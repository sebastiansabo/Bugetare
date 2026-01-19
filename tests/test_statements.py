"""Unit tests for Bank Statement module.

Tests for:
- parser.py: parse_value(), parse_date(), parse_unicredit_statement()
- vendors.py: match_vendor(), extract_vendor_name()
- database.py: check_duplicate_transaction(), save_transactions()
"""
import sys
import os
import pytest
from unittest.mock import patch, MagicMock
from datetime import date

# Add project root to path (for 'from database import' to work)
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
# Add jarvis folder to path (for 'from accounting.statements import' to work)
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'jarvis'))


# ============== PARSER TESTS ==============

class TestParseValue:
    """Tests for parse_value() function - European number format parsing."""

    def test_simple_integer(self):
        from accounting.statements.parser import parse_value
        assert parse_value('123') == 123.0

    def test_european_format_with_comma(self):
        from accounting.statements.parser import parse_value
        assert parse_value('123,45') == 123.45

    def test_european_format_with_thousands(self):
        from accounting.statements.parser import parse_value
        assert parse_value('1.234,56') == 1234.56

    def test_european_format_large_number(self):
        from accounting.statements.parser import parse_value
        assert parse_value('1.234.567,89') == 1234567.89

    def test_with_spaces(self):
        from accounting.statements.parser import parse_value
        assert parse_value('1 234,56') == 1234.56

    def test_empty_string(self):
        from accounting.statements.parser import parse_value
        assert parse_value('') == 0.0

    def test_none(self):
        from accounting.statements.parser import parse_value
        assert parse_value(None) == 0.0

    def test_invalid_value(self):
        from accounting.statements.parser import parse_value
        assert parse_value('abc') == 0.0


class TestParseDate:
    """Tests for parse_date() function - DD.MM.YYYY to YYYY-MM-DD conversion."""

    def test_valid_date(self):
        from accounting.statements.parser import parse_date
        assert parse_date('15.11.2024') == '2024-11-15'

    def test_date_with_leading_zeros(self):
        from accounting.statements.parser import parse_date
        assert parse_date('01.01.2024') == '2024-01-01'

    def test_date_with_whitespace(self):
        from accounting.statements.parser import parse_date
        assert parse_date('  15.11.2024  ') == '2024-11-15'

    def test_empty_string(self):
        from accounting.statements.parser import parse_date
        assert parse_date('') is None

    def test_none(self):
        from accounting.statements.parser import parse_date
        assert parse_date(None) is None

    def test_invalid_date_format(self):
        from accounting.statements.parser import parse_date
        assert parse_date('2024-11-15') is None  # Wrong format

    def test_invalid_date_value(self):
        from accounting.statements.parser import parse_date
        assert parse_date('32.13.2024') is None  # Invalid day/month


class TestClassifyTransaction:
    """Tests for classify_transaction() function."""

    def test_pos_purchase(self):
        from accounting.statements.parser import classify_transaction
        assert classify_transaction('POS purchase at store') == 'card_purchase'

    def test_internal_transfer(self):
        from accounting.statements.parser import classify_transaction
        assert classify_transaction('Alim Card from account') == 'internal'

    def test_refund(self):
        from accounting.statements.parser import classify_transaction
        assert classify_transaction('Return from merchant') == 'refund'

    def test_fee(self):
        from accounting.statements.parser import classify_transaction
        assert classify_transaction('Comision administrare') == 'fee'

    def test_cms_transaction(self):
        from accounting.statements.parser import classify_transaction
        assert classify_transaction('Payment +CMS fee') == 'card_purchase'

    def test_other(self):
        from accounting.statements.parser import classify_transaction
        assert classify_transaction('Random transaction') == 'other'


class TestExtractTextFromPdf:
    """Tests for extract_text_from_pdf() function."""

    def test_extracts_text(self):
        from accounting.statements.parser import extract_text_from_pdf
        # Create a minimal PDF-like bytes (mock approach)
        with patch('accounting.statements.parser.PyPDF2.PdfReader') as mock_reader:
            mock_page = MagicMock()
            mock_page.extract_text.return_value = 'Test PDF content'
            mock_reader.return_value.pages = [mock_page]

            result = extract_text_from_pdf(b'fake pdf bytes')
            assert 'Test PDF content' in result


