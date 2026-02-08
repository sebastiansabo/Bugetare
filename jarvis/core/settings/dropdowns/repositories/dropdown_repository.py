"""Dropdown options and VAT rates repository.

Handles all database operations for dropdown options and VAT rate management.
"""

import logging
from typing import Optional

from database import get_db, get_cursor, release_db, dict_from_row

logger = logging.getLogger('jarvis.core.settings.dropdowns.repository')


class DropdownRepository:

    # ---- VAT Rates ----

    def get_vat_rates(self, active_only: bool = False) -> list[dict]:
        """Get all VAT rates, optionally filtering for active only."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            if active_only:
                cursor.execute('''
                    SELECT id, name, rate, is_default, is_active, created_at
                    FROM vat_rates WHERE is_active = TRUE ORDER BY rate DESC
                ''')
            else:
                cursor.execute('''
                    SELECT id, name, rate, is_default, is_active, created_at
                    FROM vat_rates ORDER BY rate DESC
                ''')
            return [dict_from_row(row) for row in cursor.fetchall()]
        finally:
            release_db(conn)

    def add_vat_rate(self, name: str, rate: float, is_default: bool = False, is_active: bool = True) -> int:
        """Add a new VAT rate. Returns the new rate ID."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            if is_default:
                cursor.execute('UPDATE vat_rates SET is_default = FALSE WHERE is_default = TRUE')
            cursor.execute('''
                INSERT INTO vat_rates (name, rate, is_default, is_active)
                VALUES (%s, %s, %s, %s) RETURNING id
            ''', (name, rate, is_default, is_active))
            rate_id = cursor.fetchone()['id']
            conn.commit()
            return rate_id
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def update_vat_rate(self, rate_id: int, name: str = None, rate: float = None,
                        is_default: bool = None, is_active: bool = None) -> bool:
        """Update a VAT rate."""
        updates = []
        params = []
        if name is not None:
            updates.append('name = %s')
            params.append(name)
        if rate is not None:
            updates.append('rate = %s')
            params.append(rate)
        if is_default is not None:
            updates.append('is_default = %s')
            params.append(is_default)
        if is_active is not None:
            updates.append('is_active = %s')
            params.append(is_active)
        if not updates:
            return False
        params.append(rate_id)
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            if is_default:
                cursor.execute('UPDATE vat_rates SET is_default = FALSE WHERE is_default = TRUE')
            cursor.execute(f'UPDATE vat_rates SET {", ".join(updates)} WHERE id = %s', params)
            updated = cursor.rowcount > 0
            conn.commit()
            return updated
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def delete_vat_rate(self, rate_id: int) -> bool:
        """Delete a VAT rate."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('DELETE FROM vat_rates WHERE id = %s', (rate_id,))
            deleted = cursor.rowcount > 0
            conn.commit()
            return deleted
        finally:
            release_db(conn)

    # ---- Dropdown Options ----

    def get_options(self, dropdown_type: str = None, active_only: bool = False) -> list[dict]:
        """Get dropdown options, optionally filtered by type and active status."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            query = 'SELECT * FROM dropdown_options WHERE 1=1'
            params = []
            if dropdown_type:
                query += ' AND dropdown_type = %s'
                params.append(dropdown_type)
            if active_only:
                query += ' AND is_active = TRUE'
            query += ' ORDER BY dropdown_type, sort_order, label'
            cursor.execute(query, params)
            return [dict_from_row(row) for row in cursor.fetchall()]
        finally:
            release_db(conn)

    def get_option(self, option_id: int) -> Optional[dict]:
        """Get a specific dropdown option by ID."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT * FROM dropdown_options WHERE id = %s', (option_id,))
            result = cursor.fetchone()
            return dict_from_row(result) if result else None
        finally:
            release_db(conn)

    def add_option(self, dropdown_type: str, value: str, label: str,
                   color: str = None, opacity: float = 0.7, sort_order: int = 0,
                   is_active: bool = True, notify_on_status: bool = False) -> int:
        """Add a new dropdown option. Returns the new option ID."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO dropdown_options (dropdown_type, value, label, color, opacity, sort_order, is_active, notify_on_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            ''', (dropdown_type, value, label, color, opacity, sort_order, is_active, notify_on_status))
            option_id = cursor.fetchone()['id']
            conn.commit()
            return option_id
        finally:
            release_db(conn)

    def update_option(self, option_id: int, value: str = None, label: str = None,
                      color: str = None, opacity: float = None, sort_order: int = None,
                      is_active: bool = None, notify_on_status: bool = None) -> bool:
        """Update a dropdown option. Returns True if updated."""
        updates = []
        params = []
        if value is not None:
            updates.append('value = %s')
            params.append(value)
        if label is not None:
            updates.append('label = %s')
            params.append(label)
        if color is not None:
            updates.append('color = %s')
            params.append(color)
        if opacity is not None:
            updates.append('opacity = %s')
            params.append(opacity)
        if sort_order is not None:
            updates.append('sort_order = %s')
            params.append(sort_order)
        if is_active is not None:
            updates.append('is_active = %s')
            params.append(is_active)
        if notify_on_status is not None:
            updates.append('notify_on_status = %s')
            params.append(notify_on_status)
        if not updates:
            return False
        params.append(option_id)
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(f"UPDATE dropdown_options SET {', '.join(updates)} WHERE id = %s", params)
            updated = cursor.rowcount > 0
            conn.commit()
            return updated
        finally:
            release_db(conn)

    def delete_option(self, option_id: int) -> bool:
        """Delete a dropdown option."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('DELETE FROM dropdown_options WHERE id = %s', (option_id,))
            deleted = cursor.rowcount > 0
            conn.commit()
            return deleted
        finally:
            release_db(conn)

    def should_notify_on_status(self, status_value: str, dropdown_type: str = 'invoice_status') -> bool:
        """Check if a status value should trigger notifications."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT notify_on_status FROM dropdown_options
                WHERE dropdown_type = %s AND value = %s AND is_active = TRUE
            ''', (dropdown_type, status_value))
            result = cursor.fetchone()
            return result['notify_on_status'] if result and result['notify_on_status'] else False
        finally:
            release_db(conn)
