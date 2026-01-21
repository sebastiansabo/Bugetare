/**
 * J.A.R.V.I.S. Shared Utilities
 * Common functions used across multiple pages
 */

(function() {
    'use strict';

    // Loading overlay state
    let loadingCount = 0;

    /**
     * Escape HTML entities to prevent XSS
     * @param {string} text - Text to escape
     * @returns {string} Escaped HTML string
     */
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Format date string to Romanian format (DD.MM.YYYY)
     * @param {string} dateStr - ISO date string or date-like string
     * @returns {string} Formatted date or '-' if invalid
     */
    function formatDateRomanian(dateStr) {
        if (!dateStr) return '-';
        try {
            const date = new Date(dateStr);
            if (isNaN(date.getTime())) return dateStr;
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            return `${day}.${month}.${year}`;
        } catch (e) {
            return dateStr;
        }
    }

    /**
     * Format date to ISO format (YYYY-MM-DD) for form inputs
     * @param {string|Date} dateStr - Date to format
     * @returns {string} ISO formatted date
     */
    function formatDateISO(dateStr) {
        if (!dateStr) return '';
        try {
            const date = new Date(dateStr);
            if (isNaN(date.getTime())) return dateStr;
            return date.toISOString().split('T')[0];
        } catch (e) {
            return dateStr;
        }
    }

    /**
     * Show a toast notification
     * @param {string} message - Message to display
     * @param {string} type - 'success', 'error', 'warning', 'info'
     * @param {number} duration - Duration in ms (default 3000)
     */
    function showNotification(message, type = 'info', duration = 3000) {
        const alertClass = {
            'success': 'alert-success',
            'error': 'alert-danger',
            'warning': 'alert-warning',
            'info': 'alert-info'
        }[type] || 'alert-info';

        const icon = {
            'success': 'check-circle',
            'error': 'exclamation-circle',
            'warning': 'exclamation-triangle',
            'info': 'info-circle'
        }[type] || 'info-circle';

        const notification = document.createElement('div');
        notification.className = `alert ${alertClass} position-fixed top-0 end-0 m-3 shadow`;
        notification.style.zIndex = '9999';
        notification.style.minWidth = '250px';
        notification.innerHTML = `<i class="bi bi-${icon}"></i> ${escapeHtml(message)}`;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transition = 'opacity 0.3s';
            setTimeout(() => notification.remove(), 300);
        }, duration);
    }

    /**
     * Show loading overlay
     * @param {string} message - Loading message to display
     */
    function showLoading(message = 'Loading...') {
        loadingCount++;
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            const text = overlay.querySelector('.loading-text');
            if (text) text.textContent = message;
            overlay.classList.add('show');
        }
    }

    /**
     * Hide loading overlay (only hides when all loading calls are balanced)
     */
    function hideLoading() {
        loadingCount = Math.max(0, loadingCount - 1);
        if (loadingCount === 0) {
            const overlay = document.getElementById('loadingOverlay');
            if (overlay) {
                overlay.classList.remove('show');
            }
        }
    }

    /**
     * Force hide loading overlay (resets counter)
     */
    function forceHideLoading() {
        loadingCount = 0;
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.classList.remove('show');
        }
    }

    /**
     * Debounce function to limit rapid calls
     * @param {Function} func - Function to debounce
     * @param {number} wait - Wait time in ms
     * @returns {Function} Debounced function
     */
    function debounce(func, wait = 300) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    /**
     * Format number with thousands separator
     * @param {number} num - Number to format
     * @param {number} decimals - Decimal places (default 2)
     * @returns {string} Formatted number
     */
    function formatNumber(num, decimals = 2) {
        if (num === null || num === undefined) return '-';
        return Number(num).toLocaleString('ro-RO', {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        });
    }

    /**
     * Format currency value
     * @param {number} amount - Amount to format
     * @param {string} currency - Currency code (RON, EUR, USD)
     * @returns {string} Formatted currency string
     */
    function formatCurrency(amount, currency = 'RON') {
        if (amount === null || amount === undefined) return '-';
        return `${formatNumber(amount)} ${currency}`;
    }

    // Expose functions globally
    window.JarvisUtils = {
        escapeHtml,
        formatDateRomanian,
        formatDateISO,
        showNotification,
        showLoading,
        hideLoading,
        forceHideLoading,
        debounce,
        formatNumber,
        formatCurrency
    };

    // Also expose commonly used functions directly for backward compatibility
    window.escapeHtml = escapeHtml;
    window.formatDateRomanian = formatDateRomanian;
    window.showNotification = showNotification;
    window.showLoading = showLoading;
    window.hideLoading = hideLoading;

})();