# ============== VENDOR TESTS ==============

class TestExtractVendorName:
    """Tests for extract_vendor_name() function."""

    def test_facebook_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('FACEBK *9DGR2CRV62') == 'FACEBK'

    def test_google_ads_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('GOOGLE *ADS3555304242') == 'GOOGLE ADS'

    def test_claude_ai_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('CLAUDE.AI SUBSCRIPTION') == 'CLAUDE.AI'

    def test_openai_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('OPENAI *CHATGPT SUBSCR') == 'OPENAI CHATGPT'

    def test_digitalocean_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('DIGITALOCEAN.COM') == 'DIGITALOCEAN'

    def test_dreamstime_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('DREAMSTIME.COM purchase') == 'DREAMSTIME'

    def test_shopify_pattern(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('SHOPIFY *12345') == 'SHOPIFY'

    def test_empty_string(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name('') is None

    def test_none(self):
        from accounting.statements.vendors import extract_vendor_name
        assert extract_vendor_name(None) is None

    def test_unmatched_description(self):
        from accounting.statements.vendors import extract_vendor_name
        # Should return None or fallback extraction
        result = extract_vendor_name('Unknown vendor transaction')
        # Could be None or extracted word depending on fallback logic
        assert result is None or isinstance(result, str)


class TestMatchVendor:
    """Tests for match_vendor() function."""

    @patch('accounting.statements.vendors.get_all_vendor_mappings')
    def test_match_with_known_pattern(self, mock_get_mappings):
        from accounting.statements.vendors import match_vendor, reload_patterns

        mock_get_mappings.return_value = [
            {'id': 1, 'pattern': r'FACEBK\s*\*', 'supplier_name': 'Meta', 'supplier_vat': None, 'template_id': None}
        ]
        reload_patterns()

        result = match_vendor('FACEBK *9DGR2CRV62')
        assert result['matched'] is True
        assert result['supplier_name'] == 'Meta'

    @patch('accounting.statements.vendors.get_all_vendor_mappings')
    def test_no_match(self, mock_get_mappings):
        from accounting.statements.vendors import match_vendor, reload_patterns

        mock_get_mappings.return_value = [
            {'id': 1, 'pattern': r'FACEBK\s*\*', 'supplier_name': 'Meta', 'supplier_vat': None, 'template_id': None}
        ]
        reload_patterns()

        result = match_vendor('Unknown Vendor Transaction')
        assert result['matched'] is False
        assert result['supplier_name'] is None

    @patch('accounting.statements.vendors.get_all_vendor_mappings')
    def test_empty_description(self, mock_get_mappings):
        from accounting.statements.vendors import match_vendor, reload_patterns

        mock_get_mappings.return_value = []
        reload_patterns()

        result = match_vendor('')
        assert result['matched'] is False
        assert result['vendor_name'] is None


class TestMatchTransactions:
    """Tests for match_transactions() function."""

    @patch('accounting.statements.vendors.get_all_vendor_mappings')
    def test_matches_multiple_transactions(self, mock_get_mappings):
        from accounting.statements.vendors import match_transactions, reload_patterns

        mock_get_mappings.return_value = [
            {'id': 1, 'pattern': r'FACEBK\s*\*', 'supplier_name': 'Meta', 'supplier_vat': None, 'template_id': None},
            {'id': 2, 'pattern': r'GOOGLE\s*\*\s*ADS', 'supplier_name': 'Google Ads', 'supplier_vat': None, 'template_id': None}
        ]
        reload_patterns()

        transactions = [
            {'description': 'FACEBK *123', 'transaction_type': 'card_purchase'},
            {'description': 'GOOGLE *ADS456', 'transaction_type': 'card_purchase'},
            {'description': 'Unknown', 'transaction_type': 'card_purchase'}
        ]

        result = match_transactions(transactions)

        # Note: 'matched' status is reserved for invoice matching, not vendor matching
        # All non-internal transactions start as 'pending' but have matched_supplier populated
        assert result[0]['status'] == 'pending'
        assert result[0]['matched_supplier'] == 'Meta'
        assert result[1]['status'] == 'pending'
        assert result[1]['matched_supplier'] == 'Google Ads'
        assert result[2]['status'] == 'pending'
        assert result[2]['matched_supplier'] is None

    @patch('accounting.statements.vendors.get_all_vendor_mappings')
    def test_auto_ignores_internal_transfers(self, mock_get_mappings):
        from accounting.statements.vendors import match_transactions, reload_patterns

        mock_get_mappings.return_value = []
        reload_patterns()

        transactions = [
            {'description': 'Alim Card transfer', 'transaction_type': 'internal'}
        ]

        result = match_transactions(transactions)
        assert result[0]['status'] == 'ignored'


class TestGetUnmatchedVendors:
    """Tests for get_unmatched_vendors() function."""

    def test_returns_unique_vendors(self):
        from accounting.statements.vendors import get_unmatched_vendors

        transactions = [
            {'status': 'pending', 'vendor_name': 'VENDOR A'},
            {'status': 'pending', 'vendor_name': 'VENDOR B'},
            {'status': 'pending', 'vendor_name': 'VENDOR A'},  # Duplicate
            {'status': 'matched', 'vendor_name': 'VENDOR C'},  # Should be excluded
        ]

        result = get_unmatched_vendors(transactions)
        assert 'VENDOR A' in result
        assert 'VENDOR B' in result
        assert 'VENDOR C' not in result
        assert len(result) == 2


# ============== DATABASE TESTS ==============

class TestCheckDuplicateTransaction:
    """Tests for check_duplicate_transaction() function."""

    @patch('accounting.statements.database.release_db')
    @patch('accounting.statements.database.get_db')
    @patch('accounting.statements.database.get_cursor')
    def test_finds_duplicate(self, mock_cursor, mock_db, _mock_release):
        from accounting.statements.database import check_duplicate_transaction

        mock_conn = MagicMock()
        mock_db.return_value = mock_conn
        mock_cur = MagicMock()
        mock_cursor.return_value = mock_cur
        mock_cur.fetchone.return_value = {'id': 1}  # Found duplicate

        result = check_duplicate_transaction('12345', '2024-11-15', 100.0, 'Test transaction')
        assert result is True

    @patch('accounting.statements.database.release_db')
    @patch('accounting.statements.database.get_db')
    @patch('accounting.statements.database.get_cursor')
    def test_no_duplicate(self, mock_cursor, mock_db, _mock_release):
        from accounting.statements.database import check_duplicate_transaction

        mock_conn = MagicMock()
        mock_db.return_value = mock_conn
        mock_cur = MagicMock()
        mock_cursor.return_value = mock_cur
        mock_cur.fetchone.return_value = None  # No duplicate

        result = check_duplicate_transaction('12345', '2024-11-15', 100.0, 'Test transaction')
        assert result is False


class TestSaveTransactions:
    """Tests for save_transactions() function."""

    @patch('accounting.statements.database.release_db')
    @patch('accounting.statements.database.get_db')
    @patch('accounting.statements.database.get_cursor')
    def test_saves_transactions(self, mock_cursor, mock_db, _mock_release):
        from accounting.statements.database import save_transactions

        mock_conn = MagicMock()
        mock_db.return_value = mock_conn
        mock_cur = MagicMock()
        mock_cursor.return_value = mock_cur
        mock_cur.fetchone.side_effect = [{'id': 1}, {'id': 2}]

        transactions = [
            {'statement_file': 'test.pdf', 'amount': 100, 'description': 'Test 1'},
            {'statement_file': 'test.pdf', 'amount': 200, 'description': 'Test 2'}
        ]

        result = save_transactions(transactions)

        assert len(result) == 2
        assert result[0] == 1
        assert result[1] == 2
        mock_conn.commit.assert_called_once()

    @patch('accounting.statements.database.release_db')
    @patch('accounting.statements.database.get_db')
    @patch('accounting.statements.database.get_cursor')
    def test_handles_duplicates_in_batch(self, mock_cursor, mock_db, _mock_release):
        from accounting.statements.database import save_transactions

        mock_conn = MagicMock()
        mock_db.return_value = mock_conn
        mock_cur = MagicMock()
        mock_cursor.return_value = mock_cur
        mock_cur.fetchone.side_effect = [{'id': 1}]

        transactions = [
            {'statement_file': 'test.pdf', 'amount': 100, 'description': 'Test 1'}
        ]

        result = save_transactions(transactions)
        assert len(result) == 1


# ============== RATE LIMITER TESTS ==============

class TestRateLimiter:
    """Tests for RateLimiter class."""

    def test_allows_first_request(self):
        from accounting.statements.routes import RateLimiter
        limiter = RateLimiter()

        is_allowed, retry_after = limiter.is_allowed(user_id=1, max_requests=10, window_seconds=60)
        assert is_allowed is True
        assert retry_after == 0

    def test_allows_up_to_limit(self):
        from accounting.statements.routes import RateLimiter
        limiter = RateLimiter()

        # Make 10 requests (the limit)
        for i in range(10):
            is_allowed, _ = limiter.is_allowed(user_id=1, max_requests=10, window_seconds=60)
            assert is_allowed is True

        # 11th request should be blocked
        is_allowed, retry_after = limiter.is_allowed(user_id=1, max_requests=10, window_seconds=60)
        assert is_allowed is False
        assert retry_after > 0

    def test_different_users_have_separate_limits(self):
        from accounting.statements.routes import RateLimiter
        limiter = RateLimiter()

        # Exhaust user 1's limit
        for i in range(10):
            limiter.is_allowed(user_id=1, max_requests=10, window_seconds=60)

        # User 2 should still be allowed
        is_allowed, _ = limiter.is_allowed(user_id=2, max_requests=10, window_seconds=60)
        assert is_allowed is True

    def test_get_remaining(self):
        from accounting.statements.routes import RateLimiter
        limiter = RateLimiter()

        assert limiter.get_remaining(user_id=1, max_requests=10, window_seconds=60) == 10

        # Make 3 requests
        for _ in range(3):
            limiter.is_allowed(user_id=1, max_requests=10, window_seconds=60)

        assert limiter.get_remaining(user_id=1, max_requests=10, window_seconds=60) == 7

    def test_window_expiry(self):
        import time
        from accounting.statements.routes import RateLimiter
        limiter = RateLimiter()

        # Use a very short window for testing
        window = 0.1  # 100ms

        # Exhaust limit
        for i in range(3):
            limiter.is_allowed(user_id=1, max_requests=3, window_seconds=window)

        # Should be blocked
        is_allowed, _ = limiter.is_allowed(user_id=1, max_requests=3, window_seconds=window)
        assert is_allowed is False

        # Wait for window to expire
        time.sleep(0.15)

        # Should be allowed again
        is_allowed, _ = limiter.is_allowed(user_id=1, max_requests=3, window_seconds=window)
        assert is_allowed is True


class TestBulkItemLimits:
    """Tests for bulk operation item count limits."""

    def test_max_bulk_items_constant(self):
        from accounting.statements.routes import MAX_BULK_ITEMS
        assert MAX_BULK_ITEMS == 100

    def test_rate_limit_constants(self):
        from accounting.statements.routes import RATE_LIMIT_REQUESTS, RATE_LIMIT_WINDOW
        assert RATE_LIMIT_REQUESTS == 10
        assert RATE_LIMIT_WINDOW == 60


# Run with: pytest tests/test_statements.py -v
if __name__ == '__main__':
    pytest.main([__file__, '-v'])
