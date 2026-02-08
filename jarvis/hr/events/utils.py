"""HR Events Utility Functions — Bonus Lock System."""
from datetime import date
from typing import Tuple

# Default lock day (can be overridden via Settings)
DEFAULT_LOCK_DAY = 5


def get_lock_day() -> int:
    """
    Get the configured lock day from database settings.
    Falls back to DEFAULT_LOCK_DAY if not configured.
    """
    try:
        from core.notifications.repositories import NotificationRepository
        settings = NotificationRepository().get_settings()
        lock_day = settings.get('hr_bonus_lock_day')
        if lock_day:
            return int(lock_day)
    except Exception:
        pass
    return DEFAULT_LOCK_DAY


def get_bonus_lock_deadline(year: int, month: int) -> date:
    """
    Get the deadline date for a bonus month.

    Bonuses for a given month are editable until the 5th of the following month.
    Example: January 2026 bonuses lock on February 5, 2026 at end of day.

    Args:
        year: Bonus year
        month: Bonus month (1-12)

    Returns:
        date: The deadline date (configured day of following month)
    """
    lock_day = get_lock_day()
    if month == 12:
        return date(year + 1, 1, lock_day)
    return date(year, month + 1, lock_day)


def is_bonus_month_locked(year: int, month: int) -> bool:
    """
    Check if a bonus month is locked (past the edit deadline).

    Args:
        year: Bonus year
        month: Bonus month (1-12)

    Returns:
        bool: True if locked (past deadline), False if still editable
    """
    return date.today() > get_bonus_lock_deadline(year, month)


def get_lock_status(year: int, month: int) -> dict:
    """
    Get comprehensive lock status information for a bonus month.

    Args:
        year: Bonus year
        month: Bonus month (1-12)

    Returns:
        dict with keys:
            - locked: bool - Whether the month is locked
            - deadline: str - ISO format deadline date
            - deadline_display: str - Romanian format deadline (DD.MM.YYYY)
            - days_remaining: int - Days until lock (negative if past)
            - message: str - Human-readable status message
    """
    deadline = get_bonus_lock_deadline(year, month)
    today = date.today()
    days_remaining = (deadline - today).days
    locked = today > deadline

    if locked:
        message = f"Locked since {deadline.strftime('%d.%m.%Y')}"
    elif days_remaining == 0:
        message = "Last day to edit! Locks at midnight."
    elif days_remaining == 1:
        message = "1 day remaining"
    else:
        message = f"{days_remaining} days remaining"

    return {
        'locked': locked,
        'deadline': deadline.isoformat(),
        'deadline_display': deadline.strftime('%d.%m.%Y'),
        'days_remaining': days_remaining,
        'message': message
    }


def can_edit_bonus(year: int, month: int, user_role: str) -> Tuple[bool, str]:
    """
    Check if a user can edit a bonus for the given month.

    Admin users can always edit regardless of lock status.
    Other users can only edit if the month is not locked.

    Args:
        year: Bonus year
        month: Bonus month (1-12)
        user_role: User's role name (e.g., 'Admin', 'Manager', 'User')

    Returns:
        Tuple of (can_edit: bool, reason: str)
    """
    if user_role == 'Admin':
        return True, "Admin override"

    if is_bonus_month_locked(year, month):
        deadline = get_bonus_lock_deadline(year, month)
        return False, f"Locked since {deadline.strftime('%d.%m.%Y')}"

    return True, "Within edit window"
