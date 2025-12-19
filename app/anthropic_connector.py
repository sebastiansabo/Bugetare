"""
Anthropic Invoice Connector Module

This module provides functionality for fetching invoices from the Anthropic Console.
Since Anthropic doesn't provide a public API for invoices, this connector uses
browser automation (Playwright) to:
1. Log into the Anthropic Console
2. Navigate to the billing/invoices page
3. Download PDF invoices
4. Parse them for integration with bulk budgeting

Configuration:
- email: Anthropic console email
- password: Anthropic console password (stored encrypted)
- session_token: Optional - saved session to avoid re-login

Environment Variables:
- ANTHROPIC_CONSOLE_EMAIL: Console login email
- ANTHROPIC_CONSOLE_PASSWORD: Console login password
"""

import os
import re
import json
import tempfile
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any
from io import BytesIO

# Optional: Playwright for browser automation
try:
    from playwright.sync_api import sync_playwright, Browser, Page
    PLAYWRIGHT_AVAILABLE = True
except ImportError:
    PLAYWRIGHT_AVAILABLE = False

# PDF parsing
try:
    import PyPDF2
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False


# Anthropic Console URLs
CONSOLE_BASE_URL = 'https://console.anthropic.com'
BILLING_URL = f'{CONSOLE_BASE_URL}/settings/billing'
LOGIN_URL = f'{CONSOLE_BASE_URL}/login'


def check_dependencies() -> Dict[str, bool]:
    """Check if required dependencies are available."""
    return {
        'playwright': PLAYWRIGHT_AVAILABLE,
        'pypdf2': PDF_AVAILABLE
    }


def parse_anthropic_invoice_text(text: str) -> Dict[str, Any]:
    """
    Parse Anthropic invoice from extracted PDF text.

    Anthropic invoices typically contain:
    - Invoice number
    - Invoice date
    - Billing period
    - Usage breakdown by model
    - Total amount in USD

    Returns dict with:
        - invoice_number
        - invoice_date
        - billing_period_start
        - billing_period_end
        - invoice_value
        - currency (usually USD)
        - items: dict of model_name -> cost
    """
    result = {
        'supplier': 'Anthropic',
        'supplier_vat': '',  # Anthropic is US-based, no VAT
        'currency': 'USD',
        'items': {}
    }

    # Extract invoice number (typically format: INV-XXXXXX or similar)
    invoice_match = re.search(r'(?:Invoice|Invoice\s*#|Invoice\s*Number)[:\s]*([A-Z0-9-]+)', text, re.IGNORECASE)
    if invoice_match:
        result['invoice_number'] = invoice_match.group(1).strip()

    # Try alternate invoice number patterns
    if 'invoice_number' not in result:
        alt_match = re.search(r'\b(INV-\d+|[A-Z]{2,}\d{6,})\b', text)
        if alt_match:
            result['invoice_number'] = alt_match.group(1)

    # Extract date patterns
    # Try "Invoice Date: Month DD, YYYY" or "Date: YYYY-MM-DD"
    date_patterns = [
        r'(?:Invoice\s*Date|Date)[:\s]*(\w+\s+\d{1,2},?\s*\d{4})',
        r'(?:Invoice\s*Date|Date)[:\s]*(\d{4}-\d{2}-\d{2})',
        r'(?:Invoice\s*Date|Date)[:\s]*(\d{1,2}/\d{1,2}/\d{4})',
        r'(\w+\s+\d{1,2},?\s*\d{4})'  # Fallback: any date
    ]

    for pattern in date_patterns:
        date_match = re.search(pattern, text, re.IGNORECASE)
        if date_match:
            result['invoice_date'] = date_match.group(1).strip()
            result['date_parsed'] = parse_date(result['invoice_date'])
            break

    # Extract billing period
    period_match = re.search(
        r'(?:Billing\s*Period|Period)[:\s]*(\w+\s+\d{1,2},?\s*\d{4})\s*[-–to]+\s*(\w+\s+\d{1,2},?\s*\d{4})',
        text, re.IGNORECASE
    )
    if period_match:
        result['billing_period_start'] = period_match.group(1).strip()
        result['billing_period_end'] = period_match.group(2).strip()

    # Extract total amount
    # Patterns: "$1,234.56", "USD 1234.56", "Total: $1,234.56"
    total_patterns = [
        r'(?:Total|Amount\s*Due|Grand\s*Total)[:\s]*\$?([\d,]+\.?\d*)',
        r'\$\s*([\d,]+\.\d{2})\s*(?:USD)?',
        r'USD\s*([\d,]+\.\d{2})',
    ]

    for pattern in total_patterns:
        total_match = re.search(pattern, text, re.IGNORECASE)
        if total_match:
            value_str = total_match.group(1).replace(',', '')
            result['invoice_value'] = float(value_str)
            break

    # Extract model usage breakdown
    # Look for patterns like "Claude 3 Opus: $XX.XX" or "claude-3-opus: XX.XX USD"
    model_patterns = [
        r'(Claude[\s\-]*\d*[\s\-]*(?:Opus|Sonnet|Haiku|Instant)?)[:\s]*\$?([\d,]+\.?\d*)',
        r'(claude-[\w\-]+)[:\s]*\$?([\d,]+\.?\d*)',
        r'(API\s*Usage)[:\s]*\$?([\d,]+\.?\d*)',
    ]

    for pattern in model_patterns:
        for match in re.finditer(pattern, text, re.IGNORECASE):
            model_name = match.group(1).strip()
            value_str = match.group(2).replace(',', '')
            if value_str:
                try:
                    result['items'][model_name] = float(value_str)
                except ValueError:
                    pass

    return result


