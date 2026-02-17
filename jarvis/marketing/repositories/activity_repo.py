"""Repository for mkt_project_activity table."""

import json
import logging
from database import get_db, get_cursor, release_db

logger = logging.getLogger('jarvis.marketing.activity_repo')


class ActivityRepository:

    def get_by_project(self, project_id, limit=50, offset=0):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT a.*, u.name as actor_name
                FROM mkt_project_activity a
                LEFT JOIN users u ON u.id = a.actor_id
                WHERE a.project_id = %s
                ORDER BY a.created_at DESC
                LIMIT %s OFFSET %s
            ''', (project_id, limit, offset))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def log(self, project_id, action, actor_id=None, actor_type='user', details=None):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_project_activity (project_id, action, actor_id, actor_type, details)
                VALUES (%s, %s, %s, %s, %s) RETURNING id
            ''', (project_id, action, actor_id, actor_type, json.dumps(details or {})))
            activity_id = cursor.fetchone()['id']
            conn.commit()
            return activity_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)
