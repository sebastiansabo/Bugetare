/**
 * J.A.R.V.I.S. Online Users Tracking
 * Handles heartbeat and online users display
 */

(function() {
    'use strict';

    let onlineUsersInterval = null;
    let heartbeatInterval = null;
    let onlineUsersTooltip = null;
    let initialized = false;

    /**
     * Send heartbeat to server to indicate user is active
     */
    async function sendHeartbeat() {
        try {
            await fetch('/api/heartbeat', { method: 'POST' });
        } catch (e) {
            console.error('Heartbeat failed:', e);
        }
    }

    /**
     * Fetch and update online users count and tooltip
     */
    async function updateOnlineUsersCount() {
        try {
            const res = await fetch('/api/online-users');
            const data = await res.json();

            const countEl = document.getElementById('onlineUsersCount');
            const indicatorEl = document.getElementById('onlineUsersIndicator');

            if (countEl) {
                countEl.textContent = data.count;
            }

            if (indicatorEl && data.users) {
                // Initialize tooltip if not already done
                if (!onlineUsersTooltip && typeof bootstrap !== 'undefined') {
                    onlineUsersTooltip = new bootstrap.Tooltip(indicatorEl, {
                        html: true,
                        trigger: 'hover'
                    });
                }

                // Build tooltip content
                let tooltipContent = '<strong>Online Users:</strong>';
                if (data.users && data.users.length > 0) {
                    tooltipContent += '<br>' + data.users.map(u => u.name).join('<br>');
                } else {
                    tooltipContent += '<br><em>No users online</em>';
                }

                indicatorEl.setAttribute('data-bs-original-title', tooltipContent);

                // Update tooltip if visible
                if (onlineUsersTooltip) {
                    onlineUsersTooltip.setContent({ '.tooltip-inner': tooltipContent });
                }
            }
        } catch (e) {
            console.error('Failed to get online users:', e);
        }
    }

    /**
     * Initialize online users tracking
     * Call this on DOMContentLoaded
     */
    async function init() {
        if (initialized) return;
        initialized = true;

        // Check if online users indicator exists on this page
        const indicatorEl = document.getElementById('onlineUsersIndicator');
        if (!indicatorEl) {
            // No indicator on this page, just send heartbeats
            await sendHeartbeat();
            heartbeatInterval = setInterval(sendHeartbeat, 60000);
            return;
        }

        // Initial calls
        await sendHeartbeat();
        await updateOnlineUsersCount();

        // Set up intervals
        heartbeatInterval = setInterval(sendHeartbeat, 60000);      // Every 60 seconds
        onlineUsersInterval = setInterval(updateOnlineUsersCount, 30000);  // Every 30 seconds
    }

    /**
     * Clean up intervals (call on page unload if needed)
     */
    function destroy() {
        if (heartbeatInterval) {
            clearInterval(heartbeatInterval);
            heartbeatInterval = null;
        }
        if (onlineUsersInterval) {
            clearInterval(onlineUsersInterval);
            onlineUsersInterval = null;
        }
        if (onlineUsersTooltip) {
            onlineUsersTooltip.dispose();
            onlineUsersTooltip = null;
        }
        initialized = false;
    }

    // Auto-initialize on DOMContentLoaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expose functions globally
    window.JarvisOnlineUsers = {
        init,
        destroy,
        sendHeartbeat,
        updateOnlineUsersCount
    };

    // Backward compatibility for inline calls
    window.initOnlineUsersTracking = init;

})();
