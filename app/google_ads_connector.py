"""
Google Ads Invoice Connector Module

This module provides functionality for fetching invoices from Google Ads.
Since Google Ads doesn't provide a simple API for invoice downloads, this connector uses
browser automation (Playwright) to:
1. Log into Google Ads with stored credentials
2. Navigate to the billing/documents page
3. Download PDF invoices
4. Parse them for integration with bulk budgeting

Configuration:
- email: Google account email
- password: Google account password
- account_id: Google Ads account ID (e.g., 320-749-2288)

The connector stores browser session cookies to avoid repeated logins.
"""

import os
import re
import json
import tempfile
from datetime import datetime
from typing import Optional, List, Dict, Any
from io import BytesIO

# Optional: Playwright for browser automation
try:
    from playwright.sync_api import sync_playwright, Browser, Page, BrowserContext
    PLAYWRIGHT_AVAILABLE = True
except ImportError:
    PLAYWRIGHT_AVAILABLE = False

# PDF parsing
try:
    import PyPDF2
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False


# Google Ads URLs
GOOGLE_ADS_BASE_URL = 'https://ads.google.com'
GOOGLE_ADS_BILLING_URL = 'https://ads.google.com/aw/billing/documents'
GOOGLE_LOGIN_URL = 'https://accounts.google.com'


def check_dependencies() -> Dict[str, bool]:
    """Check if required dependencies are available."""
    return {
        'playwright': PLAYWRIGHT_AVAILABLE,
        'pypdf2': PDF_AVAILABLE
    }


def parse_google_ads_invoice_text(text: str) -> Dict[str, Any]:
    """
    Parse Google Ads invoice from extracted PDF text.

    Google Ads invoices contain:
    - Invoice number
    - Invoice date
    - Billing period
    - Campaign breakdown with clicks and costs
    - Total amount in RON/EUR/USD

    Returns dict with:
        - invoice_number
        - invoice_date
        - billing_period
        - invoice_value
        - currency
        - items: dict of campaign_name -> cost
    """
    result = {
        'supplier': 'Google Ireland Limited',
        'supplier_vat': 'IE 6388047V',
        'currency': 'RON',
        'items': {}
    }

    # Extract invoice number
    invoice_match = re.search(r'Invoice\s*(?:number)?[:\s]*(\d{10})', text, re.IGNORECASE)
    if invoice_match:
        result['invoice_number'] = invoice_match.group(1).strip()

    # Extract invoice date (format: Nov 30, 2025 or November 30, 2025)
    date_patterns = [
        r'Invoice\s*date[:\s]*(\w+\s+\d{1,2},?\s*\d{4})',
        r'(\w{3}\s+\d{1,2},\s*\d{4})',
    ]

    for pattern in date_patterns:
        date_match = re.search(pattern, text, re.IGNORECASE)
        if date_match:
            result['invoice_date'] = date_match.group(1).strip()
            break

    # Extract billing period
    period_match = re.search(
        r'(?:Summary\s+for|Period)[:\s]*(\w+\s+\d{1,2},?\s*\d{4})\s*[-–]\s*(\w+\s+\d{1,2},?\s*\d{4})',
        text, re.IGNORECASE
    )
    if period_match:
        result['billing_period_start'] = period_match.group(1).strip()
        result['billing_period_end'] = period_match.group(2).strip()

    # Extract total amount and currency
    # Patterns: "RON 6,986.88", "Total in RON RON 6,986.88", "€1,234.56"
    total_patterns = [
        r'Total\s+in\s+(\w+)\s+\1\s*([\d,]+\.?\d*)',  # "Total in RON RON 6,986.88"
        r'Total\s+in\s+(\w+)[:\s]*([\d,]+\.?\d*)',     # "Total in RON: 6,986.88"
        r'(RON|EUR|USD)\s*([\d,]+\.?\d*)',             # "RON 6,986.88"
    ]

    for pattern in total_patterns:
        total_match = re.search(pattern, text, re.IGNORECASE)
        if total_match:
            result['currency'] = total_match.group(1).upper()
            value_str = total_match.group(2).replace(',', '')
            if value_str:
                result['invoice_value'] = float(value_str)
            break

    # Extract campaign breakdown
    # Format: "[CA] S General 3230 Clicks 1,519.98"
    campaign_pattern = r'\[CA\]\s*([^\d]+?)\s+(\d+)\s+Clicks\s+([\d,]+\.?\d*)'

    for match in re.finditer(campaign_pattern, text):
        campaign_name = f"[CA] {match.group(1).strip()}"
        value_str = match.group(3).replace(',', '')
        if value_str:
            try:
                result['items'][campaign_name] = float(value_str)
            except ValueError:
                pass

    # Extract customer VAT
    customer_vat_match = re.search(r'VAT\s*number[:\s]*([A-Z]{2}\s*\d+)', text, re.IGNORECASE)
    if customer_vat_match:
        # Find the second VAT number (customer's, not Google's)
        vat_numbers = re.findall(r'VAT\s*number[:\s]*([A-Z]{2}\s*\d+)', text, re.IGNORECASE)
        if len(vat_numbers) >= 2:
            result['customer_vat'] = vat_numbers[1].replace(' ', '')

    # Extract Account ID
    account_match = re.search(r'Account\s*ID[:\s]*([\d-]+)', text, re.IGNORECASE)
    if account_match:
        result['account_id'] = account_match.group(1).strip()

    return result


