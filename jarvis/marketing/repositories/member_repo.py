"""Repository for mkt_project_members table."""

import logging
from database import get_db, get_cursor, release_db

logger = logging.getLogger('jarvis.marketing.member_repo')


class MemberRepository:

    def get_by_project(self, project_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT m.*, u.name as user_name, u.email as user_email,
                       u2.name as added_by_name
                FROM mkt_project_members m
                JOIN users u ON u.id = m.user_id
                JOIN users u2 ON u2.id = m.added_by
                WHERE m.project_id = %s
                ORDER BY m.created_at
            ''', (project_id,))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def add(self, project_id, user_id, role, added_by, department_structure_id=None):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_project_members (project_id, user_id, role, added_by, department_structure_id)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (project_id, user_id) DO UPDATE SET role = EXCLUDED.role
                RETURNING id
            ''', (project_id, user_id, role, added_by, department_structure_id))
            member_id = cursor.fetchone()['id']
            conn.commit()
            return member_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def update_role(self, member_id, role):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(
                'UPDATE mkt_project_members SET role = %s WHERE id = %s',
                (role, member_id)
            )
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def remove(self, member_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('DELETE FROM mkt_project_members WHERE id = %s', (member_id,))
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def get_user_ids_for_project(self, project_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(
                'SELECT user_id FROM mkt_project_members WHERE project_id = %s',
                (project_id,)
            )
            return [r['user_id'] for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def get_stakeholder_ids(self, project_id):
        """Get user IDs of all stakeholders for a project."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(
                'SELECT user_id FROM mkt_project_members WHERE project_id = %s AND role = %s',
                (project_id, 'stakeholder')
            )
            return [r['user_id'] for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def is_member(self, project_id, user_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute(
                'SELECT 1 FROM mkt_project_members WHERE project_id = %s AND user_id = %s',
                (project_id, user_id)
            )
            return cursor.fetchone() is not None
        finally:
            release_db(conn)
