"""Theme settings repository.

Handles all database operations for theme management.
"""

import json
import logging
from typing import Optional

from database import get_db, get_cursor, release_db

logger = logging.getLogger('jarvis.core.settings.themes.repository')


class ThemeRepository:

    def _row_to_dict(self, row) -> dict:
        """Convert a theme row to a dictionary."""
        return {
            'id': row['id'],
            'theme_name': row['theme_name'],
            'settings': row['settings'] if isinstance(row['settings'], dict) else json.loads(row['settings'] or '{}'),
            'is_active': row['is_active'],
            'created_at': row['created_at'].isoformat() if row['created_at'] else None,
            'updated_at': row['updated_at'].isoformat() if row['updated_at'] else None
        }

    def get_active(self) -> Optional[dict]:
        """Get the active theme settings."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT id, theme_name, settings, is_active, created_at, updated_at
                FROM theme_settings
                WHERE is_active = TRUE
                ORDER BY id
                LIMIT 1
            ''')
            row = cursor.fetchone()
            return self._row_to_dict(row) if row else None
        finally:
            release_db(conn)

    def get_all(self) -> list:
        """Get all themes."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT id, theme_name, settings, is_active, created_at, updated_at
                FROM theme_settings
                ORDER BY is_active DESC, theme_name
            ''')
            return [self._row_to_dict(row) for row in cursor.fetchall()]
        finally:
            release_db(conn)

    def get_by_id(self, theme_id: int) -> Optional[dict]:
        """Get a theme by ID."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT id, theme_name, settings, is_active, created_at, updated_at
                FROM theme_settings
                WHERE id = %s
            ''', (theme_id,))
            row = cursor.fetchone()
            return self._row_to_dict(row) if row else None
        finally:
            release_db(conn)

    def save(self, theme_id: Optional[int], theme_name: str, settings: dict, is_active: Optional[bool] = None) -> Optional[dict]:
        """Save or update a theme. If is_active=True, deactivate other themes."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            settings_json = json.dumps(settings)

            if theme_id:
                if is_active:
                    cursor.execute('UPDATE theme_settings SET is_active = FALSE WHERE id != %s', (theme_id,))
                cursor.execute('''
                    UPDATE theme_settings
                    SET theme_name = %s, settings = %s, is_active = COALESCE(%s, is_active), updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                    RETURNING id
                ''', (theme_name, settings_json, is_active, theme_id))
            else:
                if is_active:
                    cursor.execute('UPDATE theme_settings SET is_active = FALSE')
                cursor.execute('''
                    INSERT INTO theme_settings (theme_name, settings, is_active)
                    VALUES (%s, %s, %s)
                    RETURNING id
                ''', (theme_name, settings_json, is_active or False))

            result = cursor.fetchone()
            conn.commit()
            return self.get_by_id(result['id']) if result else None
        finally:
            release_db(conn)

    def delete(self, theme_id: int) -> bool:
        """Delete a theme. Cannot delete if it's the only theme or if it's active."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)

            cursor.execute('SELECT COUNT(*) as cnt FROM theme_settings')
            if cursor.fetchone()['cnt'] <= 1:
                return False

            cursor.execute('SELECT is_active FROM theme_settings WHERE id = %s', (theme_id,))
            row = cursor.fetchone()
            if row and row['is_active']:
                return False

            cursor.execute('DELETE FROM theme_settings WHERE id = %s', (theme_id,))
            conn.commit()
            return True
        finally:
            release_db(conn)

    def activate(self, theme_id: int) -> bool:
        """Activate a theme and deactivate all others."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('UPDATE theme_settings SET is_active = FALSE')
            cursor.execute('UPDATE theme_settings SET is_active = TRUE, updated_at = CURRENT_TIMESTAMP WHERE id = %s', (theme_id,))
            conn.commit()
            return True
        finally:
            release_db(conn)
