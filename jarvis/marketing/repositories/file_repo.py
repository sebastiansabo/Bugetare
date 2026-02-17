"""Repository for mkt_project_files table."""

import logging
from database import get_db, get_cursor, release_db

logger = logging.getLogger('jarvis.marketing.file_repo')


class FileRepository:

    def get_by_project(self, project_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT f.*, u.name as uploaded_by_name
                FROM mkt_project_files f
                JOIN users u ON u.id = f.uploaded_by
                WHERE f.project_id = %s
                ORDER BY f.created_at DESC
            ''', (project_id,))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def create(self, project_id, file_name, storage_uri, uploaded_by, **kwargs):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_project_files
                    (project_id, file_name, file_type, mime_type, file_size, storage_uri, uploaded_by, description)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            ''', (
                project_id, file_name,
                kwargs.get('file_type'), kwargs.get('mime_type'),
                kwargs.get('file_size'), storage_uri, uploaded_by,
                kwargs.get('description'),
            ))
            file_id = cursor.fetchone()['id']
            conn.commit()
            return file_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def delete(self, file_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('DELETE FROM mkt_project_files WHERE id = %s', (file_id,))
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)
