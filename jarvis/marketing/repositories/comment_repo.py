"""Repository for mkt_project_comments table."""

import logging
from database import get_db, get_cursor, release_db

logger = logging.getLogger('jarvis.marketing.comment_repo')


class CommentRepository:

    def get_by_project(self, project_id, include_internal=False):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            internal_filter = '' if include_internal else 'AND c.is_internal = FALSE'
            cursor.execute(f'''
                SELECT c.*, u.name as user_name, u.email as user_email
                FROM mkt_project_comments c
                JOIN users u ON u.id = c.user_id
                WHERE c.project_id = %s AND c.deleted_at IS NULL {internal_filter}
                ORDER BY c.created_at ASC
            ''', (project_id,))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def create(self, project_id, user_id, content, parent_id=None, is_internal=False):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_project_comments (project_id, user_id, content, parent_id, is_internal)
                VALUES (%s, %s, %s, %s, %s) RETURNING id
            ''', (project_id, user_id, content, parent_id, is_internal))
            comment_id = cursor.fetchone()['id']
            conn.commit()
            return comment_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def update(self, comment_id, content):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(
                'UPDATE mkt_project_comments SET content = %s, updated_at = NOW() WHERE id = %s AND deleted_at IS NULL',
                (content, comment_id)
            )
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def soft_delete(self, comment_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(
                'UPDATE mkt_project_comments SET deleted_at = NOW() WHERE id = %s',
                (comment_id,)
            )
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)
