"""
Scheduled cleanup tasks for JARVIS.

Uses APScheduler BackgroundScheduler to run periodic maintenance jobs.
"""

import atexit
from apscheduler.schedulers.background import BackgroundScheduler
from core.utils.logging_config import get_logger

logger = get_logger('jarvis.tasks.cleanup')

scheduler = BackgroundScheduler(daemon=True)


def cleanup_old_unallocated_invoices():
    """Permanently delete unallocated e-Factura invoices older than 15 days."""
    try:
        from core.connectors.efactura.repositories.invoice_repo import EFacturaInvoiceRepository
        repo = EFacturaInvoiceRepository()
        count = repo.delete_old_unallocated(days=15)
        if count > 0:
            logger.info(f"Cleanup: deleted {count} old unallocated e-Factura invoices (>15 days)")
    except Exception as e:
        logger.error(f"Cleanup task failed: {e}")


def reindex_rag_documents():
    """Reindex all RAG document sources for the AI agent."""
    try:
        from ai_agent.services.rag_service import RAGService
        svc = RAGService()
        result = svc.index_all_sources()
        total = result.data.get('total', 0) if result.success else 0
        logger.info(f"RAG reindex complete: {total} documents indexed")
    except Exception as e:
        logger.error(f"RAG reindex task failed: {e}")


def start_scheduler():
    """Start the background scheduler with all cleanup jobs."""
    if scheduler.running:
        return

    scheduler.add_job(
        cleanup_old_unallocated_invoices,
        'interval',
        hours=6,
        id='cleanup_old_unallocated',
        replace_existing=True,
    )

    scheduler.add_job(
        reindex_rag_documents,
        'cron',
        hour=0,
        minute=0,
        id='rag_reindex_daily',
        replace_existing=True,
    )

    scheduler.start()
    atexit.register(lambda: scheduler.shutdown(wait=False))
    logger.info("Background scheduler started with cleanup jobs")


def stop_scheduler():
    """Stop the background scheduler."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        logger.info("Background scheduler stopped")
