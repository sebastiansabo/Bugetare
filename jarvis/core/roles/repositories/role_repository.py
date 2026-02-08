"""Role repository.

Handles all database operations for role management.
"""

import logging
from typing import Optional

from database import get_db, get_cursor, release_db, dict_from_row

logger = logging.getLogger('jarvis.core.roles.role_repository')


class RoleRepository:

    def get_all(self) -> list[dict]:
        """Get all roles."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT * FROM roles ORDER BY name')
            return [dict_from_row(row) for row in cursor.fetchall()]
        finally:
            release_db(conn)

    def get(self, role_id: int) -> Optional[dict]:
        """Get a specific role by ID."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT * FROM roles WHERE id = %s', (role_id,))
            role = cursor.fetchone()
            return dict_from_row(role) if role else None
        finally:
            release_db(conn)

    def save(self, name: str, description: str = None,
             can_add_invoices: bool = False, can_edit_invoices: bool = False,
             can_delete_invoices: bool = False, can_view_invoices: bool = False,
             can_access_accounting: bool = False, can_access_settings: bool = False,
             can_access_connectors: bool = False, can_access_templates: bool = False,
             can_access_hr: bool = False, is_hr_manager: bool = False,
             can_access_efactura: bool = False, can_access_statements: bool = False) -> int:
        """Save a new role. Returns role ID."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO roles (name, description, can_add_invoices, can_edit_invoices, can_delete_invoices,
                    can_view_invoices, can_access_accounting, can_access_settings,
                    can_access_connectors, can_access_templates, can_access_hr, is_hr_manager,
                    can_access_efactura, can_access_statements)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            ''', (
                name, description, can_add_invoices, can_edit_invoices, can_delete_invoices,
                can_view_invoices, can_access_accounting, can_access_settings,
                can_access_connectors, can_access_templates, can_access_hr, is_hr_manager,
                can_access_efactura, can_access_statements
            ))
            role_id = cursor.fetchone()['id']
            conn.commit()
            return role_id
        except Exception as e:
            conn.rollback()
            if 'unique' in str(e).lower() or 'duplicate' in str(e).lower():
                raise ValueError(f"Role '{name}' already exists")
            raise
        finally:
            release_db(conn)

    def update(self, role_id: int, name: str = None, description: str = None,
               can_add_invoices: bool = None, can_edit_invoices: bool = None,
               can_delete_invoices: bool = None, can_view_invoices: bool = None,
               can_access_accounting: bool = None, can_access_settings: bool = None,
               can_access_connectors: bool = None, can_access_templates: bool = None,
               can_access_hr: bool = None, is_hr_manager: bool = None) -> bool:
        """Update a role. Returns True if updated."""
        updates = []
        params = []
        if name is not None:
            updates.append('name = %s')
            params.append(name)
        if description is not None:
            updates.append('description = %s')
            params.append(description)
        if can_add_invoices is not None:
            updates.append('can_add_invoices = %s')
            params.append(can_add_invoices)
        if can_edit_invoices is not None:
            updates.append('can_edit_invoices = %s')
            params.append(can_edit_invoices)
        if can_delete_invoices is not None:
            updates.append('can_delete_invoices = %s')
            params.append(can_delete_invoices)
        if can_view_invoices is not None:
            updates.append('can_view_invoices = %s')
            params.append(can_view_invoices)
        if can_access_accounting is not None:
            updates.append('can_access_accounting = %s')
            params.append(can_access_accounting)
        if can_access_settings is not None:
            updates.append('can_access_settings = %s')
            params.append(can_access_settings)
        if can_access_connectors is not None:
            updates.append('can_access_connectors = %s')
            params.append(can_access_connectors)
        if can_access_templates is not None:
            updates.append('can_access_templates = %s')
            params.append(can_access_templates)
        if can_access_hr is not None:
            updates.append('can_access_hr = %s')
            params.append(can_access_hr)
        if is_hr_manager is not None:
            updates.append('is_hr_manager = %s')
            params.append(is_hr_manager)
        if not updates:
            return False
        params.append(role_id)
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(f"UPDATE roles SET {', '.join(updates)} WHERE id = %s", params)
            updated = cursor.rowcount > 0
            conn.commit()
            return updated
        except Exception as e:
            conn.rollback()
            if 'unique' in str(e).lower() or 'duplicate' in str(e).lower():
                raise ValueError("Role with that name already exists")
            raise
        finally:
            release_db(conn)

    def delete(self, role_id: int) -> bool:
        """Delete a role. Returns False if role is in use by users."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT COUNT(*) as count FROM users WHERE role_id = %s', (role_id,))
            if cursor.fetchone()['count'] > 0:
                raise ValueError("Cannot delete role that is assigned to users")
            cursor.execute('DELETE FROM roles WHERE id = %s', (role_id,))
            deleted = cursor.rowcount > 0
            conn.commit()
            return deleted
        finally:
            release_db(conn)
