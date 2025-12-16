# Bugetare Agent Definitions

Specialized agent prompts for different types of work on the Bugetare application.

---

## UI Agent

### Role
Frontend specialist focused on user interface and user experience improvements.

### Context Files
- `app/templates/accounting.html` - Main dashboard
- `app/templates/index.html` - Add Invoice page
- `app/templates/settings.html` - Settings page
- `CONTEXT.md` - Business workflow understanding

### Responsibilities
1. Implement UI features using Bootstrap 5 and vanilla JavaScript
2. Maintain responsive design across devices
3. Ensure consistent styling and UX patterns
4. Handle client-side validation and feedback
5. Optimize perceived performance (loading states, transitions)

### Conventions
- Use Bootstrap 5 classes for styling
- Keep JavaScript inline in `<script>` tags (no build step)
- Use `async/await` for API calls with `fetch()`
- Show loading spinners during async operations
- Use modals for edit/detail views
- Store user preferences in `localStorage`
- Format dates as Romanian `DD.MM.YYYY` for display
- Format currency with thousands separator and 2 decimals

### Common Patterns
```javascript
// API call pattern
async function loadData() {
    showLoading('Loading...');
    try {
        const res = await fetch('/api/endpoint');
        const data = await res.json();
        renderData(data);
    } catch (e) {
        console.error('Error:', e);
        alert('Failed to load data');
    } finally {
        hideLoading();
    }
}

// Format currency
function formatCurrency(value) {
    return new Intl.NumberFormat('ro-RO', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }).format(value);
}

// Format Romanian date
function formatDateRomanian(isoDate) {
    if (!isoDate) return '-';
    const [y, m, d] = isoDate.split('-');
    return `${d}.${m}.${y}`;
}
```

### UI Components
- **Tables**: Sortable, configurable columns, pagination
- **Modals**: Bootstrap modals for forms and details
- **Forms**: Real-time validation, lock/unlock icons
- **Cards**: Summary statistics with toggle switches
- **Dropdowns**: Cascading filters (company → department → subdepartment)

---

## Developer Agent

### Role
Backend specialist focused on API development, database operations, and business logic.

### Context Files
- `app/app.py` - Flask routes and API endpoints
- `app/database.py` - PostgreSQL operations
- `app/invoice_parser.py` - AI parsing logic
- `app/services.py` - Business logic
- `CLAUDE.md` - Technical reference

### Responsibilities
1. Implement API endpoints following REST conventions
2. Write efficient database queries with proper indexing
3. Manage database migrations safely
4. Handle error cases and validation
5. Maintain connection pool health

### Conventions
- Use `@app.route()` decorators for endpoints
- Return JSON with `jsonify()` for APIs
- Use `@login_required` for authenticated routes
- Use connection pool: `get_db()` / `release_db()`
- Log user events for audit trail
- Handle both happy path and error cases

### API Patterns
```python
# GET endpoint
@app.route('/api/items')
@login_required
def get_items():
    items = get_all_items()
    return jsonify(items)

# POST endpoint
@app.route('/api/items', methods=['POST'])
@login_required
def create_item():
    data = request.get_json()
    if not data.get('name'):
        return jsonify({'success': False, 'error': 'Name required'}), 400

    item_id = save_item(data)
    log_event('item_created', entity_type='item', entity_id=item_id)
    return jsonify({'success': True, 'id': item_id})

# PUT endpoint
@app.route('/api/items/<int:item_id>', methods=['PUT'])
@login_required
def update_item(item_id):
    data = request.get_json()
    update_item_in_db(item_id, data)
    log_event('item_updated', entity_type='item', entity_id=item_id)
    return jsonify({'success': True})
```

### Database Patterns
```python
# Query with connection pool
def get_all_items():
    conn = get_db()
    cursor = get_cursor(conn)
    cursor.execute('SELECT * FROM items ORDER BY created_at DESC')
    results = cursor.fetchall()
    release_db(conn)
    return [dict_from_row(r) for r in results]

# Safe migration pattern
cursor.execute('''
    ALTER TABLE items
    ADD COLUMN IF NOT EXISTS new_field TEXT
''')
```

### Error Handling
```python
try:
    # Operation
    pass
except Exception as e:
    conn.rollback()
    return jsonify({'success': False, 'error': str(e)}), 500
finally:
    release_db(conn)
```

---

## Test Agent

### Role
Quality assurance specialist focused on testing and validation.

### Context Files
- `CLAUDE.md` - Feature documentation
- `CONTEXT.md` - Business requirements
- Production URL: `https://bugetare-mkt-t6fk7.ondigitalocean.app`

### Responsibilities
1. Test features against requirements
2. Verify API endpoints return correct data
3. Test edge cases and error handling
4. Validate UI behavior across scenarios
5. Performance testing and monitoring

### Test Categories

#### API Testing
```bash
# Health check
curl -s https://bugetare-mkt-t6fk7.ondigitalocean.app/health

# Login and get session
curl -s -c cookies.txt -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=user@example.com&password=pass" \
  https://bugetare-mkt-t6fk7.ondigitalocean.app/login

# Test authenticated endpoint
curl -s -b cookies.txt \
  https://bugetare-mkt-t6fk7.ondigitalocean.app/api/db/invoices
```

#### Performance Testing
```bash
# Measure response times
curl -s -o /dev/null -w "Time: %{time_total}s\n" \
  https://bugetare-mkt-t6fk7.ondigitalocean.app/login

# Test compression
curl -s -H "Accept-Encoding: gzip" -o /tmp/compressed.html \
  https://bugetare-mkt-t6fk7.ondigitalocean.app/accounting
```

#### Validation Checklist
- [ ] Feature works as documented
- [ ] API returns expected format
- [ ] Error cases handled gracefully
- [ ] UI updates correctly after operations
- [ ] Data persists after page reload
- [ ] Concurrent access handled properly

### Test Scenarios

#### Invoice Creation
1. Upload PDF invoice
2. Verify AI parsing extracts correct data
3. Add allocations (verify sum = 100%)
4. Save and verify in database
5. Check email notification sent
6. Verify Drive upload

#### VAT Subtraction
1. Create invoice with VAT subtraction enabled
2. Verify net value calculation
3. Verify allocation values use net value
4. Edit invoice, toggle VAT - verify recalculation
5. Change department - verify values stay correct

#### Pagination
1. Load accounting page
2. Verify pagination controls appear
3. Change page size (25/50/100/All)
4. Navigate pages
5. Apply filters - verify pagination resets

---

## Using Agents

### Invoke Agent Mode
When asking Claude to work in a specific mode:

```
"As the UI Agent, add a search box to the accounting page"

"As the Developer Agent, create an API endpoint to export invoices"

"As the Test Agent, verify the VAT subtraction feature works correctly"
```

### Multi-Agent Workflow
For complex features, use multiple agents:

1. **Developer Agent**: Design and implement API
2. **UI Agent**: Build frontend interface
3. **Test Agent**: Validate end-to-end

### Agent Handoff
When transitioning between agents, provide context:

```
"The Developer Agent has created the /api/export endpoint.
As the UI Agent, add an Export button to the accounting page that calls this endpoint."
```
