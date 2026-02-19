"""
Sync Repository

Database operations for e-Factura synchronization tracking.
"""

import uuid
from datetime import datetime
from typing import Optional, List, Dict, Any

from core.base_repository import BaseRepository
from core.utils.logging_config import get_logger
from ..models import SyncRun, SyncError

logger = get_logger('jarvis.accounting.efactura.repo.sync')


class SyncRepository(BaseRepository):
    """Repository for SyncRun and SyncError entities."""

    def create_run(self, company_cif: str, direction: str = 'both') -> SyncRun:
        """Create a new sync run."""
        run = SyncRun(
            run_id=str(uuid.uuid4()),
            company_cif=company_cif,
            direction=direction,
            started_at=datetime.now(),
        )

        def _work(cursor):
            cursor.execute("""
                INSERT INTO efactura_sync_runs (
                    run_id, company_cif, direction, started_at
                ) VALUES (
                    %(run_id)s, %(company_cif)s, %(direction)s, %(started_at)s
                )
                RETURNING id
            """, {
                'run_id': run.run_id,
                'company_cif': run.company_cif,
                'direction': run.direction,
                'started_at': run.started_at,
            })
            run.id = cursor.fetchone()['id']
            logger.info(
                "Sync run started",
                extra={
                    'run_id': run.run_id,
                    'cif': company_cif,
                    'direction': direction,
                }
            )
            return run
        return self.execute_many(_work)

    def complete_run(
        self,
        run: SyncRun,
        success: bool = True,
        error_summary: Optional[str] = None,
    ) -> SyncRun:
        """Mark sync run as complete."""
        run.finished_at = datetime.now()
        run.success = success
        run.error_summary = error_summary

        self.execute("""
            UPDATE efactura_sync_runs SET
                finished_at = %(finished_at)s,
                success = %(success)s,
                messages_checked = %(messages_checked)s,
                invoices_fetched = %(invoices_fetched)s,
                invoices_created = %(invoices_created)s,
                invoices_updated = %(invoices_updated)s,
                invoices_skipped = %(invoices_skipped)s,
                errors_count = %(errors_count)s,
                cursor_before = %(cursor_before)s,
                cursor_after = %(cursor_after)s,
                error_summary = %(error_summary)s
            WHERE run_id = %(run_id)s
        """, {
            'run_id': run.run_id,
            'finished_at': run.finished_at,
            'success': run.success,
            'messages_checked': run.messages_checked,
            'invoices_fetched': run.invoices_fetched,
            'invoices_created': run.invoices_created,
            'invoices_updated': run.invoices_updated,
            'invoices_skipped': run.invoices_skipped,
            'errors_count': run.errors_count,
            'cursor_before': run.cursor_before,
            'cursor_after': run.cursor_after,
            'error_summary': run.error_summary,
        })

        duration_ms = int(
            (run.finished_at - run.started_at).total_seconds() * 1000
        )
        logger.info(
            "Sync run completed",
            extra={
                'run_id': run.run_id,
                'success': success,
                'duration_ms': duration_ms,
                'invoices_created': run.invoices_created,
                'errors_count': run.errors_count,
            }
        )
        return run

    def record_error(
        self,
        run_id: str,
        error_type: str,
        error_message: str,
        message_id: Optional[str] = None,
        invoice_ref: Optional[str] = None,
        error_code: Optional[str] = None,
        request_hash: Optional[str] = None,
        response_hash: Optional[str] = None,
        stack_trace: Optional[str] = None,
        is_retryable: bool = False,
    ) -> SyncError:
        """Record a sync error."""
        error = SyncError(
            run_id=run_id,
            message_id=message_id,
            invoice_ref=invoice_ref,
            error_type=error_type,
            error_code=error_code,
            error_message=error_message[:500] if error_message else None,
            request_hash=request_hash,
            response_hash=response_hash,
            stack_trace=stack_trace[:2000] if stack_trace else None,
            is_retryable=is_retryable,
        )

        def _work(cursor):
            cursor.execute("""
                INSERT INTO efactura_sync_errors (
                    run_id, message_id, invoice_ref,
                    error_type, error_code, error_message,
                    request_hash, response_hash, stack_trace,
                    is_retryable, created_at
                ) VALUES (
                    %(run_id)s, %(message_id)s, %(invoice_ref)s,
                    %(error_type)s, %(error_code)s, %(error_message)s,
                    %(request_hash)s, %(response_hash)s, %(stack_trace)s,
                    %(is_retryable)s, NOW()
                )
                RETURNING id, created_at
            """, {
                'run_id': error.run_id,
                'message_id': error.message_id,
                'invoice_ref': error.invoice_ref,
                'error_type': error.error_type,
                'error_code': error.error_code,
                'error_message': error.error_message,
                'request_hash': error.request_hash,
                'response_hash': error.response_hash,
                'stack_trace': error.stack_trace,
                'is_retryable': error.is_retryable,
            })
            row = cursor.fetchone()
            error.id = row['id']
            error.created_at = row['created_at']
            logger.warning(
                "Sync error recorded",
                extra={
                    'run_id': run_id,
                    'error_type': error_type,
                    'message_id': message_id,
                    'is_retryable': is_retryable,
                }
            )
            return error
        return self.execute_many(_work)

    def get_run_by_id(self, run_id: str) -> Optional[SyncRun]:
        """Get sync run by ID."""
        row = self.query_one(
            'SELECT * FROM efactura_sync_runs WHERE run_id = %s', (run_id,)
        )
        return self._row_to_run(row) if row else None

    def get_recent_runs(
        self,
        company_cif: Optional[str] = None,
        limit: int = 20,
    ) -> List[SyncRun]:
        """Get recent sync runs."""
        if company_cif:
            rows = self.query_all("""
                SELECT * FROM efactura_sync_runs
                WHERE company_cif = %s
                ORDER BY started_at DESC
                LIMIT %s
            """, (company_cif, limit))
        else:
            rows = self.query_all("""
                SELECT * FROM efactura_sync_runs
                ORDER BY started_at DESC
                LIMIT %s
            """, (limit,))
        return [self._row_to_run(row) for row in rows]

    def get_run_errors(self, run_id: str) -> List[SyncError]:
        """Get errors for a sync run."""
        rows = self.query_all("""
            SELECT * FROM efactura_sync_errors
            WHERE run_id = %s
            ORDER BY created_at
        """, (run_id,))
        return [self._row_to_error(row) for row in rows]

    def get_last_successful_run(
        self,
        company_cif: str,
        direction: Optional[str] = None,
    ) -> Optional[SyncRun]:
        """Get last successful sync run for a company."""
        if direction:
            row = self.query_one("""
                SELECT * FROM efactura_sync_runs
                WHERE company_cif = %s
                AND direction = %s
                AND success = TRUE
                ORDER BY finished_at DESC
                LIMIT 1
            """, (company_cif, direction))
        else:
            row = self.query_one("""
                SELECT * FROM efactura_sync_runs
                WHERE company_cif = %s
                AND success = TRUE
                ORDER BY finished_at DESC
                LIMIT 1
            """, (company_cif,))
        return self._row_to_run(row) if row else None

    def get_error_stats(
        self,
        company_cif: Optional[str] = None,
        hours: int = 24,
    ) -> Dict[str, Any]:
        """Get error statistics for monitoring."""
        cif_filter = 'AND r.company_cif = %s' if company_cif else ''
        params = [hours]
        if company_cif:
            params.append(company_cif)

        rows = self.query_all(f"""
            SELECT
                e.error_type,
                COUNT(*) as count,
                COUNT(DISTINCT r.company_cif) as affected_companies
            FROM efactura_sync_errors e
            JOIN efactura_sync_runs r ON r.run_id = e.run_id
            WHERE r.started_at > NOW() - INTERVAL '%s hours'
            {cif_filter}
            GROUP BY e.error_type
            ORDER BY count DESC
        """, params)

        stats = {
            'by_type': {},
            'total_errors': 0,
            'hours': hours,
        }
        for row in rows:
            stats['by_type'][row['error_type']] = {
                'count': row['count'],
                'affected_companies': row['affected_companies'],
            }
            stats['total_errors'] += row['count']
        return stats

    def cleanup_old_runs(self, days: int = 90) -> int:
        """Delete old sync runs and errors."""
        def _work(cursor):
            # Delete old errors first (FK constraint)
            cursor.execute("""
                DELETE FROM efactura_sync_errors
                WHERE run_id IN (
                    SELECT run_id FROM efactura_sync_runs
                    WHERE started_at < NOW() - INTERVAL '%s days'
                )
            """, (days,))

            # Delete old runs
            cursor.execute("""
                DELETE FROM efactura_sync_runs
                WHERE started_at < NOW() - INTERVAL '%s days'
            """, (days,))
            deleted = cursor.rowcount
            logger.info(
                "Cleaned up old sync runs",
                extra={'deleted': deleted, 'older_than_days': days}
            )
            return deleted
        return self.execute_many(_work)

    def _row_to_run(self, row: Dict[str, Any]) -> SyncRun:
        """Convert database row to SyncRun model."""
        return SyncRun(
            id=row['id'],
            run_id=row['run_id'],
            company_cif=row['company_cif'],
            direction=row.get('direction'),
            started_at=row['started_at'],
            finished_at=row.get('finished_at'),
            success=row.get('success', False),
            messages_checked=row.get('messages_checked', 0),
            invoices_fetched=row.get('invoices_fetched', 0),
            invoices_created=row.get('invoices_created', 0),
            invoices_updated=row.get('invoices_updated', 0),
            invoices_skipped=row.get('invoices_skipped', 0),
            errors_count=row.get('errors_count', 0),
            cursor_before=row.get('cursor_before'),
            cursor_after=row.get('cursor_after'),
            error_summary=row.get('error_summary'),
        )

    def _row_to_error(self, row: Dict[str, Any]) -> SyncError:
        """Convert database row to SyncError model."""
        return SyncError(
            id=row['id'],
            run_id=row['run_id'],
            message_id=row.get('message_id'),
            invoice_ref=row.get('invoice_ref'),
            error_type=row['error_type'],
            error_code=row.get('error_code'),
            error_message=row['error_message'],
            request_hash=row.get('request_hash'),
            response_hash=row.get('response_hash'),
            stack_trace=row.get('stack_trace'),
            is_retryable=row.get('is_retryable', False),
            created_at=row['created_at'],
        )