def extract_text_from_pdf_bytes(pdf_bytes: bytes) -> str:
    """Extract text from PDF bytes."""
    if not PDF_AVAILABLE:
        raise ImportError("PyPDF2 is required for PDF parsing")

    text = ''
    try:
        reader = PyPDF2.PdfReader(BytesIO(pdf_bytes))
        for page in reader.pages:
            text += page.extract_text() or ''
    except Exception as e:
        print(f"Error extracting PDF text: {e}")

    return text


class GoogleAdsConnector:
    """
    Connector for fetching invoices from Google Ads.

    Uses Playwright browser automation with persistent context
    to maintain login sessions.
    """

    def __init__(self, config: Dict[str, Any] = None, credentials: Dict[str, Any] = None):
        """
        Initialize the connector.

        Args:
            config: Configuration dict (may include account_id, date_range, etc.)
            credentials: Credentials dict with email, password
        """
        self.config = config or {}
        self.credentials = credentials or {}

        self.email = self.credentials.get('email', '')
        self.password = self.credentials.get('password', '')
        self.account_id = self.config.get('account_id', '')

        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None
        self.page: Optional[Page] = None
        self._playwright = None
        self._temp_dir = None  # Temporary directory for this session

        # Directory for storing browser state - use unique dir per session to avoid lock conflicts
        self.user_data_dir = None  # Will be set in _ensure_browser

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def close(self):
        """Close browser and cleanup."""
        if self.page:
            self.page.close()
            self.page = None
        if self.context:
            self.context.close()
            self.context = None
        if self.browser:
            self.browser.close()
            self.browser = None
        if self._playwright:
            self._playwright.stop()
            self._playwright = None
        # Clean up temp directory
        if self._temp_dir and os.path.exists(self._temp_dir):
            import shutil
            try:
                shutil.rmtree(self._temp_dir)
            except Exception:
                pass  # Ignore cleanup errors
            self._temp_dir = None

    def _ensure_browser(self):
        """Ensure browser is initialized with persistent context."""
        if not PLAYWRIGHT_AVAILABLE:
            raise ImportError(
                "Playwright is required for Google Ads connector. "
                "Install with: pip install playwright && playwright install chromium"
            )

        # Check if already initialized (use context since we use persistent context, not browser)
        if not self.context:
            self._playwright = sync_playwright().start()

            # Create unique temp directory for this session to avoid lock conflicts
            self._temp_dir = tempfile.mkdtemp(prefix='bugetare_gads_')
            self.user_data_dir = self._temp_dir

            # Use persistent context to maintain cookies/session
            self.context = self._playwright.chromium.launch_persistent_context(
                self.user_data_dir,
                headless=False,  # Google often blocks headless browsers
                args=['--no-sandbox', '--disable-setuid-sandbox'],
                viewport={'width': 1280, 'height': 800}
            )

            # Use existing page or create new one
            if self.context.pages:
                self.page = self.context.pages[0]
            else:
                self.page = self.context.new_page()

    def is_logged_in(self) -> bool:
        """Check if already logged into Google Ads."""
        try:
            self._ensure_browser()

            # Navigate to Google Ads
            self.page.goto(GOOGLE_ADS_BASE_URL, timeout=30000)
            self.page.wait_for_load_state('networkidle', timeout=15000)

            current_url = self.page.url

            # If we're on a Google Ads page (not login), we're logged in
            if 'ads.google.com/aw' in current_url or 'ads.google.com/nav/selectaccount' in current_url:
                return True

            return False

        except Exception as e:
            print(f"Error checking login status: {e}")
            return False

    def login(self) -> bool:
        """
        Log into Google Ads.

        Note: Google's login flow often requires manual interaction
        (2FA, captcha, etc.). This method attempts automatic login
        but may require user intervention.

        Returns:
            True if login successful, False otherwise
        """
        if not self.email or not self.password:
            raise ValueError("Email and password are required for login")

        self._ensure_browser()

        try:
            # Check if already logged in
            if self.is_logged_in():
                return True

            # Navigate to Google login
            self.page.goto(GOOGLE_LOGIN_URL, wait_until='networkidle', timeout=30000)

            # Wait for email input
            email_input = self.page.wait_for_selector(
                'input[type="email"]',
                timeout=10000
            )

            if email_input:
                email_input.fill(self.email)

                # Click Next
                next_btn = self.page.query_selector('button:has-text("Next"), #identifierNext')
                if next_btn:
                    next_btn.click()
                    self.page.wait_for_load_state('networkidle')

            # Wait for password input - needs to be visible, not just present
            password_input = self.page.wait_for_selector(
                'input[type="password"]:visible',
                timeout=15000,
                state='visible'
            )

            if password_input:
                # Small delay to ensure field is ready
                self.page.wait_for_timeout(500)
                password_input.fill(self.password)

                # Click Next/Sign in
                signin_btn = self.page.query_selector('#passwordNext, button:has-text("Next")')
                if signin_btn:
                    signin_btn.click()

                    # Wait for redirect to Google Ads or 2FA prompt
                    self.page.wait_for_timeout(5000)

            # Check if we reached Google Ads
            current_url = self.page.url
            if 'ads.google.com' in current_url:
                return True

            # May need manual intervention for 2FA
            print("Login may require manual verification (2FA, captcha, etc.)")
            return False

        except Exception as e:
            print(f"Login failed: {e}")
            return False

    def select_account(self, account_id: str = None) -> bool:
        """
        Select a specific Google Ads account.

        Args:
            account_id: Account ID like "320-749-2288"
        """
        try:
            account_id = account_id or self.account_id

            if not account_id:
                # Just proceed without selecting specific account
                return True

            # Check if on account selection page
            if 'selectaccount' in self.page.url:
                # Look for account in list
                account_selector = f'[data-accountid="{account_id}"], :has-text("{account_id}")'
                account_elem = self.page.query_selector(account_selector)

                if account_elem:
                    account_elem.click()
                    self.page.wait_for_load_state('networkidle')
                    return True

            return True

        except Exception as e:
            print(f"Error selecting account: {e}")
            return False

    def navigate_to_documents(self) -> bool:
        """Navigate to the billing documents page."""
        try:
            self._ensure_browser()

            # Build URL with account ID if available
            url = GOOGLE_ADS_BILLING_URL

            self.page.goto(url, timeout=30000, wait_until='domcontentloaded')

            # Check if we got redirected to login
            current_url = self.page.url
            if 'accounts.google.com' in current_url or 'signin' in current_url:
                # Need to login first
                if not self.login():
                    print("Login required but failed")
                    return False
                # Navigate again after login
                self.page.goto(url, timeout=30000, wait_until='domcontentloaded')

            # Wait for page to settle
            self.page.wait_for_timeout(3000)

            return True

        except Exception as e:
            print(f"Failed to navigate to documents: {e}")
            import traceback
            traceback.print_exc()
            return False

    def get_invoice_list(self) -> List[Dict[str, Any]]:
        """
        Get list of available invoices from the documents page.

        Returns:
            List of invoice metadata dicts with document_number, date, amount, type
        """
        invoices = []

        try:
            # The documents are in an iframe
            frame = self.page.frame_locator('iframe[name*="containerIframe"]')

            # Wait for table to load
            frame.locator('table').wait_for(timeout=10000)

            # Get all rows in the table body
            rows = frame.locator('table tbody tr').all()

            for row in rows:
                try:
                    cells = row.locator('td, [role="gridcell"]').all()

                    if len(cells) >= 5:
                        # Skip pagination row
                        row_text = row.inner_text()
                        if 'Rows per page' in row_text:
                            continue

                        invoice = {
                            'issue_date': cells[1].inner_text().strip(),
                            'document_type': cells[2].inner_text().strip(),
                            'document_number': cells[3].inner_text().strip(),
                            'amount': cells[4].inner_text().strip(),
                            'row_element': row
                        }

                        # Only add if it has valid data
                        if invoice['document_number'] and invoice['issue_date']:
                            invoices.append(invoice)

                except Exception as e:
                    continue

        except Exception as e:
            print(f"Error getting invoice list: {e}")

        return invoices

    def download_invoice_pdf(self, invoice: Dict[str, Any]) -> Optional[bytes]:
        """
        Download a specific invoice PDF.

        Args:
            invoice: Invoice dict with row_element or download info

        Returns:
            PDF bytes or None if download failed
        """
        try:
            row = invoice.get('row_element')
            if not row:
                return None

            # Find download button in the row
            download_btn = row.locator('button:has-text("Download")').first

            if download_btn:
                # Set up download handler
                with self.page.expect_download(timeout=30000) as download_info:
                    download_btn.click()

                download = download_info.value

                # Save to temp file and read bytes
                with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as tmp:
                    tmp_path = tmp.name

                download.save_as(tmp_path)

                with open(tmp_path, 'rb') as f:
                    pdf_bytes = f.read()

                os.unlink(tmp_path)
                return pdf_bytes

        except Exception as e:
            print(f"Error downloading invoice: {e}")

        return None

    def sync_invoices(
        self,
        max_invoices: int = 12
    ) -> Dict[str, Any]:
        """
        Sync invoices from Google Ads.

        Args:
            max_invoices: Maximum number of invoices to fetch

        Returns:
            Dict with:
                - success: bool
                - invoices: list of invoice dicts with filename, pdf_bytes, parsed data
                - invoices_found: count
                - errors: list of error messages
        """
        result = {
            'success': False,
            'invoices': [],
            'invoices_found': 0,
            'invoices_downloaded': 0,
            'errors': []
        }

        try:
            self._ensure_browser()

            # Navigate to documents page
            if not self.navigate_to_documents():
                result['errors'].append('Failed to navigate to documents page')
                return result

            # Give time for iframe to load
            self.page.wait_for_timeout(3000)

            # Get invoice list
            invoice_list = self.get_invoice_list()
            result['invoices_found'] = len(invoice_list)

            # Download each invoice
            for inv in invoice_list[:max_invoices]:
                try:
                    # Download PDF
                    pdf_bytes = self.download_invoice_pdf(inv)

                    if not pdf_bytes:
                        continue

                    # Parse invoice
                    text = extract_text_from_pdf_bytes(pdf_bytes)
                    parsed = parse_google_ads_invoice_text(text)

                    # Create filename
                    filename = f"{inv['document_number']}.pdf"

                    invoice_data = {
                        'filename': filename,
                        'document_number': inv['document_number'],
                        'issue_date': inv['issue_date'],
                        'document_type': inv['document_type'],
                        'amount': inv['amount'],
                        'pdf_bytes': pdf_bytes,
                        'parsed': parsed,
                        'source': 'google_ads'
                    }

                    result['invoices'].append(invoice_data)
                    result['invoices_downloaded'] += 1

                except Exception as e:
                    result['errors'].append(f"Error processing invoice {inv.get('document_number', 'unknown')}: {e}")

            result['success'] = True

        except Exception as e:
            result['errors'].append(str(e))

        return result


