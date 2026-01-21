/**
 * J.A.R.V.I.S. Profile Management
 * Handles user profile updates and password changes
 */

(function() {
    'use strict';

    /**
     * Update user profile (name, phone)
     */
    async function updateProfile() {
        const nameInput = document.getElementById('profileName');
        const phoneInput = document.getElementById('profilePhone');

        if (!nameInput) {
            alert('Profile form not found');
            return;
        }

        const name = nameInput.value.trim();
        const phone = phoneInput ? phoneInput.value.trim() : '';

        if (!name || name.length < 2) {
            alert('Name must be at least 2 characters');
            return;
        }

        try {
            const response = await fetch('/api/auth/update-profile', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, phone })
            });

            const result = await response.json();

            if (result.success) {
                // Update navbar display name if present
                const userDropdown = document.getElementById('userDropdown');
                if (userDropdown && result.name) {
                    userDropdown.innerHTML = '<i class="bi bi-person-circle"></i> ' + result.name;
                }

                if (typeof showNotification === 'function') {
                    showNotification('Profile updated successfully', 'success');
                } else {
                    alert('Profile updated successfully');
                }
            } else {
                alert('Error: ' + (result.error || 'Unknown error'));
            }
        } catch (e) {
            alert('Error: ' + e.message);
        }
    }

    /**
     * Change user password
     */
    async function changePassword() {
        const currentPasswordInput = document.getElementById('currentPassword');
        const newPasswordInput = document.getElementById('newPassword');
        const confirmPasswordInput = document.getElementById('confirmPassword');

        if (!currentPasswordInput || !newPasswordInput || !confirmPasswordInput) {
            alert('Password form not found');
            return;
        }

        const currentPassword = currentPasswordInput.value;
        const newPassword = newPasswordInput.value;
        const confirmPassword = confirmPasswordInput.value;

        if (!currentPassword || !newPassword || !confirmPassword) {
            alert('Please fill in all password fields');
            return;
        }

        if (newPassword !== confirmPassword) {
            alert('New passwords do not match');
            return;
        }

        if (newPassword.length < 6) {
            alert('Password must be at least 6 characters');
            return;
        }

        try {
            const response = await fetch('/api/auth/change-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    current_password: currentPassword,
                    new_password: newPassword
                })
            });

            const result = await response.json();

            if (result.success) {
                // Clear the form
                const form = document.getElementById('changePasswordForm');
                if (form) form.reset();

                if (typeof showNotification === 'function') {
                    showNotification('Password changed successfully', 'success');
                } else {
                    alert('Password changed successfully');
                }
            } else {
                alert('Error: ' + (result.error || 'Unknown error'));
            }
        } catch (e) {
            alert('Error: ' + e.message);
        }
    }

    /**
     * Initialize profile modal event listeners
     */
    function init() {
        // Set up save profile button
        const saveProfileBtn = document.querySelector('#editProfileModal .btn-primary[onclick*="updateProfile"]');
        if (saveProfileBtn) {
            saveProfileBtn.removeAttribute('onclick');
            saveProfileBtn.addEventListener('click', updateProfile);
        }

        // Set up change password button
        const changePasswordBtn = document.querySelector('#editProfileModal .btn-warning[onclick*="changePassword"]');
        if (changePasswordBtn) {
            changePasswordBtn.removeAttribute('onclick');
            changePasswordBtn.addEventListener('click', changePassword);
        }
    }

    // Auto-initialize on DOMContentLoaded if modal exists
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expose functions globally
    window.JarvisProfile = {
        updateProfile,
        changePassword,
        init
    };

    // Backward compatibility - expose at window level
    window.updateProfile = updateProfile;
    window.changePassword = changePassword;

})();
