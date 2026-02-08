"""Unit tests for main Database module.

Tests for:
- database.py: Utility functions, cache operations
Note: Most database functions require complex mocking due to psycopg2 connection pool.
      These tests focus on testable utility functions and cache operations.
"""
import sys
import os

# Set dummy DATABASE_URL before importing modules that require it
os.environ.setdefault('DATABASE_URL', 'postgresql://test:test@localhost:5432/test')

import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime, date

# Add project root to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'jarvis'))


# ============== DICT FROM ROW TESTS ==============

class TestDictFromRow:
    """Tests for dict_from_row() utility function."""

    def test_converts_date_to_iso(self):
        from database import dict_from_row

        row = {'invoice_date': date(2025, 12, 15), 'supplier': 'Test'}
        result = dict_from_row(row)

        assert result['invoice_date'] == '2025-12-15'
        assert result['supplier'] == 'Test'

    def test_converts_datetime_to_iso(self):
        from database import dict_from_row

        row = {'created_at': datetime(2025, 12, 15, 10, 30, 0)}
        result = dict_from_row(row)

        assert '2025-12-15' in result['created_at']

    def test_preserves_none(self):
        from database import dict_from_row

        row = {'value': None}
        result = dict_from_row(row)

        assert result['value'] is None

    def test_preserves_numbers(self):
        from database import dict_from_row

        row = {'amount': 123.45, 'count': 10}
        result = dict_from_row(row)

        assert result['amount'] == 123.45
        assert result['count'] == 10

    def test_preserves_strings(self):
        from database import dict_from_row

        row = {'name': 'Test', 'description': 'A test row'}
        result = dict_from_row(row)

        assert result['name'] == 'Test'
        assert result['description'] == 'A test row'

    def test_preserves_booleans(self):
        from database import dict_from_row

        row = {'is_active': True, 'is_deleted': False}
        result = dict_from_row(row)

        assert result['is_active'] is True
        assert result['is_deleted'] is False

    def test_handles_empty_dict(self):
        from database import dict_from_row

        row = {}
        result = dict_from_row(row)

        assert result == {}

    def test_handles_mixed_types(self):
        from database import dict_from_row

        row = {
            'id': 1,
            'name': 'Test',
            'created_at': datetime(2025, 12, 15, 10, 30),
            'invoice_date': date(2025, 12, 15),
            'value': 123.45,
            'is_active': True,
            'notes': None
        }
        result = dict_from_row(row)

        assert result['id'] == 1
        assert result['name'] == 'Test'
        assert '2025-12-15' in result['created_at']
        assert result['invoice_date'] == '2025-12-15'
        assert result['value'] == 123.45
        assert result['is_active'] is True
        assert result['notes'] is None


# ============== CACHE TESTS ==============

class TestClearCaches:
    """Tests for cache clearing functions."""

    def test_clear_invoices_cache(self):
        from accounting.invoices.repositories.invoice_repository import clear_invoices_cache
        # Just verify function can be called without error
        clear_invoices_cache()

    def test_clear_templates_cache(self):
        from accounting.templates.repositories.template_repository import clear_templates_cache
        # Just verify function can be called without error
        clear_templates_cache()

    def test_clear_summary_cache(self):
        from accounting.invoices.repositories.summary_repository import clear_summary_cache
        # Just verify function can be called without error
        clear_summary_cache()

    def test_clear_companies_vat_cache(self):
        from core.organization.repositories.company_repository import clear_companies_vat_cache
        # Just verify function can be called without error
        clear_companies_vat_cache()


# ============== PLACEHOLDER TESTS ==============

class TestGetPlaceholder:
    """Tests for get_placeholder() function."""

    def test_returns_correct_placeholder(self):
        from database import get_placeholder
        # PostgreSQL uses %s for placeholders
        assert get_placeholder() == '%s'


# ============== CACHE VALIDITY TESTS ==============

class TestCacheValidity:
    """Tests for cache validity checking."""

    def test_is_cache_valid_with_recent_timestamp(self):
        from core.cache import _is_cache_valid
        import time

        cache_entry = {
            'data': ['test'],
            'timestamp': time.time()
        }
        assert _is_cache_valid(cache_entry) is True

    def test_is_cache_valid_with_old_timestamp(self):
        from core.cache import _is_cache_valid
        import time

        cache_entry = {
            'data': ['test'],
            'timestamp': time.time() - 7200  # 2 hours old
        }
        assert _is_cache_valid(cache_entry) is False

    def test_is_cache_valid_with_no_data(self):
        from core.cache import _is_cache_valid
        import time

        cache_entry = {
            'data': None,
            'timestamp': time.time()
        }
        assert _is_cache_valid(cache_entry) is False

    def test_is_cache_valid_with_zero_timestamp(self):
        from core.cache import _is_cache_valid

        cache_entry = {
            'data': ['test'],
            'timestamp': 0  # Very old timestamp
        }
        assert _is_cache_valid(cache_entry) is False


# ============== GET/SET CACHE DATA TESTS ==============

class TestCacheData:
    """Tests for cache data get/set functions."""

    def test_get_cache_data(self):
        from core.cache import _get_cache_data

        cache_dict = {'data': ['item1', 'item2'], 'timestamp': 123}
        result = _get_cache_data(cache_dict)
        assert result == ['item1', 'item2']

    def test_get_cache_data_with_custom_key(self):
        from core.cache import _get_cache_data

        cache_dict = {'custom': 'value', 'other': 'other'}
        result = _get_cache_data(cache_dict, key='custom')
        assert result == 'value'

    def test_get_cache_data_missing_key(self):
        from core.cache import _get_cache_data

        cache_dict = {'other': 'value'}
        result = _get_cache_data(cache_dict, key='missing')
        assert result is None

    def test_set_cache_data(self):
        from core.cache import _set_cache_data
        import time

        cache_dict = {}
        _set_cache_data(cache_dict, ['new_data'])

        assert cache_dict['data'] == ['new_data']
        assert 'timestamp' in cache_dict
        assert cache_dict['timestamp'] <= time.time()


# ============== TRANSACTION CONTEXT MANAGER TESTS ==============

class TestTransactionContextManager:
    """Tests for transaction context manager."""

    def test_transaction_exists(self):
        from database import transaction
        # Just verify the function exists and is callable
        assert callable(transaction)


# ============== CACHE TTL TESTS ==============

class TestCacheTTL:
    """Tests for cache TTL values in cache dictionaries."""

    def test_templates_cache_has_ttl(self):
        from accounting.templates.repositories.template_repository import _templates_cache
        assert 'ttl' in _templates_cache
        assert _templates_cache['ttl'] > 0

    def test_invoices_cache_has_ttl(self):
        from accounting.invoices.repositories.invoice_repository import _invoices_cache
        assert 'ttl' in _invoices_cache
        assert _invoices_cache['ttl'] > 0

    def test_max_summary_cache_entries_exists(self):
        from core.cache import MAX_SUMMARY_CACHE_ENTRIES
        assert MAX_SUMMARY_CACHE_ENTRIES > 0


# Run with: pytest tests/test_database.py -v
if __name__ == '__main__':
    pytest.main([__file__, '-v'])
