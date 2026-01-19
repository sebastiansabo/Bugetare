"""Bank Statement Parser for UniCredit PDF statements.

Extracts transactions from UniCredit bank statement PDFs.
"""
import re
import logging
from datetime import datetime
from io import BytesIO
from typing import Optional

import PyPDF2

logger = logging.getLogger('jarvis.statements.parser')

# Header extraction patterns
COMPANY_PATTERN = re.compile(r'Titular de cont\s+(.+?)(?:\n|CUI)', re.IGNORECASE)
CUI_PATTERN = re.compile(r'CUI/CNP\s+(\d+)')
ACCOUNT_PATTERN = re.compile(r'Cont ales\s+(RO\d{2}\s*[A-Z]{4}\s*[\d\s]+)')
PERIOD_PATTERN = re.compile(r'De la\s+Pana la.*?(\d{2}\.\d{2}\.\d{4})\s+(\d{2}\.\d{2}\.\d{4})', re.DOTALL)

# Balance extraction
OPENING_BALANCE_PATTERN = re.compile(r'Sold deschidere\s+\d{2}\.\d{2}\.\d{4}\s+([\d.,]+)\s*RON')
CLOSING_BALANCE_PATTERN = re.compile(r'Sold inchidere\s+\d{2}\.\d{2}\.\d{4}\s+([\d.,]+)\s*RON')
CREDIT_TOTAL_PATTERN = re.compile(r'Credit total.*?\(([\d]+)\)\s+([\d.,]+)\s*RON')
DEBIT_TOTAL_PATTERN = re.compile(r'Debit total.*?\(([\d]+)\)\s+([\d.,]+)\s*RON')

# Card number pattern (masked)
CARD_PATTERN = re.compile(r'Card[:\s]*([\d]{4}-[\dX]{2}XX-XXXX-[\d]{4})')

# Auth code pattern
AUTH_CODE_PATTERN = re.compile(r'Auth code\s+(\d+)')

# Foreign currency with exchange rate
FOREX_PATTERN = re.compile(r'([\d.,]+)\s*(EUR|USD)\s*@([\d.,]+)\s*EUR-RON')


def parse_value(value_str: str) -> float:
    """Parse European number format (1.234,56) to float."""
    if not value_str:
        return 0.0
    # Remove spaces
    value_str = value_str.replace(' ', '')
    # Handle European format: 1.234,56 -> 1234.56
    if ',' in value_str and '.' in value_str:
        value_str = value_str.replace('.', '').replace(',', '.')
    elif ',' in value_str:
        value_str = value_str.replace(',', '.')
    try:
        return float(value_str)
    except ValueError:
        logger.warning(f'Could not parse value: {value_str}')
        return 0.0


def parse_date(date_str: str) -> Optional[str]:
    """Parse DD.MM.YYYY to YYYY-MM-DD."""
    if not date_str:
        return None
    try:
        dt = datetime.strptime(date_str.strip(), '%d.%m.%Y')
        return dt.strftime('%Y-%m-%d')
    except ValueError:
        logger.warning(f'Could not parse date: {date_str}')
        return None


def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """Extract all text from a PDF file."""
    reader = PyPDF2.PdfReader(BytesIO(pdf_bytes))
    text_parts = []
    for page in reader.pages:
        text_parts.append(page.extract_text() or '')
    return '\n'.join(text_parts)


def extract_header_info(text: str) -> dict:
    """Extract company and account information from statement header."""
    info = {
        'company_name': None,
        'company_cui': None,
        'account_number': None,
        'period_from': None,
        'period_to': None,
    }

    # Company name
    match = COMPANY_PATTERN.search(text)
    if match:
        info['company_name'] = match.group(1).strip()

    # CUI
    match = CUI_PATTERN.search(text)
    if match:
        info['company_cui'] = match.group(1).strip()

    # Account number (IBAN)
    match = ACCOUNT_PATTERN.search(text)
    if match:
        # Clean up IBAN - remove extra spaces
        iban = match.group(1).strip()
        info['account_number'] = re.sub(r'\s+', '', iban)

    # Period
    match = PERIOD_PATTERN.search(text)
    if match:
        info['period_from'] = parse_date(match.group(1))
        info['period_to'] = parse_date(match.group(2))

    return info