def parse_date(date_str: str) -> Optional[datetime]:
    """Parse various date formats to datetime object."""
    if not date_str:
        return None

    # Common date formats
    formats = [
        '%B %d, %Y',      # December 15, 2024
        '%b %d, %Y',      # Dec 15, 2024
        '%Y-%m-%d',       # 2024-12-15
        '%m/%d/%Y',       # 12/15/2024
        '%d/%m/%Y',       # 15/12/2024
        '%B %d %Y',       # December 15 2024
    ]

    for fmt in formats:
        try:
            return datetime.strptime(date_str.strip(), fmt)
        except ValueError:
            continue

    return None


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


class AnthropicConnector:
    """
    Connector for fetching invoices from Anthropic Console.

    Uses Playwright browser automation since there's no public API.
    """

    def __init__(self, config: Dict[str, Any] = None, credentials: Dict[str, Any] = None):
        """
        Initialize the connector.

        Args:
            config: Configuration dict (may include date_range, etc.)
            credentials: Credentials dict with email, password, or session_token
        """
        self.config = config or {}
        self.credentials = credentials or {}

        # Get credentials from env if not provided
        self.email = self.credentials.get('email') or os.environ.get('ANTHROPIC_CONSOLE_EMAIL', '')
        self.password = self.credentials.get('password') or os.environ.get('ANTHROPIC_CONSOLE_PASSWORD', '')
        self.session_token = self.credentials.get('session_token', '')

        self.browser: Optional[Browser] = None
        self.page: Optional[Page] = None
        self._playwright = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def close(self):
        """Close browser and cleanup."""
        if self.page:
            self.page.close()
            self.page = None
        if self.browser:
            self.browser.close()
            self.browser = None
        if self._playwright:
            self._playwright.stop()
            self._playwright = None

    def _ensure_browser(self):
        """Ensure browser is initialized."""
        if not PLAYWRIGHT_AVAILABLE:
            raise ImportError(
                "Playwright is required for Anthropic connector. "
                "Install with: pip install playwright && playwright install chromium"
            )

        if not self.browser:
            self._playwright = sync_playwright().start()
            self.browser = self._playwright.chromium.launch(
                headless=True,  # Set to False for debugging
                args=['--no-sandbox', '--disable-setuid-sandbox']
            )
            self.page = self.browser.new_page()

    def login(self) -> bool:
        """
        Log into Anthropic Console.

        Returns:
            True if login successful, False otherwise
        """
        if not self.email or not self.password:
            raise ValueError("Email and password are required for login")

        self._ensure_browser()

        try:
            # Navigate to login page
            self.page.goto(LOGIN_URL, wait_until='networkidle')

            # Wait for login form
            self.page.wait_for_selector('input[type="email"], input[name="email"]', timeout=10000)

            # Fill email
            email_input = self.page.query_selector('input[type="email"], input[name="email"]')
            if email_input:
                email_input.fill(self.email)

            # Fill password
            password_input = self.page.query_selector('input[type="password"], input[name="password"]')
            if password_input:
                password_input.fill(self.password)

            # Click login button
            login_btn = self.page.query_selector('button[type="submit"]')
            if login_btn:
                login_btn.click()

            # Wait for navigation to complete
            self.page.wait_for_url('**/dashboard**', timeout=30000)

            return True

        except Exception as e:
            print(f"Login failed: {e}")
            return False

    def navigate_to_billing(self) -> bool:
        """Navigate to the billing page."""
        self._ensure_browser()

        try:
            self.page.goto(BILLING_URL, wait_until='networkidle')
            self.page.wait_for_load_state('domcontentloaded')
            return True
        except Exception as e:
            print(f"Failed to navigate to billing: {e}")
            return False

    def get_invoice_list(self) -> List[Dict[str, Any]]:
        """
        Get list of available invoices from the billing page.

        Returns:
            List of invoice metadata dicts with id, date, amount, download_url
        """
        invoices = []

        try:
            # Wait for invoice list to load
            self.page.wait_for_selector('[data-testid="invoice-row"], .invoice-item, tr', timeout=10000)

            # Try to find invoice rows
            invoice_elements = self.page.query_selector_all(
                '[data-testid="invoice-row"], .invoice-item, table tbody tr'
            )

            for elem in invoice_elements:
                try:
                    # Extract invoice data from row
                    text = elem.inner_text()

                    # Look for date
                    date_match = re.search(r'(\w+\s+\d{1,2},?\s*\d{4}|\d{4}-\d{2}-\d{2})', text)

                    # Look for amount
                    amount_match = re.search(r'\$?([\d,]+\.\d{2})', text)

                    # Look for download link
                    download_link = elem.query_selector('a[href*="download"], a[href*="invoice"], button')

                    invoice = {
                        'date': date_match.group(1) if date_match else None,
                        'amount': float(amount_match.group(1).replace(',', '')) if amount_match else None,
                        'element': elem,
                        'download_available': download_link is not None
                    }

                    if invoice['date'] or invoice['amount']:
                        invoices.append(invoice)

                except Exception as e:
                    print(f"Error parsing invoice row: {e}")
                    continue

        except Exception as e:
            print(f"Error getting invoice list: {e}")

        return invoices

    def download_invoice_pdf(self, invoice: Dict[str, Any]) -> Optional[bytes]:
        """
        Download a specific invoice PDF.

        Args:
            invoice: Invoice dict with element or download info

        Returns:
            PDF bytes or None if download failed
        """
        try:
            elem = invoice.get('element')
            if not elem:
                return None

            # Look for download button/link
            download_btn = elem.query_selector(
                'a[href*="download"], a[href*="pdf"], button[aria-label*="download"]'
            )

            if download_btn:
                # Set up download handler
                with self.page.expect_download() as download_info:
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
        start_date: datetime = None,
        end_date: datetime = None,
        max_invoices: int = 12
    ) -> Dict[str, Any]:
        """
        Sync invoices from Anthropic Console.

        Args:
            start_date: Only fetch invoices after this date
            end_date: Only fetch invoices before this date
            max_invoices: Maximum number of invoices to fetch

        Returns:
            Dict with:
                - success: bool
                - invoices: list of parsed invoice dicts
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
            # Login if not already
            if not self.login():
                result['errors'].append('Login failed')
                return result

            # Navigate to billing
            if not self.navigate_to_billing():
                result['errors'].append('Failed to navigate to billing page')
                return result

            # Get invoice list
            invoice_list = self.get_invoice_list()
            result['invoices_found'] = len(invoice_list)

            # Download and parse each invoice
            for inv in invoice_list[:max_invoices]:
                try:
                    # Check date filter
                    if inv.get('date'):
                        inv_date = parse_date(inv['date'])
                        if inv_date:
                            if start_date and inv_date < start_date:
                                continue
                            if end_date and inv_date > end_date:
                                continue

                    # Download PDF
                    pdf_bytes = self.download_invoice_pdf(inv)
                    if not pdf_bytes:
                        continue

                    # Parse invoice
                    text = extract_text_from_pdf_bytes(pdf_bytes)
                    parsed = parse_anthropic_invoice_text(text)

                    # Add raw data
                    parsed['pdf_bytes'] = pdf_bytes
                    parsed['raw_text'] = text

                    result['invoices'].append(parsed)
                    result['invoices_downloaded'] += 1

                except Exception as e:
                    result['errors'].append(f"Error processing invoice: {e}")

            result['success'] = True

        except Exception as e:
            result['errors'].append(str(e))

        finally:
            self.close()

        return result


def fetch_anthropic_invoices(
    credentials: Dict[str, Any],
    config: Dict[str, Any] = None
) -> Dict[str, Any]:
    """
    High-level function to fetch Anthropic invoices.

    Args:
        credentials: Dict with email, password
        config: Optional config with date_range, max_invoices

    Returns:
        Sync result dict
    """
    config = config or {}

    # Parse date range from config
    start_date = None
    end_date = None

    if config.get('start_date'):
        start_date = parse_date(config['start_date'])
    if config.get('end_date'):
        end_date = parse_date(config['end_date'])

    max_invoices = config.get('max_invoices', 12)

    with AnthropicConnector(config=config, credentials=credentials) as connector:
        return connector.sync_invoices(
            start_date=start_date,
            end_date=end_date,
            max_invoices=max_invoices
        )


def parse_anthropic_invoice_for_bulk(invoice_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Convert parsed Anthropic invoice to bulk processor format.

    This matches the format expected by bulk_processor.py

    Args:
        invoice_data: Parsed invoice from parse_anthropic_invoice_text

    Returns:
        Dict in bulk processor format with items/campaigns
    """
    result = {
        'supplier': invoice_data.get('supplier', 'Anthropic'),
        'supplier_vat': invoice_data.get('supplier_vat', ''),
        'invoice_number': invoice_data.get('invoice_number', ''),
        'invoice_date': invoice_data.get('invoice_date', ''),
        'invoice_value': invoice_data.get('invoice_value', 0),
        'currency': invoice_data.get('currency', 'USD'),
        'items': invoice_data.get('items', {}),
        'campaigns': invoice_data.get('items', {}),  # Alias for compatibility
    }

    # If no items breakdown, create single item with total
    if not result['items'] and result['invoice_value']:
        result['items'] = {'API Usage': result['invoice_value']}
        result['campaigns'] = result['items']

    return result


# Test function for development
def test_parser():
    """Test the invoice parser with sample text."""
    sample_text = """
    Anthropic
    Invoice

    Invoice Number: INV-2024-001234
    Invoice Date: December 15, 2024

    Billing Period: December 1, 2024 - December 31, 2024

    Usage Summary:
    Claude 3.5 Sonnet: $150.00
    Claude 3 Opus: $75.00
    Claude 3 Haiku: $25.00

    Total: $250.00 USD
    """

    result = parse_anthropic_invoice_text(sample_text)
    print(json.dumps(result, indent=2, default=str))
    return result


if __name__ == '__main__':
    test_parser()