def _run_sync_in_subprocess(credentials: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Run the Google Ads sync in a subprocess to avoid asyncio conflicts with Flask.
    """
    import subprocess
    import sys

    # Create a small script to run the sync
    script = f'''
import sys
import json
sys.path.insert(0, '/Users/sebastiansabo/Documents/Git/Bugetare/app')
from google_ads_connector import GoogleAdsConnector

credentials = {json.dumps(credentials)}
config = {json.dumps(config)}
max_invoices = config.get('max_invoices', 12)

connector = GoogleAdsConnector(config=config, credentials=credentials)
result = connector.sync_invoices(max_invoices=max_invoices)

# Remove pdf_bytes from result as it's too large for subprocess output
for inv in result.get('invoices', []):
    if 'pdf_bytes' in inv:
        del inv['pdf_bytes']

print(json.dumps(result))
'''

    try:
        result = subprocess.run(
            [sys.executable, '-c', script],
            capture_output=True,
            text=True,
            timeout=120  # 2 minute timeout
        )

        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            return {
                'success': False,
                'invoices': [],
                'errors': [f"Subprocess error: {result.stderr}"]
            }
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'invoices': [],
            'errors': ['Timeout: Invoice fetch took too long']
        }
    except Exception as e:
        return {
            'success': False,
            'invoices': [],
            'errors': [str(e)]
        }


def fetch_google_ads_invoices(
    credentials: Dict[str, Any],
    config: Dict[str, Any] = None
) -> Dict[str, Any]:
    """
    High-level function to fetch Google Ads invoices.

    Args:
        credentials: Dict with email, password
        config: Optional config with account_id, max_invoices

    Returns:
        Sync result dict
    """
    config = config or {}

    # Check if we're in an asyncio loop (Flask) - if so, use subprocess
    try:
        import asyncio
        loop = asyncio.get_running_loop()
        # We're in an async context, run in subprocess
        return _run_sync_in_subprocess(credentials, config)
    except RuntimeError:
        # No running loop, we can use sync API directly
        max_invoices = config.get('max_invoices', 12)
        connector = GoogleAdsConnector(config=config, credentials=credentials)

        try:
            return connector.sync_invoices(max_invoices=max_invoices)
        finally:
            # Don't close - keep session for reuse
            pass


def parse_google_ads_invoice_for_bulk(invoice_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Convert parsed Google Ads invoice to bulk processor format.

    Args:
        invoice_data: Invoice dict from sync_invoices

    Returns:
        Dict in bulk processor format with items/campaigns
    """
    parsed = invoice_data.get('parsed', {})

    result = {
        'supplier': parsed.get('supplier', 'Google Ireland Limited'),
        'supplier_vat': parsed.get('supplier_vat', 'IE 6388047V'),
        'invoice_number': parsed.get('invoice_number', invoice_data.get('document_number', '')),
        'invoice_date': parsed.get('invoice_date', invoice_data.get('issue_date', '')),
        'invoice_value': parsed.get('invoice_value', 0),
        'currency': parsed.get('currency', 'RON'),
        'items': parsed.get('items', {}),
        'campaigns': parsed.get('items', {}),  # Alias for compatibility
        'filename': invoice_data.get('filename', ''),
        'pdf_bytes': invoice_data.get('pdf_bytes'),
    }

    # If no items breakdown, create single item with total
    if not result['items'] and result['invoice_value']:
        result['items'] = {'Google Ads': result['invoice_value']}
        result['campaigns'] = result['items']

    return result


# Test function for development
def test_parser():
    """Test the invoice parser with sample text."""
    sample_text = """
    Google
    Invoice

    Invoice number: 5431698595
    Invoice date: Nov 30, 2025
    Billing ID: 0229-3468-0893
    Account ID: 320-749-2288

    Bill to
    Sebastian Sabo
    Autoworld Next s.r.l.
    VAT number: RO 50186814

    Google Ireland Limited
    VAT number: IE 6388047V

    Summary for Nov 1, 2025 - Nov 30, 2025
    Subtotal in RON RON 6,986.88
    VAT (0%) RON 0.00
    Total in RON RON 6,986.88

    Account: Autoworld.ro
    Account ID: 320-749-2288

    [CA] S General 3230 Clicks 1,519.98
    [CA] S Skoda modele 1682 Clicks 1,519.93
    [CA] S Modele BMW 698 Clicks 1,519.84
    [CA] S Mazda CX80 767 Clicks 1,214.12
    [CA] S Mazda CX60 1151 Clicks 1,213.01
    """

    result = parse_google_ads_invoice_text(sample_text)
    print(json.dumps(result, indent=2, default=str))
    return result


if __name__ == '__main__':
    test_parser()
