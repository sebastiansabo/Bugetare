# Software Development Agent Prompt: Bank Statement Module Upgrades

## Context

You are working on the J.A.R.V.I.S. enterprise platform, specifically the Bank Statement module located in `jarvis/accounting/statements/`. This module parses UniCredit bank statement PDFs, matches transactions to vendors, and generates invoice records.

**Tech Stack:** Flask, PostgreSQL, Bootstrap 5, vanilla JavaScript

**Key Files:**
- `jarvis/accounting/statements/routes.py` - API endpoints
- `jarvis/accounting/statements/parser.py` - PDF parsing logic
- `jarvis/accounting/statements/vendors.py` - Vendor pattern matching
- `jarvis/accounting/statements/database.py` - CRUD operations
- `jarvis/templates/accounting/statements/index.html` - Main UI

---

## Tasks to Implement

Complete the following upgrades in priority order. Mark each task complete before moving to the next.

---

### HIGH PRIORITY

#### Task 1: Create Missing Mappings Template

Create `jarvis/templates/accounting/statements/mappings.html` for the vendor mappings management page.

Requirements:
- Extend base template like other accounting templates
- Display table of existing vendor mappings (pattern, supplier_name, template_id, created_at)
- Add form to create new mapping with fields: pattern (regex), supplier_name, template_id (dropdown)
- Edit functionality (inline or modal)
- Delete with confirmation
- Test regex pattern button (validates pattern and shows preview match)
- Use existing API endpoints: GET/POST/PUT/DELETE `/statements/api/mappings`
- Follow the UI patterns from `index.html` (Bootstrap 5, similar styling)

---

#### Task 2: Add Database Indexes

Add indexes to `bank_statement_transactions` table for commonly filtered columns.

In `jarvis/accounting/statements/database.py`, update `init_statements_tables()` to include:
```sql
CREATE INDEX IF NOT EXISTS idx_transactions_status ON bank_statement_transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON bank_statement_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_transactions_supplier ON bank_statement_transactions(matched_supplier);
CREATE INDEX IF NOT EXISTS idx_transactions_company ON bank_statement_transactions(company_cui);
```

---

#### Task 3: Implement File Size Limits

Add PDF upload size validation to prevent DoS attacks.

Requirements:
- Maximum file size: 10MB per file
- Maximum total upload: 50MB per request
- Validate in both frontend (before upload) and backend (in upload route)
- Return clear error message: "File {filename} exceeds maximum size of 10MB"
- Update `jarvis/accounting/statements/routes.py` upload endpoint
- Update `jarvis/templates/accounting/statements/index.html` JavaScript validation

---

### MEDIUM PRIORITY

#### Task 4: Add Pagination UI

The backend already supports `limit` and `offset` parameters. Add pagination to the frontend.

Requirements:
- Add pagination controls below transaction table
- Show: "Showing X-Y of Z transactions"
- Page size selector: 50, 100, 250, 500
- Previous/Next buttons with page numbers
- Preserve current filters when paginating
- Store page size preference in localStorage
- Update `loadTransactions()` function in `index.html`

---

#### Task 5: Improve Error Messages

Enhance error responses with more context.

Requirements:
- In `routes.py`, differentiate HTTP status codes:
  - 400 for bad request (missing required fields)
  - 422 for validation errors (invalid regex pattern, invalid data format)
  - 500 for server errors (database failures)
- Include field-specific error messages in response:
  ```json
  {"success": false, "error": "Validation failed", "details": {"pattern": "Invalid regex syntax"}}
  ```
- Add null checks for `request.get_json()` calls
- Log errors with full context before returning response

---

#### Task 6: Add CSV Export

Add ability to export transactions to CSV format.

Requirements:
- New endpoint: `GET /statements/api/export/csv`
- Accept same filter parameters as transaction list
- Export columns: date, description, amount, currency, status, matched_supplier, company
- Filename format: `transactions_YYYY-MM-DD.csv`
- Add "Export CSV" button next to filters in UI
- Use Python's `csv` module with proper escaping

---

#### Task 7: Write Unit Tests

Create test file `tests/test_statements.py` with unit tests.

Test coverage for:
- `parser.py`:
  - `parse_value()` with various European number formats
  - `parse_date()` with valid and invalid dates
  - `parse_unicredit_statement()` with mock PDF content
- `vendors.py`:
  - `match_vendor()` with known patterns
  - `match_vendor()` with unmatched descriptions
  - `extract_vendor_name()` logic
- `database.py`:
  - `check_duplicate_transaction()`
  - `save_transactions()` with duplicates

Use pytest. Mock database connections using `unittest.mock`.

---

### LOW PRIORITY

#### Task 8: Toast Notifications

Replace JavaScript `alert()` calls with toast notifications.

Requirements:
- Create reusable toast component (success, error, warning, info variants)
- Position: top-right corner, auto-dismiss after 5 seconds
- Stack multiple toasts if needed
- Replace all `alert()` calls in `index.html`
- Use Bootstrap 5 toast component

---

#### Task 9: Inline Transaction Editing

Add ability to edit transaction status inline without buttons.

Requirements:
- Add status dropdown in each transaction row
- Options: pending, matched, ignored, invoiced
- Auto-save on change (debounced)
- Show loading spinner during save
- Revert on error with toast notification
- Keep existing Ignore/Restore buttons as alternative

---

#### Task 10: Rate Limiting for Bulk Operations

Add rate limiting to prevent abuse of bulk endpoints.

Requirements:
- Limit bulk operations to 100 items per request
- Limit to 10 bulk requests per minute per user
- Return 429 Too Many Requests when exceeded
- Affected endpoints:
  - `POST /statements/api/transactions/bulk-ignore`
  - `POST /statements/api/create-invoices`
- Use in-memory rate limiting (no Redis needed for internal app)

---

## Implementation Notes

1. **Follow existing patterns**: Match the code style, naming conventions, and structure of existing files
2. **Maintain backwards compatibility**: Don't break existing functionality
3. **Test locally**: Use `DATABASE_URL='postgresql://...' PORT=5001 python jarvis/app.py`
4. **Commit incrementally**: One commit per task with descriptive message
5. **Update CLAUDE.md**: If adding new routes or significant features, document them

## Definition of Done

- [ ] All tasks implemented and tested locally
- [ ] No Python linting errors
- [ ] JavaScript console has no errors
- [ ] All existing functionality still works
- [ ] Code follows project conventions
