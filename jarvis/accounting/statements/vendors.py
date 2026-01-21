"""Vendor matching logic for bank statement transactions.

Matches transaction descriptions to known vendors/suppliers
using regex patterns from the vendor_mappings table.
"""
import re
import logging
import threading
from typing import Optional

from .database import get_all_vendor_mappings

logger = logging.getLogger('jarvis.statements.vendors')

# Cache for compiled patterns with thread-safety
_compiled_patterns = None
_patterns_loaded = False
_patterns_lock = threading.RLock()


def _load_patterns():
    """Load and compile vendor patterns from database.

    Note: Caller must hold _patterns_lock.
    """
    global _compiled_patterns, _patterns_loaded

    mappings = get_all_vendor_mappings(active_only=True)
    _compiled_patterns = []

    for mapping in mappings:
        try:
            pattern = re.compile(mapping['pattern'], re.IGNORECASE)
            _compiled_patterns.append({
                'id': mapping['id'],
                'pattern': pattern,
                'supplier_name': mapping['supplier_name'],
                'supplier_vat': mapping.get('supplier_vat'),
                'template_id': mapping.get('template_id')
            })
        except re.error as e:
            logger.error(f"Invalid regex pattern '{mapping['pattern']}': {e}")

    _patterns_loaded = True
    logger.info(f'Loaded {len(_compiled_patterns)} vendor patterns')


def reload_patterns():
    """Force reload of vendor patterns from database."""
    global _patterns_loaded
    with _patterns_lock:
        _patterns_loaded = False
        _load_patterns()


def match_vendor(description: str) -> dict:
    """
    Match a transaction description to a known vendor.

    Args:
        description: Transaction description text

    Returns:
        {
            'matched': bool,
            'vendor_name': str or None,  # Extracted vendor name from description
            'supplier_name': str or None,  # Mapped supplier name
            'supplier_vat': str or None,
            'template_id': int or None,
            'mapping_id': int or None
        }
    """
    global _compiled_patterns, _patterns_loaded

    # Thread-safe pattern loading
    with _patterns_lock:
        if not _patterns_loaded:
            _load_patterns()
        # Copy reference to avoid race conditions during iteration
        patterns = _compiled_patterns

    result = {
        'matched': False,
        'vendor_name': None,
        'supplier_name': None,
        'supplier_vat': None,
        'template_id': None,
        'mapping_id': None
    }

    if not description:
        return result

    # Extract a human-readable vendor name from description
    result['vendor_name'] = extract_vendor_name(description)

    # Try to match against known patterns (using local reference)
    for mapping in patterns:
        if mapping['pattern'].search(description):
            result['matched'] = True
            result['supplier_name'] = mapping['supplier_name']
            result['supplier_vat'] = mapping['supplier_vat']
            result['template_id'] = mapping['template_id']
            result['mapping_id'] = mapping['id']
            logger.debug(f"Matched '{description[:50]}...' to {mapping['supplier_name']}")
            return result

    return result


def extract_vendor_name(description: str) -> Optional[str]:
    """
    Extract a readable vendor name from transaction description.

    Examples:
        'FACEBK *9DGR2CRV62' -> 'FACEBK'
        'GOOGLE *ADS3555304242' -> 'GOOGLE ADS'
        'CLAUDE.AI SUBSCRIPTION' -> 'CLAUDE.AI'
        'OPENAI *CHATGPT SUBSCR' -> 'OPENAI CHATGPT'
    """
    if not description:
        return None

    # Common vendor patterns with readable names
    vendor_patterns = [
        (r'FACEBK\s*\*\w+', 'FACEBK'),
        (r'GOOGLE\s*\*\s*ADS\d+', 'GOOGLE ADS'),
        (r'GOOGLE\s*CLOUD\s*\w+', 'GOOGLE CLOUD'),
        (r'CLAUDE\.AI\s*\w*', 'CLAUDE.AI'),
        (r'OPENAI\s*\*\s*CHATGPT\s*\w*', 'OPENAI CHATGPT'),
        (r'DIGITALOCEAN\.?COM?', 'DIGITALOCEAN'),
        (r'DREAMSTIME\.?COM?', 'DREAMSTIME'),
        (r'SHOPIFY\s*\*\s*\d+', 'SHOPIFY'),
        (r'Intuit\s*Mailchimp', 'MAILCHIMP'),
        (r'ANCPI\s*NETOPIA', 'ANCPI'),
        (r'tarom\.ro', 'TAROM'),
        (r'ONRC', 'ONRC'),
        (r'MPY\*hisky', 'HISKY'),
        (r'ANIMA\s*WINGS', 'ANIMA WINGS'),
        (r'AWESOME\s*PROJECTS', 'AWESOME PROJECTS'),
        (r'AIRALO', 'AIRALO'),
    ]

    for pattern, name in vendor_patterns:
        if re.search(pattern, description, re.IGNORECASE):
            return name

    # Fallback: Try to extract first recognizable word/phrase
    # Look for capitalized words that might be vendor names
    match = re.search(r'\d{4}\.\d{2}\.\d{2}\s+([A-Z][A-Za-z0-9.*]+(?:\s+[A-Z][A-Za-z0-9]+)?)', description)
    if match:
        return match.group(1).strip()

    return None


def match_transactions(transactions: list[dict]) -> list[dict]:
    """
    Match a list of transactions to vendors.

    Args:
        transactions: List of transaction dicts with 'description' field

    Returns:
        Same list with added vendor matching fields:
        - vendor_name
        - matched_supplier
        - status ('matched' or 'pending')
    """
    for txn in transactions:
        match_result = match_vendor(txn.get('description', ''))

        txn['vendor_name'] = match_result['vendor_name']
        txn['matched_supplier'] = match_result['supplier_name']

        # Set status based on transaction type
        # Note: 'matched' status is reserved for invoice matching, not vendor matching
        if txn.get('transaction_type') == 'internal':
            txn['status'] = 'ignored'  # Auto-ignore internal transfers
        else:
            txn['status'] = 'pending'  # All other transactions start as pending

    return transactions


def get_unmatched_vendors(transactions: list[dict]) -> list[str]:
    """
    Get list of unique unmatched vendor names from transactions.

    Useful for suggesting new vendor mappings to create.
    """
    unmatched = set()
    for txn in transactions:
        if txn.get('status') == 'pending' and txn.get('vendor_name'):
            unmatched.add(txn['vendor_name'])
    return sorted(list(unmatched))
