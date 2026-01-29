/**
 * Invoice Edit Module - Shared JavaScript for editing invoices
 * Used by: accounting.html, profile.html, and any page with the edit invoice modal
 */

// Module state
const InvoiceEdit = {
    currentInvoiceData: null,
    organizationalStructure: [],
    statusOptions: [],
    paymentStatusOptions: [],
    vatRates: [],
    companiesData: [],
    editAllocations: [],
    onSaveCallback: null,  // Callback after successful save
    userRole: 'Viewer',    // Current user's role (set during init)

    // Role hierarchy for permission checks (higher index = more permissions)
    roleHierarchy: ['Viewer', 'User', 'Manager', 'Admin'],

    // Check if user's role meets the minimum required role
    userHasRole(minRole) {
        const userRoleIndex = this.roleHierarchy.indexOf(this.userRole);
        const minRoleIndex = this.roleHierarchy.indexOf(minRole || 'Viewer');
        return userRoleIndex >= minRoleIndex;
    },

    // Check if user can edit processed invoices (legacy - for backward compatibility)
    canEditProcessed() {
        return ['Admin', 'Manager'].includes(this.userRole);
    },

    // Initialize the module
    async init(options = {}) {
        this.onSaveCallback = options.onSaveCallback || null;
        this.userRole = options.userRole || 'Viewer';
        await this.loadDropdownOptions();
        await this.loadOrganizationalStructure();
        this.setupEventListeners();
    },

    // Load dropdown options from API
    async loadDropdownOptions() {
        try {
            const [optionsResponse, vatResponse] = await Promise.all([
                fetch('/api/dropdown-options'),
                fetch('/api/vat-rates')
            ]);
            const data = await optionsResponse.json();

            // Filter options by dropdown_type (API returns flat array)
            this.statusOptions = data.filter(opt => opt.dropdown_type === 'invoice_status');
            this.paymentStatusOptions = data.filter(opt => opt.dropdown_type === 'payment_status');
            this.vatRates = await vatResponse.json();

            // Populate status dropdown (filter based on min_role)
            const statusSelect = document.getElementById('editStatus');
            if (statusSelect) {
                statusSelect.innerHTML = this.statusOptions
                    .filter(opt => this.userHasRole(opt.min_role))
                    .map(opt => `<option value="${opt.value}">${opt.label || opt.value}</option>`)
                    .join('');
            }

            // Populate payment status dropdown
            const paymentSelect = document.getElementById('editPaymentStatus');
            if (paymentSelect) {
                paymentSelect.innerHTML = this.paymentStatusOptions.map(opt =>
                    `<option value="${opt.value}">${opt.label || opt.value}</option>`
                ).join('');
            }

            // Populate VAT rates dropdown
            const vatSelect = document.getElementById('editVatRateId');
            if (vatSelect) {
                vatSelect.innerHTML = '<option value="">Select rate...</option>' +
                    this.vatRates.map(r => `<option value="${r.id}" data-rate="${r.rate}">${r.name}</option>`).join('');
            }
        } catch (e) {
            console.error('Error loading dropdown options:', e);
        }
    },

    // Load organizational structure
    async loadOrganizationalStructure() {
        try {
            const [structResponse, companiesResponse] = await Promise.all([
                fetch('/api/structure'),
                fetch('/api/companies-vat')
            ]);
            this.organizationalStructure = await structResponse.json();
            this.companiesData = await companiesResponse.json();

            // Populate company dropdown
            const companySelect = document.getElementById('editDedicatedCompany');
            if (companySelect) {
                companySelect.innerHTML = '<option value="">Select company...</option>' +
                    this.companiesData.map(c => `<option value="${c.company}">${c.company}</option>`).join('');
            }
        } catch (e) {
            console.error('Error loading organizational structure:', e);
        }
    },

    // Setup event listeners
    setupEventListeners() {
        // VAT checkbox handler
        const subtractVatCheckbox = document.getElementById('editSubtractVat');
        if (subtractVatCheckbox) {
            subtractVatCheckbox.addEventListener('change', () => this.onVatCheckboxChange());
        }

        // VAT rate change handler
        const vatRateSelect = document.getElementById('editVatRateId');
        if (vatRateSelect) {
            vatRateSelect.addEventListener('change', () => this.calculateNetValue());
        }

        // Invoice value change handler
        const invoiceValueInput = document.getElementById('editInvoiceValue');
        if (invoiceValueInput) {
            invoiceValueInput.addEventListener('input', () => {
                this.recalculateAllocationValues();
                this.renderEditAllocations();
                if (document.getElementById('editSubtractVat').checked) {
                    this.calculateNetValue();
                }
            });
        }

        // Currency change handler
        const currencySelect = document.getElementById('editCurrency');
        if (currencySelect) {
            currencySelect.addEventListener('change', () => this.renderEditAllocations());
        }

        // Add allocation button
        const addBtn = document.getElementById('addAllocationBtn');
        if (addBtn) {
            addBtn.addEventListener('click', () => this.addAllocation());
        }

        // Company change handler
        const companySelect = document.getElementById('editDedicatedCompany');
        if (companySelect) {
            companySelect.addEventListener('change', () => this.onDedicatedCompanyChange());
        }

        // Save button
        const saveBtn = document.getElementById('saveInvoiceBtn');
        if (saveBtn) {
            saveBtn.addEventListener('click', () => this.saveInvoice());
        }

        // Upload file button
        const uploadBtn = document.getElementById('uploadEditFileBtn');
        if (uploadBtn) {
            uploadBtn.addEventListener('click', () => this.uploadFile());
        }

        // Edit from detail modal
        const editFromDetailBtn = document.getElementById('editFromDetailBtn');
        if (editFromDetailBtn) {
            editFromDetailBtn.addEventListener('click', () => {
                if (this.currentInvoiceData) {
                    const detailModal = bootstrap.Modal.getInstance(document.getElementById('invoiceDetailModal'));
                    if (detailModal) detailModal.hide();
                    this.openEditModal(this.currentInvoiceData.id);
                }
            });
        }

        // Save allocation comment
        const saveCommentBtn = document.getElementById('saveAllocationCommentBtn');
        if (saveCommentBtn) {
            saveCommentBtn.addEventListener('click', () => this.saveAllocationComment());
        }
    },

    // View invoice detail
    async viewInvoice(invoiceId) {
        const modal = new bootstrap.Modal(document.getElementById('invoiceDetailModal'));
        const body = document.getElementById('invoiceDetailBody');
        body.innerHTML = '<div class="text-center"><div class="spinner-border"></div></div>';
        modal.show();

        try {
            const response = await fetch(`/api/db/invoices/${invoiceId}`);
            const invoice = await response.json();
            this.currentInvoiceData = invoice;

            body.innerHTML = `
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Supplier:</strong> ${invoice.supplier || '-'}</p>
                        <p><strong>Invoice Number:</strong> ${invoice.invoice_number || '-'}</p>
                        <p><strong>Invoice Date:</strong> ${this.formatDateRomanian(invoice.invoice_date)}</p>
                        <p><strong>Invoice Value:</strong> ${this.formatCurrency(invoice.invoice_value)} ${invoice.currency || 'RON'}</p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Status:</strong> <span class="badge ${this.getStatusClass(invoice.status)}">${invoice.status || '-'}</span></p>
                        <p><strong>Payment Status:</strong> ${invoice.payment_status || '-'}</p>
                        <p><strong>Notes:</strong> ${invoice.comment || '-'}</p>
                        ${invoice.drive_link ? `<p><a href="${invoice.drive_link}" target="_blank" class="btn btn-sm btn-outline-success"><i class="bi bi-cloud-arrow-down"></i> View in Drive</a></p>` : ''}
                    </div>
                </div>
                ${invoice.allocations && invoice.allocations.length > 0 ? `
                <hr>
                <h6><i class="bi bi-pie-chart"></i> Allocations</h6>
                <table class="table table-sm">
                    <thead>
                        <tr><th>Company</th><th>Department</th><th>Brand</th><th class="text-end">Value</th><th class="text-end">%</th></tr>
                    </thead>
                    <tbody>
                        ${invoice.allocations.map(a => `
                            <tr>
                                <td>${a.company || '-'}</td>
                                <td>${a.department || '-'}</td>
                                <td>${a.brand || '-'}</td>
                                <td class="text-end">${this.formatCurrency(a.allocation_value)}</td>
                                <td class="text-end">${(a.allocation_percent || 0).toFixed(0)}%</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
                ` : ''}
            `;
        } catch (e) {
            body.innerHTML = `<div class="alert alert-danger">Error loading invoice: ${e.message}</div>`;
        }
    },

    // Open edit modal
    async openEditModal(invoiceId) {
        if (typeof showLoading === 'function') showLoading('Loading invoice...');

        try {
            // Load invoice data
            const response = await fetch(`/api/db/invoices/${invoiceId}`);
            const invoice = await response.json();
            this.currentInvoiceData = invoice;

            // Block users from editing invoices if their role is below the status's min_role
            const currentStatusOption = this.statusOptions.find(opt => opt.value === invoice.status);
            if (currentStatusOption && !this.userHasRole(currentStatusOption.min_role)) {
                if (typeof hideLoading === 'function') hideLoading();
                const minRole = currentStatusOption.min_role || 'Manager';
                JarvisDialog.alert(`Invoices with status "${currentStatusOption.label}" can only be edited by ${minRole}s or higher.`, { type: 'warning', title: 'Access Restricted' });
                return;
            }

            // Populate form
            document.getElementById('editInvoiceId').value = invoice.id;
            document.getElementById('editSupplier').value = invoice.supplier || '';
            document.getElementById('editInvoiceNumber').value = invoice.invoice_number || '';
            document.getElementById('editInvoiceDate').value = invoice.invoice_date || '';
            document.getElementById('editInvoiceValue').value = invoice.invoice_value || '';
            document.getElementById('editCurrency').value = invoice.currency || 'RON';
            document.getElementById('editDriveLink').value = invoice.drive_link || '';
            document.getElementById('editComment').value = invoice.comment || '';
            document.getElementById('editStatus').value = invoice.status || '';
            document.getElementById('editPaymentStatus').value = invoice.payment_status || '';

            // VAT fields
            const subtractVat = invoice.subtract_vat || false;
            document.getElementById('editSubtractVat').checked = subtractVat;
            document.getElementById('editVatRateCol').style.display = subtractVat ? 'block' : 'none';
            document.getElementById('editNetValueCol').style.display = subtractVat ? 'block' : 'none';

            if (invoice.vat_rate_id) {
                document.getElementById('editVatRateId').value = invoice.vat_rate_id;
            } else if (invoice.vat_rate) {
                // Match by rate value if vat_rate_id not available
                const vatSelect = document.getElementById('editVatRateId');
                for (let opt of vatSelect.options) {
                    if (opt.dataset.rate == invoice.vat_rate) {
                        vatSelect.value = opt.value;
                        break;
                    }
                }
            }

            if (invoice.net_value) {
                document.getElementById('editNetValue').value = invoice.net_value;
                document.getElementById('editNetValueDisplay').value = this.formatCurrencyNoSymbol(invoice.net_value) + ' ' + (invoice.currency || 'RON');
            }

            // Set dedicated company from first allocation
            if (invoice.allocations && invoice.allocations.length > 0) {
                document.getElementById('editDedicatedCompany').value = invoice.allocations[0].company || '';
                this.editAllocations = invoice.allocations.map(a => ({
                    ...a,
                    locked: a.locked || false,
                    reinvoice_to: a.reinvoice_to || ''
                }));
            } else {
                this.editAllocations = [];
            }

            this.renderEditAllocations();

            // Reset file input
            const fileInput = document.getElementById('editInvoiceFile');
            if (fileInput) fileInput.value = '';

            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('editInvoiceModal'));
            modal.show();
        } catch (e) {
            if (typeof showError === 'function') showError('Error loading invoice: ' + e.message);
            else JarvisDialog.alert('Error loading invoice: ' + e.message, { type: 'error' });
        } finally {
            if (typeof hideLoading === 'function') hideLoading();
        }
    },

    // VAT checkbox change handler
    onVatCheckboxChange() {
        const checked = document.getElementById('editSubtractVat').checked;
        document.getElementById('editVatRateCol').style.display = checked ? 'block' : 'none';
        document.getElementById('editNetValueCol').style.display = checked ? 'block' : 'none';
        if (checked) {
            this.calculateNetValue();
        }
    },

    // Calculate net value
    calculateNetValue() {
        const invoiceValue = parseFloat(document.getElementById('editInvoiceValue').value) || 0;
        const vatRateSelect = document.getElementById('editVatRateId');
        const selectedOption = vatRateSelect.options[vatRateSelect.selectedIndex];

        if (!selectedOption || !selectedOption.dataset.rate) {
            document.getElementById('editNetValue').value = '';
            document.getElementById('editNetValueDisplay').value = '';
            return;
        }

        const vatRate = parseFloat(selectedOption.dataset.rate);
        const netValue = invoiceValue / (1 + vatRate / 100);
        const currency = document.getElementById('editCurrency').value || 'RON';

        document.getElementById('editNetValue').value = netValue.toFixed(2);
        document.getElementById('editNetValueDisplay').value = this.formatCurrencyNoSymbol(netValue) + ' ' + currency;
    },

    // Dedicated company change handler
    onDedicatedCompanyChange() {
        const company = document.getElementById('editDedicatedCompany').value;
        // Update all allocations to new company
        this.editAllocations.forEach(a => {
            a.company = company;
            a.brand = '';
            a.department = '';
            a.subdepartment = '';
        });
        this.renderEditAllocations();
    },

    // Add allocation
    addAllocation() {
        const company = document.getElementById('editDedicatedCompany').value;
        if (!company) {
            JarvisDialog.alert('Please select a company first', { type: 'warning' });
            return;
        }

        // Calculate remaining percentage
        const usedPercent = this.editAllocations.reduce((sum, a) => sum + (a.allocation_percent || 0), 0);
        const remainingPercent = Math.max(0, 100 - usedPercent);

        this.editAllocations.push({
            company: company,
            brand: '',
            department: '',
            subdepartment: '',
            allocation_percent: remainingPercent,
            allocation_value: 0,
            locked: false
        });
        this.recalculateAllocationValues();
        this.renderEditAllocations();
    },

    // Render allocations
    renderEditAllocations() {
        const container = document.getElementById('allocationsContainer');
        const currency = document.getElementById('editCurrency').value || 'RON';

        if (this.editAllocations.length === 0) {
            container.innerHTML = '<p class="text-muted">No allocations. Click "Add Allocation" to add one.</p>';
            this.updateAllocationTotalBadge();
            return;
        }

        container.innerHTML = this.editAllocations.map((alloc, index) => {
            const brands = this.getBrandsForCompany(alloc.company);
            const departments = this.getDepartmentsForCompany(alloc.company);
            const manager = this.getManagerForDepartment(alloc.company, alloc.department, alloc.brand);
            const lockIcon = alloc.locked ? 'bi-lock-fill' : 'bi-unlock';
            const lockClass = alloc.locked ? 'btn-warning' : 'btn-outline-secondary';

            return `
            <div class="allocation-row border rounded p-3 mb-2" data-index="${index}">
                <div class="row g-2 align-items-end">
                    <div class="col-md-2">
                        <label class="form-label small mb-1">Brand</label>
                        <select class="form-select form-select-sm" onchange="InvoiceEdit.updateAllocationField(${index}, 'brand', this.value)">
                            <option value="">N/A</option>
                            ${brands.map(b => `<option value="${b}" ${alloc.brand === b ? 'selected' : ''}>${b}</option>`).join('')}
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small mb-1">Department</label>
                        <select class="form-select form-select-sm" onchange="InvoiceEdit.updateAllocationDepartment(${index}, this.value)" required>
                            <option value="">Select...</option>
                            ${departments.map(d => `<option value="${d}" ${alloc.department === d ? 'selected' : ''}>${d}</option>`).join('')}
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small mb-1">Allocation %</label>
                        <div class="input-group input-group-sm">
                            <input type="number" class="form-control" min="0" max="100" step="0.01"
                                value="${alloc.allocation_percent || 0}"
                                onchange="InvoiceEdit.updateAllocationField(${index}, 'allocation_percent', parseFloat(this.value))" required>
                            <span class="input-group-text">%</span>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small mb-1">Value (${currency})</label>
                        <input type="text" class="form-control form-control-sm" readonly
                            value="${this.formatCurrencyNoSymbol(alloc.allocation_value || 0)}">
                    </div>
                    <div class="col-md-3 d-flex align-items-end gap-1">
                        <button type="button" class="btn ${lockClass} btn-sm" onclick="InvoiceEdit.toggleLock(${index})" title="Lock/Unlock">
                            <i class="bi ${lockIcon}"></i>
                        </button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="InvoiceEdit.openAllocationComment(${index})" title="Comment">
                            <i class="bi bi-chat${alloc.comment ? '-fill text-primary' : ''}"></i>
                        </button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="InvoiceEdit.duplicateAllocation(${index})" title="Duplicate">
                            <i class="bi bi-copy"></i>
                        </button>
                        <button type="button" class="btn btn-outline-danger btn-sm" onclick="InvoiceEdit.removeAllocation(${index})" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </div>
                <div class="row g-2 mt-2">
                    <div class="col-md-3">
                        <small class="text-muted">Manager: ${manager || '--'}</small>
                    </div>
                    <div class="col-md-9">
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" id="reinvoice-${index}"
                                ${alloc.reinvoice_to ? 'checked' : ''}
                                onchange="InvoiceEdit.toggleReinvoice(${index}, this.checked)">
                            <label class="form-check-label small" for="reinvoice-${index}">Reinvoice to:</label>
                        </div>
                        ${alloc.reinvoice_to !== undefined && alloc.reinvoice_to !== null ? `
                        <select class="form-select form-select-sm d-inline-block" style="width: auto;"
                            onchange="InvoiceEdit.updateAllocationField(${index}, 'reinvoice_to', this.value)">
                            <option value="">Select company...</option>
                            ${this.companiesData.map(c => `<option value="${c.company}" ${alloc.reinvoice_to === c.company ? 'selected' : ''}>${c.company}</option>`).join('')}
                        </select>
                        ` : ''}
                    </div>
                </div>
            </div>`;
        }).join('');

        this.updateAllocationTotalBadge();
    },

    // Helper functions for organizational structure
    getBrandsForCompany(company) {
        if (!this.organizationalStructure || !company) return [];
        const brands = new Set();
        this.organizationalStructure.filter(s => s.company === company).forEach(s => {
            if (s.brand) brands.add(s.brand);
        });
        return Array.from(brands).sort();
    },

    getDepartmentsForCompany(company) {
        if (!this.organizationalStructure || !company) return [];
        const depts = new Set();
        this.organizationalStructure.filter(s => s.company === company).forEach(s => {
            if (s.department) depts.add(s.department);
        });
        return Array.from(depts).sort();
    },

    getManagerForDepartment(company, department, brand) {
        if (!this.organizationalStructure || !company || !department) return null;
        const match = this.organizationalStructure.find(s =>
            s.company === company &&
            s.department === department &&
            (!brand || s.brand === brand)
        );
        return match?.manager || null;
    },

    // Allocation field update handlers
    updateAllocationField(index, field, value) {
        this.editAllocations[index][field] = value;
        this.recalculateAllocationValues();
        if (field === 'allocation_percent') {
            this.renderEditAllocations();
        }
    },

    updateAllocationDepartment(index, value) {
        this.editAllocations[index].department = value;
        this.editAllocations[index].subdepartment = '';
        this.renderEditAllocations();
    },

    toggleLock(index) {
        this.editAllocations[index].locked = !this.editAllocations[index].locked;
        this.renderEditAllocations();
    },

    toggleReinvoice(index, checked) {
        this.editAllocations[index].reinvoice_to = checked ? '' : null;
        this.renderEditAllocations();
    },

    duplicateAllocation(index) {
        const original = this.editAllocations[index];
        this.editAllocations.push({...original, allocation_percent: 0, allocation_value: 0, locked: false});
        this.renderEditAllocations();
    },

    removeAllocation(index) {
        this.editAllocations.splice(index, 1);
        this.renderEditAllocations();
    },

    openAllocationComment(index) {
        const alloc = this.editAllocations[index];
        document.getElementById('allocationCommentIndex').value = index;
        document.getElementById('allocationCommentDetails').textContent =
            `${alloc.department || 'No department'} - ${alloc.brand || 'No brand'} (${alloc.allocation_percent || 0}%)`;
        document.getElementById('allocationCommentText').value = alloc.comment || '';

        const modal = new bootstrap.Modal(document.getElementById('allocationCommentModal'));
        modal.show();
    },

    saveAllocationComment() {
        const index = parseInt(document.getElementById('allocationCommentIndex').value);
        const comment = document.getElementById('allocationCommentText').value;
        this.editAllocations[index].comment = comment;

        bootstrap.Modal.getInstance(document.getElementById('allocationCommentModal')).hide();
        this.renderEditAllocations();
    },

    recalculateAllocationValues() {
        const invoiceValue = parseFloat(document.getElementById('editInvoiceValue').value) || 0;
        const subtractVat = document.getElementById('editSubtractVat').checked;
        const netValue = subtractVat ? parseFloat(document.getElementById('editNetValue').value) : null;
        const effectiveValue = subtractVat && netValue ? netValue : invoiceValue;

        this.editAllocations.forEach(a => {
            a.allocation_value = (effectiveValue * (a.allocation_percent || 0)) / 100;
        });
    },

    updateAllocationTotalBadge() {
        const total = this.editAllocations.reduce((sum, a) => sum + (a.allocation_percent || 0), 0);
        const totalValue = this.editAllocations.reduce((sum, a) => sum + (a.allocation_value || 0), 0);
        const currency = document.getElementById('editCurrency').value || 'RON';
        const badge = document.getElementById('allocationTotalBadge');

        if (badge) {
            badge.textContent = `${total.toFixed(2)}% | ${this.formatCurrencyNoSymbol(totalValue)} ${currency}`;
            badge.className = 'badge ms-2 ' + (Math.abs(total - 100) < 0.1 ? 'bg-success' : (total > 100 ? 'bg-danger' : 'bg-warning'));
        }
    },

    // Upload file
    async uploadFile() {
        const fileInput = document.getElementById('editInvoiceFile');
        const file = fileInput.files[0];

        if (!file) {
            JarvisDialog.alert('Please select a file first', { type: 'warning' });
            return;
        }

        const invoiceDate = document.getElementById('editInvoiceDate').value || '';
        const company = document.getElementById('editDedicatedCompany').value || 'Unknown Company';
        const invoiceNumber = document.getElementById('editInvoiceNumber').value || 'Unknown Invoice';

        const formData = new FormData();
        formData.append('file', file);
        formData.append('invoice_date', invoiceDate);
        formData.append('company', company);
        formData.append('invoice_number', invoiceNumber);

        const btn = document.getElementById('uploadEditFileBtn');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Uploading...';
        btn.disabled = true;

        try {
            const response = await fetch('/api/drive/upload', {
                method: 'POST',
                body: formData
            });
            const result = await response.json();

            if (result.success && result.drive_link) {
                document.getElementById('editDriveLink').value = result.drive_link;
                JarvisToast.success('File uploaded successfully to Google Drive!');
                fileInput.value = '';
            } else {
                JarvisDialog.alert('Upload failed: ' + (result.error || 'Unknown error'), { type: 'error' });
            }
        } catch (e) {
            JarvisDialog.alert('Upload error: ' + e.message, { type: 'error' });
        } finally {
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    },

    // Save invoice
    async saveInvoice() {
        const invoiceId = document.getElementById('editInvoiceId').value;
        const totalPercent = this.editAllocations.reduce((sum, a) => sum + (a.allocation_percent || 0), 0);

        // Validate allocations
        if (totalPercent < 100 || totalPercent > 100.1) {
            JarvisDialog.alert(`Allocations must sum to 100% (max 0.1% overdraft allowed). Current total: ${totalPercent.toFixed(2)}%`, { type: 'warning', title: 'Validation Error' });
            return;
        }

        if (this.editAllocations.some(a => !a.department)) {
            JarvisDialog.alert('All allocations must have a department', { type: 'warning', title: 'Validation Error' });
            return;
        }

        this.recalculateAllocationValues();

        const subtractVat = document.getElementById('editSubtractVat').checked;
        const vatRateSelect = document.getElementById('editVatRateId');
        const selectedOption = vatRateSelect.options[vatRateSelect.selectedIndex];
        const vatRate = subtractVat && selectedOption && selectedOption.dataset.rate ? parseFloat(selectedOption.dataset.rate) : null;
        const vatRateId = subtractVat && vatRateSelect.value ? parseInt(vatRateSelect.value) : null;
        const netValue = subtractVat ? parseFloat(document.getElementById('editNetValue').value) : null;
        const dedicatedCompany = document.getElementById('editDedicatedCompany').value;

        const invoiceData = {
            supplier: document.getElementById('editSupplier').value,
            invoice_number: document.getElementById('editInvoiceNumber').value,
            invoice_date: document.getElementById('editInvoiceDate').value,
            invoice_value: parseFloat(document.getElementById('editInvoiceValue').value),
            currency: document.getElementById('editCurrency').value,
            drive_link: document.getElementById('editDriveLink').value,
            comment: document.getElementById('editComment').value,
            status: document.getElementById('editStatus').value,
            payment_status: document.getElementById('editPaymentStatus').value,
            subtract_vat: subtractVat,
            vat_rate: vatRate,
            vat_rate_id: vatRateId,
            net_value: netValue
        };

        const allocationsData = this.editAllocations.map(a => ({
            company: dedicatedCompany,
            brand: a.brand || null,
            department: a.department,
            subdepartment: a.subdepartment || null,
            allocation_percent: a.allocation_percent,
            allocation_value: a.allocation_value,
            responsible: a.responsible || null,
            reinvoice_to: a.reinvoice_to || null,
            comment: a.comment || null,
            locked: a.locked || false
        }));

        if (typeof showLoading === 'function') showLoading('Saving invoice...');

        try {
            // Save invoice details
            const invoiceRes = await fetch(`/api/db/invoices/${invoiceId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(invoiceData)
            });
            const invoiceResult = await invoiceRes.json();

            if (!invoiceResult.success && invoiceRes.status !== 404) {
                JarvisDialog.alert('Error updating invoice: ' + (invoiceResult.error || 'Unknown error'), { type: 'error' });
                return;
            }

            // Save allocations
            const sendNotification = document.getElementById('sendNotificationToggle').checked;
            const allocRes = await fetch(`/api/db/invoices/${invoiceId}/allocations`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ allocations: allocationsData, send_notification: sendNotification })
            });
            const allocResult = await allocRes.json();

            if (allocResult.success) {
                bootstrap.Modal.getInstance(document.getElementById('editInvoiceModal')).hide();

                // Call the callback if provided
                if (this.onSaveCallback) {
                    await this.onSaveCallback();
                }

                JarvisToast.success('Invoice and allocations updated successfully!');
            } else {
                JarvisDialog.alert('Error updating allocations: ' + (allocResult.error || 'Unknown error'), { type: 'error' });
            }
        } catch (e) {
            JarvisDialog.alert('Error: ' + e.message, { type: 'error' });
        } finally {
            if (typeof hideLoading === 'function') hideLoading();
        }
    },

    // Formatting helpers
    formatCurrency(value, currency = 'RON') {
        return new Intl.NumberFormat('ro-RO', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0) + ' ' + currency;
    },

    formatCurrencyNoSymbol(value) {
        return new Intl.NumberFormat('ro-RO', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0);
    },

    formatDateRomanian(dateStr) {
        if (!dateStr) return '-';
        const d = new Date(dateStr);
        if (isNaN(d.getTime())) return '-';
        return d.toLocaleDateString('ro-RO');
    },

    getStatusClass(status) {
        const classes = {
            'Nebugetata': 'bg-danger',
            'New': 'bg-info',
            'new': 'bg-info',
            'Processing': 'bg-warning text-dark',
            'Processed': 'bg-success',
            'processed': 'bg-success',
            'incomplete': 'bg-secondary'
        };
        return classes[status] || 'bg-secondary';
    }
};

// Export for global access
window.InvoiceEdit = InvoiceEdit;

// Shortcut functions for use in onclick handlers
function viewInvoice(id) { InvoiceEdit.viewInvoice(id); }
function editInvoice(id) { InvoiceEdit.openEditModal(id); }