def extract_summary(text: str) -> dict:
    """Extract balance summary from statement."""
    summary = {
        'opening_balance': None,
        'closing_balance': None,
        'credit_count': 0,
        'credit_total': None,
        'debit_count': 0,
        'debit_total': None,
    }

    match = OPENING_BALANCE_PATTERN.search(text)
    if match:
        summary['opening_balance'] = parse_value(match.group(1))

    match = CLOSING_BALANCE_PATTERN.search(text)
    if match:
        summary['closing_balance'] = parse_value(match.group(1))

    match = CREDIT_TOTAL_PATTERN.search(text)
    if match:
        summary['credit_count'] = int(match.group(1))
        summary['credit_total'] = parse_value(match.group(2))

    match = DEBIT_TOTAL_PATTERN.search(text)
    if match:
        summary['debit_count'] = int(match.group(1))
        summary['debit_total'] = parse_value(match.group(2))

    return summary


def extract_transactions(text: str, header_info: dict, filename: str = None) -> list[dict]:
    """
    Extract individual transactions from statement text.

    UniCredit format (line by line):
    DD.MM.YYYY DD.MM.YYYY Description...
                         continued description...
                         Value Currency
                         -Value RON (for debits)
    """
    transactions = []

    # Split into lines for processing
    lines = text.split('\n')

    # Transaction state machine
    current_txn = None
    description_lines = []

    # Pattern for transaction start (two dates at line start)
    date_line_pattern = re.compile(r'^(\d{2}\.\d{2}\.\d{4})\s+(\d{2}\.\d{2}\.\d{4})\s+(.*)$')

    # Pattern for value line (ends with currency and amount)
    value_pattern = re.compile(r'([\d.,]+)\s*(RON|EUR|USD)\s*$')

    # Pattern for RON conversion (negative debit)
    ron_debit_pattern = re.compile(r'-([\d.,]+)\s*RON\s*$')

    i = 0
    while i < len(lines):
        line = lines[i].strip()

        # Skip empty lines and headers
        if not line or 'printat de' in line.lower() or 'UniCredit Bank' in line:
            i += 1
            continue

        # Skip summary and header lines
        if any(skip in line for skip in ['Sold deschidere', 'Sold inchidere',
                                          'Credit total', 'Debit total',
                                          'Totalul tranzactiilor', 'Data inregistrarii',
                                          'Lista Tranzactii', 'Istoric',
                                          'Titular de cont', 'CUI/CNP', 'Cont ales',
                                          'CONT:', 'IBAN:', 'LA:UNICREDIT',
                                          'Nr op.:', 'pag.', 'Pagina']):
            i += 1
            continue

        # Check for new transaction (starts with two dates)
        date_match = date_line_pattern.match(line)
        if date_match:
            # Save previous transaction if exists
            if current_txn and description_lines:
                current_txn['description'] = ' '.join(description_lines)
                _finalize_transaction(current_txn, header_info, filename)
                if current_txn.get('amount') and _is_valid_amount(current_txn.get('amount')):
                    transactions.append(current_txn)

            # Start new transaction
            current_txn = {
                'transaction_date': parse_date(date_match.group(1)),
                'value_date': parse_date(date_match.group(2)),
                'amount': None,
                'currency': 'RON',
                'original_amount': None,
                'original_currency': None,
                'exchange_rate': None,
                'card_number': None,
                'auth_code': None,
            }
            description_lines = [date_match.group(3).strip()] if date_match.group(3).strip() else []
            i += 1
            continue

        # If we have a current transaction, collect description and look for value
        if current_txn is not None:
            # Check for RON debit value (negative)
            ron_match = ron_debit_pattern.search(line)
            if ron_match:
                current_txn['amount'] = -parse_value(ron_match.group(1))
                current_txn['currency'] = 'RON'
                i += 1
                continue

            # Check for value line (positive or foreign currency)
            value_match = value_pattern.search(line)
            if value_match:
                amount = parse_value(value_match.group(1))
                currency = value_match.group(2)

                # Check for foreign currency conversion
                forex_match = FOREX_PATTERN.search(line)
                if forex_match:
                    current_txn['original_amount'] = parse_value(forex_match.group(1))
                    current_txn['original_currency'] = forex_match.group(2)
                    current_txn['exchange_rate'] = parse_value(forex_match.group(3))
                    # The RON amount will come in next line as debit
                elif currency != 'RON':
                    # Foreign currency without conversion shown yet
                    current_txn['original_amount'] = amount
                    current_txn['original_currency'] = currency
                else:
                    # Credit in RON (positive)
                    if current_txn['amount'] is None:
                        current_txn['amount'] = amount
                        current_txn['currency'] = currency

                # Remove value from description
                desc_part = line[:value_match.start()].strip()
                if desc_part:
                    description_lines.append(desc_part)

                i += 1
                continue

            # Regular description line
            if line and not line.startswith('Data'):
                description_lines.append(line)

        i += 1

    # Don't forget last transaction
    if current_txn and description_lines:
        current_txn['description'] = ' '.join(description_lines)
        _finalize_transaction(current_txn, header_info, filename)
        if current_txn.get('amount') and _is_valid_amount(current_txn.get('amount')):
            transactions.append(current_txn)

    return transactions


