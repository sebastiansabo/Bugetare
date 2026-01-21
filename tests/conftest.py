"""Pytest configuration and fixtures for all tests.

This file is loaded BEFORE any test modules are imported, allowing us to mock
the database connection pool that gets initialized at import time in database.py.
"""
import sys
import os
from unittest.mock import MagicMock, patch

# Set dummy DATABASE_URL before any imports
os.environ['DATABASE_URL'] = 'postgresql://test:test@localhost:5432/test'

# Create mock for psycopg2.pool.ThreadedConnectionPool BEFORE importing any app modules
mock_pool = MagicMock()
mock_conn = MagicMock()
mock_cursor = MagicMock()

# Setup mock chain
mock_conn.cursor.return_value.__enter__ = MagicMock(return_value=mock_cursor)
mock_conn.cursor.return_value.__exit__ = MagicMock(return_value=False)
mock_pool.getconn.return_value = mock_conn

# Patch psycopg2 before it's imported by database.py
sys.modules['psycopg2'] = MagicMock()
sys.modules['psycopg2.pool'] = MagicMock()
sys.modules['psycopg2.pool'].ThreadedConnectionPool = MagicMock(return_value=mock_pool)
sys.modules['psycopg2.extras'] = MagicMock()
sys.modules['psycopg2.errors'] = MagicMock()
# Add UniqueViolation exception class for error handling tests
sys.modules['psycopg2.errors'].UniqueViolation = type('UniqueViolation', (Exception,), {})

# Add project root to path
project_root = os.path.join(os.path.dirname(__file__), '..')
sys.path.insert(0, project_root)
sys.path.insert(0, os.path.join(project_root, 'jarvis'))

import pytest


@pytest.fixture
def mock_db_connection():
    """Provides a mock database connection for tests."""
    conn = MagicMock()
    cursor = MagicMock()
    conn.cursor.return_value.__enter__ = MagicMock(return_value=cursor)
    conn.cursor.return_value.__exit__ = MagicMock(return_value=False)
    return conn, cursor


@pytest.fixture
def mock_drive_service():
    """Provides a mock Google Drive service for tests."""
    service = MagicMock()
    return service


@pytest.fixture
def sample_invoice_data():
    """Sample invoice data for testing."""
    return {
        'supplier': 'Test Supplier SRL',
        'supplier_vat': 'RO12345678',
        'customer_vat': 'RO50186814',
        'invoice_number': 'INV-2025-001',
        'invoice_date': '2025-12-15',
        'invoice_value': 1000.00,
        'currency': 'RON',
        'value_ron': 1000.00,
        'value_eur': 201.21,
        'exchange_rate': 4.97,
        'payment_status': 'unpaid',
        'drive_link': 'https://drive.google.com/file/d/abc123/view'
    }


@pytest.fixture
def sample_allocation_data():
    """Sample allocation data for testing."""
    return {
        'company': 'DWA',
        'brand': 'BT',
        'department': 'Marketing',
        'subdepartment': 'Digital',
        'allocation_percent': 100.0,
        'allocation_value': 1000.00,
        'responsible': 'John Doe',
        'is_locked': False
    }


@pytest.fixture
def sample_employee_data():
    """Sample HR employee data for testing."""
    return {
        'name': 'Test Employee',
        'company': 'DWA',
        'brand': 'BT',
        'department': 'Marketing',
        'is_active': True
    }


@pytest.fixture
def sample_event_data():
    """Sample HR event data for testing."""
    return {
        'name': 'Company Retreat 2025',
        'start_date': '2025-06-01',
        'end_date': '2025-06-03',
        'company': 'DWA',
        'brand': None,
        'description': 'Annual company retreat'
    }


@pytest.fixture
def sample_bonus_data():
    """Sample HR bonus data for testing."""
    return {
        'employee_id': 1,
        'event_id': 1,
        'year': 2025,
        'month': 6,
        'participation_start': '2025-06-01',
        'participation_end': '2025-06-03',
        'bonus_days': 3,
        'hours_free': 0,
        'bonus_net': 500.00,
        'details': 'Full participation',
        'allocation_month': '2025-07'
    }


@pytest.fixture
def sample_bank_transaction():
    """Sample bank statement transaction for testing."""
    return {
        'statement_id': 1,
        'transaction_date': '2025-12-01',
        'description': 'FACEBK *ADS Payment',
        'amount': -150.00,
        'currency': 'RON',
        'card_number': '1234',
        'status': 'pending'
    }


@pytest.fixture
def sample_vendor_mapping():
    """Sample vendor mapping for testing."""
    return {
        'pattern': r'FACEBK\s*\*',
        'supplier_name': 'Meta',
        'supplier_vat': 'IE9692928F',
        'category': 'advertising'
    }
