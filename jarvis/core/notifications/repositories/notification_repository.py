"""Notification repository.

Handles all database operations for notification settings, logs, and user notifications.
"""

import logging
from typing import Optional

from database import get_db, get_cursor, release_db, dict_from_row

logger = logging.getLogger('jarvis.core.notifications.repository')


class NotificationRepository:

    # ---- Notification Settings ----

    def get_settings(self) -> dict:
        """Get all notification settings as a dictionary."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT setting_key, setting_value FROM notification_settings')
            rows = cursor.fetchall()
            return {row['setting_key']: row['setting_value'] for row in rows}
        finally:
            release_db(conn)

    def save_setting(self, key: str, value: str) -> bool:
        """Save or update a notification setting."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO notification_settings (setting_key, setting_value)
                VALUES (%s, %s)
                ON CONFLICT (setting_key)
                DO UPDATE SET setting_value = %s, updated_at = CURRENT_TIMESTAMP
            ''', (key, value, value))
            conn.commit()
            return True
        finally:
            release_db(conn)

    def save_settings_bulk(self, settings: dict) -> bool:
        """Save multiple notification settings at once."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            for key, value in settings.items():
                cursor.execute('''
                    INSERT INTO notification_settings (setting_key, setting_value)
                    VALUES (%s, %s)
                    ON CONFLICT (setting_key)
                    DO UPDATE SET setting_value = %s, updated_at = CURRENT_TIMESTAMP
                ''', (key, value, value))
            conn.commit()
            return True
        finally:
            release_db(conn)

    # ---- Notification Logs ----

    def log_notification(self, responsable_id: int, invoice_id: int, notification_type: str,
                         subject: str, message: str, status: str = 'pending') -> int:
        """Log a notification."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO notification_log (responsable_id, invoice_id, notification_type, subject, message, status)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
            ''', (responsable_id, invoice_id, notification_type, subject, message, status))
            log_id = cursor.fetchone()['id']
            conn.commit()
            return log_id
        finally:
            release_db(conn)

    def update_status(self, log_id: int, status: str, error_message: str = None) -> bool:
        """Update notification log status."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            if status == 'sent':
                cursor.execute('''
                    UPDATE notification_log
                    SET status = %s, sent_at = CURRENT_TIMESTAMP, error_message = %s
                    WHERE id = %s
                ''', (status, error_message, log_id))
            else:
                cursor.execute('''
                    UPDATE notification_log
                    SET status = %s, error_message = %s
                    WHERE id = %s
                ''', (status, error_message, log_id))
            updated = cursor.rowcount > 0
            conn.commit()
            return updated
        finally:
            release_db(conn)

    def get_logs(self, limit: int = 100) -> list[dict]:
        """Get recent notification logs."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT nl.*, u.name as responsable_name, u.email as responsable_email,
                       i.invoice_number, i.supplier
                FROM notification_log nl
                LEFT JOIN users u ON nl.responsable_id = u.id
                LEFT JOIN invoices i ON nl.invoice_id = i.id
                ORDER BY nl.created_at DESC
                LIMIT %s
            ''', (limit,))
            return [dict_from_row(row) for row in cursor.fetchall()]
        finally:
            release_db(conn)

    # ---- User Notifications ----

    def get_user_notifications(self, user_id: int, limit: int = 20, offset: int = 0) -> list[dict]:
        """Get notifications sent to a user."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT email FROM users WHERE id = %s', (user_id,))
            user_row = cursor.fetchone()
            if not user_row or not user_row['email']:
                return []
            cursor.execute('''
                SELECT id, event_type, invoice_id, recipient_email, status,
                       error_message, created_at
                FROM notification_logs
                WHERE LOWER(recipient_email) = LOWER(%s)
                ORDER BY created_at DESC
                LIMIT %s OFFSET %s
            ''', (user_row['email'], limit, offset))
            return [dict_from_row(dict(row)) for row in cursor.fetchall()]
        finally:
            release_db(conn)

    def get_user_notifications_summary(self, user_id: int) -> dict:
        """Get notification summary for a user."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('SELECT email FROM users WHERE id = %s', (user_id,))
            user_row = cursor.fetchone()
            if not user_row or not user_row['email']:
                return {'total': 0, 'sent': 0, 'failed': 0}
            cursor.execute('''
                SELECT
                    COUNT(*) as total,
                    COUNT(*) FILTER (WHERE status = 'sent') as sent,
                    COUNT(*) FILTER (WHERE status = 'failed') as failed
                FROM notification_logs
                WHERE LOWER(recipient_email) = LOWER(%s)
            ''', (user_row['email'],))
            row = cursor.fetchone()
            if row:
                return {
                    'total': row['total'],
                    'sent': row['sent'],
                    'failed': row['failed'],
                }
            return {'total': 0, 'sent': 0, 'failed': 0}
        finally:
            release_db(conn)
