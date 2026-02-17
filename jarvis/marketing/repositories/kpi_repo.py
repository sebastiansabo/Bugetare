"""Repository for mkt_kpi_definitions, mkt_project_kpis, mkt_kpi_snapshots."""

import logging
from database import get_db, get_cursor, release_db

logger = logging.getLogger('jarvis.marketing.kpi_repo')


class KpiRepository:

    # ---- KPI Definitions (admin catalog) ----

    def get_definitions(self, active_only=True):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            where = 'WHERE is_active = TRUE' if active_only else ''
            cursor.execute(f'SELECT * FROM mkt_kpi_definitions {where} ORDER BY sort_order')
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def create_definition(self, name, slug, unit='number', direction='higher',
                          category='performance', formula=None, description=None):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_kpi_definitions (name, slug, unit, direction, category, formula, description)
                VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id
            ''', (name, slug, unit, direction, category, formula, description))
            def_id = cursor.fetchone()['id']
            conn.commit()
            return def_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def update_definition(self, def_id, **kwargs):
        allowed = {'name', 'slug', 'unit', 'direction', 'category', 'formula', 'description', 'is_active', 'sort_order'}
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            updates = []
            params = []
            for key, val in kwargs.items():
                if key in allowed and val is not None:
                    updates.append(f'{key} = %s')
                    params.append(val)
            if not updates:
                return False
            params.append(def_id)
            cursor.execute(f'UPDATE mkt_kpi_definitions SET {", ".join(updates)} WHERE id = %s', params)
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    # ---- Project KPIs ----

    def get_by_project(self, project_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT pk.*, kd.name as kpi_name, kd.slug as kpi_slug,
                       kd.unit, kd.direction, kd.category, kd.formula
                FROM mkt_project_kpis pk
                JOIN mkt_kpi_definitions kd ON kd.id = pk.kpi_definition_id
                WHERE pk.project_id = %s
                ORDER BY kd.sort_order
            ''', (project_id,))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def add_project_kpi(self, project_id, kpi_definition_id, **kwargs):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_project_kpis
                    (project_id, kpi_definition_id, channel, target_value, weight,
                     threshold_warning, threshold_critical, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            ''', (
                project_id, kpi_definition_id,
                kwargs.get('channel'), kwargs.get('target_value'),
                kwargs.get('weight', 50),
                kwargs.get('threshold_warning'), kwargs.get('threshold_critical'),
                kwargs.get('notes'),
            ))
            kpi_id = cursor.fetchone()['id']
            conn.commit()
            return kpi_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def update_project_kpi(self, kpi_id, **kwargs):
        allowed = {'target_value', 'current_value', 'weight', 'threshold_warning',
                    'threshold_critical', 'status', 'notes', 'channel'}
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            updates = []
            params = []
            for key, val in kwargs.items():
                if key in allowed:
                    updates.append(f'{key} = %s')
                    params.append(val)
            if not updates:
                return False
            updates.append('updated_at = NOW()')
            params.append(kpi_id)
            cursor.execute(f'UPDATE mkt_project_kpis SET {", ".join(updates)} WHERE id = %s', params)
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def delete_project_kpi(self, kpi_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('DELETE FROM mkt_project_kpis WHERE id = %s', (kpi_id,))
            conn.commit()
            return cursor.rowcount > 0
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    # ---- KPI ↔ Budget Line linking ----

    def get_kpi_budget_lines(self, project_kpi_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT kb.id, kb.project_kpi_id, kb.budget_line_id, kb.created_at,
                       bl.channel, bl.description, bl.planned_amount,
                       bl.spent_amount, bl.currency
                FROM mkt_kpi_budget_lines kb
                JOIN mkt_budget_lines bl ON bl.id = kb.budget_line_id
                WHERE kb.project_kpi_id = %s
                ORDER BY bl.channel
            ''', (project_kpi_id,))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def link_budget_line(self, project_kpi_id, budget_line_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_kpi_budget_lines (project_kpi_id, budget_line_id)
                VALUES (%s, %s)
                ON CONFLICT (project_kpi_id, budget_line_id) DO NOTHING
                RETURNING id
            ''', (project_kpi_id, budget_line_id))
            row = cursor.fetchone()
            conn.commit()
            return row['id'] if row else None
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def unlink_budget_line(self, project_kpi_id, budget_line_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                DELETE FROM mkt_kpi_budget_lines
                WHERE project_kpi_id = %s AND budget_line_id = %s
            ''', (project_kpi_id, budget_line_id))
            conn.commit()
            return cursor.rowcount > 0
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    # ---- KPI ↔ KPI dependencies ----

    def get_kpi_dependencies(self, project_kpi_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT kd.id, kd.project_kpi_id, kd.depends_on_kpi_id, kd.role, kd.created_at,
                       pk.current_value as dep_current_value,
                       kdef.name as dep_kpi_name, kdef.slug as dep_kpi_slug,
                       kdef.unit as dep_unit
                FROM mkt_kpi_dependencies kd
                JOIN mkt_project_kpis pk ON pk.id = kd.depends_on_kpi_id
                JOIN mkt_kpi_definitions kdef ON kdef.id = pk.kpi_definition_id
                WHERE kd.project_kpi_id = %s
                ORDER BY kd.role, kdef.name
            ''', (project_kpi_id,))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def link_kpi_dependency(self, project_kpi_id, depends_on_kpi_id, role='input'):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_kpi_dependencies (project_kpi_id, depends_on_kpi_id, role)
                VALUES (%s, %s, %s)
                ON CONFLICT (project_kpi_id, depends_on_kpi_id) DO UPDATE SET role = EXCLUDED.role
                RETURNING id
            ''', (project_kpi_id, depends_on_kpi_id, role))
            row = cursor.fetchone()
            conn.commit()
            return row['id'] if row else None
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    def unlink_kpi_dependency(self, project_kpi_id, depends_on_kpi_id):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                DELETE FROM mkt_kpi_dependencies
                WHERE project_kpi_id = %s AND depends_on_kpi_id = %s
            ''', (project_kpi_id, depends_on_kpi_id))
            conn.commit()
            return cursor.rowcount > 0
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    # ---- Sync / Recalculate ----

    def sync_kpi(self, project_kpi_id):
        """Recalculate current_value from linked budget lines or KPI dependencies."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            # Sum of linked budget lines' spent_amount
            cursor.execute('''
                SELECT COALESCE(SUM(bl.spent_amount), 0) as total_spent, COUNT(*) as cnt
                FROM mkt_kpi_budget_lines kb
                JOIN mkt_budget_lines bl ON bl.id = kb.budget_line_id
                WHERE kb.project_kpi_id = %s
            ''', (project_kpi_id,))
            bl_row = cursor.fetchone()

            # KPI dependencies
            cursor.execute('''
                SELECT kd.role, pk.current_value
                FROM mkt_kpi_dependencies kd
                JOIN mkt_project_kpis pk ON pk.id = kd.depends_on_kpi_id
                WHERE kd.project_kpi_id = %s
            ''', (project_kpi_id,))
            deps = [dict(r) for r in cursor.fetchall()]

            new_value = None

            if deps:
                numerators = [float(d['current_value'] or 0) for d in deps if d['role'] == 'numerator']
                denominators = [float(d['current_value'] or 0) for d in deps if d['role'] == 'denominator']
                if numerators and denominators:
                    num = sum(numerators)
                    den = sum(denominators)
                    new_value = round(num / den, 4) if den != 0 else 0
            elif bl_row['cnt'] > 0:
                new_value = float(bl_row['total_spent'])

            if new_value is not None:
                cursor.execute('''
                    UPDATE mkt_project_kpis
                    SET current_value = %s, last_synced_at = NOW(), updated_at = NOW()
                    WHERE id = %s
                ''', (new_value, project_kpi_id))
                cursor.execute('''
                    INSERT INTO mkt_kpi_snapshots (project_kpi_id, value, source)
                    VALUES (%s, %s, 'auto')
                ''', (project_kpi_id, new_value))
                conn.commit()
                return {'synced': True, 'value': new_value}

            conn.commit()
            return {'synced': False, 'reason': 'No linked sources'}
        except Exception:
            conn.rollback()
            raise
        finally:
            release_db(conn)

    # ---- Snapshots ----

    def get_snapshots(self, project_kpi_id, limit=50):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                SELECT s.*, u.name as recorded_by_name
                FROM mkt_kpi_snapshots s
                LEFT JOIN users u ON u.id = s.recorded_by
                WHERE s.project_kpi_id = %s
                ORDER BY s.recorded_at DESC
                LIMIT %s
            ''', (project_kpi_id, limit))
            return [dict(r) for r in cursor.fetchall()]
        finally:
            release_db(conn)

    def add_snapshot(self, project_kpi_id, value, recorded_by=None, source='manual', notes=None):
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute('''
                INSERT INTO mkt_kpi_snapshots (project_kpi_id, value, source, recorded_by, notes)
                VALUES (%s, %s, %s, %s, %s) RETURNING id
            ''', (project_kpi_id, value, source, recorded_by, notes))
            snap_id = cursor.fetchone()['id']
            # Update current_value on project_kpi
            cursor.execute('''
                UPDATE mkt_project_kpis SET current_value = %s, last_synced_at = NOW(), updated_at = NOW()
                WHERE id = %s
            ''', (value, project_kpi_id))
            conn.commit()
            return snap_id
        except Exception as e:
            conn.rollback()
            raise
        finally:
            release_db(conn)
