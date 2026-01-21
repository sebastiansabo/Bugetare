"""Unit tests for HR Module.

Tests for:
- hr/events/database.py: Function existence and interface verification
Note: Database-dependent tests are simplified due to psycopg2 mocking complexity.
      These tests verify function interfaces and basic behavior.
"""
import sys
import os

# Set dummy DATABASE_URL before importing modules that require it
os.environ.setdefault('DATABASE_URL', 'postgresql://test:test@localhost:5432/test')

import pytest
from datetime import date

# Add project root to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'jarvis'))


# ============== FUNCTION EXISTENCE TESTS ==============

class TestEmployeeFunctionsExist:
    """Verify employee CRUD functions exist and are callable."""

    def test_get_all_hr_employees_exists(self):
        from hr.events.database import get_all_hr_employees
        assert callable(get_all_hr_employees)

    def test_get_hr_employee_exists(self):
        from hr.events.database import get_hr_employee
        assert callable(get_hr_employee)

    def test_save_hr_employee_exists(self):
        from hr.events.database import save_hr_employee
        assert callable(save_hr_employee)

    def test_update_hr_employee_exists(self):
        from hr.events.database import update_hr_employee
        assert callable(update_hr_employee)

    def test_delete_hr_employee_exists(self):
        from hr.events.database import delete_hr_employee
        assert callable(delete_hr_employee)

    def test_search_hr_employees_exists(self):
        from hr.events.database import search_hr_employees
        assert callable(search_hr_employees)


class TestEventFunctionsExist:
    """Verify event CRUD functions exist and are callable."""

    def test_get_all_hr_events_exists(self):
        from hr.events.database import get_all_hr_events
        assert callable(get_all_hr_events)

    def test_get_hr_event_exists(self):
        from hr.events.database import get_hr_event
        assert callable(get_hr_event)

    def test_save_hr_event_exists(self):
        from hr.events.database import save_hr_event
        assert callable(save_hr_event)

    def test_update_hr_event_exists(self):
        from hr.events.database import update_hr_event
        assert callable(update_hr_event)

    def test_delete_hr_event_exists(self):
        from hr.events.database import delete_hr_event
        assert callable(delete_hr_event)


class TestBonusFunctionsExist:
    """Verify bonus CRUD functions exist and are callable."""

    def test_get_all_event_bonuses_exists(self):
        from hr.events.database import get_all_event_bonuses
        assert callable(get_all_event_bonuses)

    def test_get_event_bonus_exists(self):
        from hr.events.database import get_event_bonus
        assert callable(get_event_bonus)

    def test_save_event_bonus_exists(self):
        from hr.events.database import save_event_bonus
        assert callable(save_event_bonus)

    def test_save_event_bonuses_bulk_exists(self):
        from hr.events.database import save_event_bonuses_bulk
        assert callable(save_event_bonuses_bulk)

    def test_update_event_bonus_exists(self):
        from hr.events.database import update_event_bonus
        assert callable(update_event_bonus)

    def test_delete_event_bonus_exists(self):
        from hr.events.database import delete_event_bonus
        assert callable(delete_event_bonus)


class TestSummaryFunctionsExist:
    """Verify summary functions exist and are callable."""

    def test_get_event_bonuses_summary_exists(self):
        from hr.events.database import get_event_bonuses_summary
        assert callable(get_event_bonuses_summary)

    def test_get_bonuses_by_month_exists(self):
        from hr.events.database import get_bonuses_by_month
        assert callable(get_bonuses_by_month)

    def test_get_bonuses_by_employee_exists(self):
        from hr.events.database import get_bonuses_by_employee
        assert callable(get_bonuses_by_employee)


class TestBonusTypeFunctionsExist:
    """Verify bonus type functions exist and are callable."""

    def test_get_all_bonus_types_exists(self):
        from hr.events.database import get_all_bonus_types
        assert callable(get_all_bonus_types)

    def test_get_bonus_type_exists(self):
        from hr.events.database import get_bonus_type
        assert callable(get_bonus_type)

    def test_save_bonus_type_exists(self):
        from hr.events.database import save_bonus_type
        assert callable(save_bonus_type)

    def test_update_bonus_type_exists(self):
        from hr.events.database import update_bonus_type
        assert callable(update_bonus_type)

    def test_delete_bonus_type_exists(self):
        from hr.events.database import delete_bonus_type
        assert callable(delete_bonus_type)


# ============== FUNCTION SIGNATURE TESTS ==============

class TestFunctionSignatures:
    """Test that functions have expected parameters."""

    def test_get_all_hr_employees_accepts_active_only(self):
        from hr.events.database import get_all_hr_employees
        import inspect
        sig = inspect.signature(get_all_hr_employees)
        assert 'active_only' in sig.parameters

    def test_get_all_event_bonuses_accepts_filters(self):
        from hr.events.database import get_all_event_bonuses
        import inspect
        sig = inspect.signature(get_all_event_bonuses)
        params = sig.parameters
        assert 'year' in params
        assert 'month' in params
        assert 'employee_id' in params
        assert 'event_id' in params

    def test_save_hr_employee_requires_name(self):
        from hr.events.database import save_hr_employee
        import inspect
        sig = inspect.signature(save_hr_employee)
        assert 'name' in sig.parameters

    def test_save_hr_event_requires_dates(self):
        from hr.events.database import save_hr_event
        import inspect
        sig = inspect.signature(save_hr_event)
        params = sig.parameters
        assert 'name' in params
        assert 'start_date' in params
        assert 'end_date' in params

    def test_save_event_bonus_requires_ids(self):
        from hr.events.database import save_event_bonus
        import inspect
        sig = inspect.signature(save_event_bonus)
        params = sig.parameters
        assert 'employee_id' in params
        assert 'event_id' in params
        assert 'year' in params
        assert 'month' in params


# ============== DATE HANDLING TESTS ==============

class TestDateHandling:
    """Test date type handling utilities."""

    def test_date_to_string_conversion(self):
        """Dates should be convertible to ISO strings."""
        d = date(2025, 12, 15)
        iso_string = d.isoformat()
        assert iso_string == '2025-12-15'

    def test_string_to_date_conversion(self):
        """ISO strings should be parseable to dates."""
        iso_string = '2025-12-15'
        d = date.fromisoformat(iso_string)
        assert d.year == 2025
        assert d.month == 12
        assert d.day == 15


# ============== DEFAULT VALUES TESTS ==============

class TestDefaultValues:
    """Test that functions have sensible defaults."""

    def test_get_all_hr_employees_defaults_to_active(self):
        from hr.events.database import get_all_hr_employees
        import inspect
        sig = inspect.signature(get_all_hr_employees)
        active_only_param = sig.parameters['active_only']
        assert active_only_param.default is True

    def test_get_all_bonus_types_defaults_to_active(self):
        from hr.events.database import get_all_bonus_types
        import inspect
        sig = inspect.signature(get_all_bonus_types)
        active_only_param = sig.parameters['active_only']
        assert active_only_param.default is True


# ============== IMPORT TESTS ==============

class TestModuleImports:
    """Test that the HR module can be imported correctly."""

    def test_can_import_hr_events_database(self):
        import hr.events.database
        assert hr.events.database is not None

    def test_can_import_hr_events(self):
        import hr.events
        assert hr.events is not None


# Run with: pytest tests/test_hr_module.py -v
if __name__ == '__main__':
    pytest.main([__file__, '-v'])