def _is_valid_amount(amount: float) -> bool:
    """Check if amount is within reasonable bounds for a transaction."""
    if amount is None:
        return False
    abs_amount = abs(amount)
    # Reject amounts over 10 million (likely parsing errors like IBANs or balances)
    MAX_REASONABLE_AMOUNT = 10_000_000
    if abs_amount > MAX_REASONABLE_AMOUNT:
        logger.warning(f'Rejecting transaction with unreasonable amount: {amount}')
        return False
    return True


def _finalize_transaction(txn: dict, header_info: dict, filename: str = None):
    """Add header info and extract card/auth details from description."""
    # Add header info
    txn['company_name'] = header_info.get('company_name')
    txn['company_cui'] = header_info.get('company_cui')
    txn['account_number'] = header_info.get('account_number')
    txn['statement_file'] = filename

    desc = txn.get('description', '')

    # Extract card number
    card_match = CARD_PATTERN.search(desc)
    if card_match:
        txn['card_number'] = card_match.group(1)

    # Extract auth code
    auth_match = AUTH_CODE_PATTERN.search(desc)
    if auth_match:
        txn['auth_code'] = auth_match.group(1)

    # Classify transaction type
    txn['transaction_type'] = classify_transaction(desc)


def classify_transaction(description: str) -> str:
    """Classify transaction type based on description."""
    desc_lower = description.lower()

    if 'pos purchase' in desc_lower:
        return 'card_purchase'
    elif '+cms' in desc_lower:
        return 'card_purchase'  # CMS = Card Management System (check before 'fee')
    elif 'alim card' in desc_lower:
        return 'internal'
    elif 'return' in desc_lower or 'deposit' in desc_lower:
        return 'refund'
    elif 'comision' in desc_lower or 'fee' in desc_lower:
        return 'fee'
    else:
        return 'other'


def parse_statement(pdf_bytes: bytes, filename: str = None) -> dict:
    """
    Parse a complete bank statement PDF.

    Args:
        pdf_bytes: Raw PDF file content
        filename: Optional filename for reference

    Returns:
        {
            'company_name': str,
            'company_cui': str,
            'account_number': str,
            'period': {'from': date, 'to': date},
            'transactions': [Transaction],
            'summary': {
                'opening_balance': float,
                'closing_balance': float,
                'credit_count': int,
                'credit_total': float,
                'debit_count': int,
                'debit_total': float
            },
            'filename': str
        }
    """
    # Extract text
    text = extract_text_from_pdf(pdf_bytes)

    # Extract header info
    header = extract_header_info(text)

    # Extract transactions
    transactions = extract_transactions(text, header, filename)

    # Extract summary
    summary = extract_summary(text)

    return {
        'company_name': header.get('company_name'),
        'company_cui': header.get('company_cui'),
        'account_number': header.get('account_number'),
        'period': {
            'from': header.get('period_from'),
            'to': header.get('period_to')
        },
        'transactions': transactions,
        'summary': summary,
        'filename': filename,
        'raw_text': text[:5000]  # First 5000 chars for debugging
    }
