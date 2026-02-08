"""JARVIS Cache Infrastructure.

Thread-safe in-memory caching utilities used across all modules.
Provides generic cache creation, validation, and cleanup functions.

Domain-specific caches (templates, invoices, etc.) are owned by their
respective repositories. This module provides the shared primitives.

Usage:
    from core.cache import create_cache, get_cache_lock, _is_cache_valid
    from core.cache import _get_cache_data, _set_cache_data
    from core.cache import _get_summary_cache, _set_summary_cache
"""

import time
import logging
import threading

logger = logging.getLogger('jarvis.core.cache')

# Thread-safe lock for cache operations
# Prevents race conditions in multi-threaded Gunicorn environment
_cache_lock = threading.RLock()

# Maximum entries per summary cache type to prevent unbounded growth
MAX_SUMMARY_CACHE_ENTRIES = 50


def _is_cache_valid(cache_entry: dict) -> bool:
    """Check if a cache entry is still valid."""
    if cache_entry.get('data') is None:
        return False
    return (time.time() - cache_entry.get('timestamp', 0)) < cache_entry.get('ttl', 300)


def _get_cache_data(cache_dict: dict, key: str = 'data'):
    """Thread-safe getter for cache data."""
    with _cache_lock:
        return cache_dict.get(key)


def _set_cache_data(cache_dict: dict, data, key: str = 'data'):
    """Thread-safe setter for cache data with timestamp update."""
    with _cache_lock:
        cache_dict[key] = data
        cache_dict['timestamp'] = time.time()


def create_cache(ttl: int = 300) -> dict:
    """Create a new cache dictionary with specified TTL."""
    return {
        'data': None,
        'timestamp': 0,
        'ttl': ttl
    }


def get_cache_lock():
    """Get the shared cache lock for custom cache operations."""
    return _cache_lock


def _get_summary_cache(summary_cache: dict, cache_type: str, cache_key: str):
    """Thread-safe getter for summary cache entries.

    Args:
        summary_cache: The summary cache dict (e.g. _summary_cache from the owning module)
        cache_type: Cache category (e.g. 'company', 'department')
        cache_key: Unique key for the cached query
    """
    with _cache_lock:
        cache = summary_cache.get(cache_type, {})
        entry = cache.get(cache_key)
        if entry and (time.time() - entry.get('timestamp', 0)) < summary_cache.get('ttl', 60):
            return entry.get('data')
        return None


def _set_summary_cache(summary_cache: dict, cache_type: str, cache_key: str, data):
    """Thread-safe setter for summary cache entries.

    Args:
        summary_cache: The summary cache dict (e.g. _summary_cache from the owning module)
        cache_type: Cache category (e.g. 'company', 'department')
        cache_key: Unique key for the cached query
        data: The data to cache
    """
    with _cache_lock:
        summary_cache[cache_type][cache_key] = {'data': data, 'timestamp': time.time()}
        _enforce_summary_cache_limit(summary_cache, cache_type)


def _enforce_summary_cache_limit(summary_cache: dict, cache_type: str):
    """Remove oldest entries if cache exceeds MAX_SUMMARY_CACHE_ENTRIES.

    Note: Caller must hold _cache_lock.
    """
    cache = summary_cache.get(cache_type, {})
    if len(cache) > MAX_SUMMARY_CACHE_ENTRIES:
        sorted_keys = sorted(cache.keys(), key=lambda k: cache[k].get('timestamp', 0))
        entries_to_remove = len(cache) - MAX_SUMMARY_CACHE_ENTRIES
        for key in sorted_keys[:entries_to_remove]:
            del cache[key]
        logger.debug(f'Evicted {entries_to_remove} entries from {cache_type} cache')


def cleanup_expired_caches(summary_cache: dict = None):
    """Remove expired entries from summary caches.

    Call periodically to prevent memory growth.

    Args:
        summary_cache: The summary cache dict to clean. If None, uses the
                       invoice summary cache from summary_repository.
    """
    if summary_cache is None:
        from accounting.invoices.repositories.summary_repository import _summary_cache
        summary_cache = _summary_cache
    with _cache_lock:
        now = time.time()
        ttl = summary_cache.get('ttl', 60)
        total_removed = 0

        for cache_type in ['company', 'department', 'brand', 'supplier']:
            cache = summary_cache.get(cache_type, {})
            expired_keys = [k for k, v in cache.items() if (now - v.get('timestamp', 0)) > ttl]
            for key in expired_keys:
                del cache[key]
            total_removed += len(expired_keys)

        if total_removed > 0:
            logger.debug(f'Cleaned up {total_removed} expired cache entries')
