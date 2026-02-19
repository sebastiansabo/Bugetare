# Database Schema

PostgreSQL database with `pg_trgm` extension for fuzzy text search. Schema auto-creates on first boot via `init_db()`.

## Table Overview

| Module | Tables | Key Tables |
|--------|--------|------------|
| Core/Accounting | 13 | invoices, allocations, bank_statements, bank_statement_transactions |
| Users & Auth | 8 | users, roles, permissions_v2, role_permissions_v2 |
| Tags | 4 | tag_groups, tags, entity_tags, auto_tag_rules |
| e-Factura | 10 | efactura_invoices, efactura_supplier_mappings, efactura_sync_runs |
| HR | 3 (+hr schema) | hr.events, hr.event_bonuses, hr.bonus_types |
| Approvals | 6 | approval_flows, approval_steps, approval_requests, approval_decisions |
| Notifications | 2 | notifications, smart_notification_state |
| Marketing | 14 | mkt_projects, mkt_budget_lines, mkt_project_kpis, mkt_objectives |
| **Total** | **~60** | |

---

## Core/Accounting

### invoices
Primary invoice table. Supports soft delete (`deleted_at`).

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| supplier | TEXT | NOT NULL |
| invoice_number | TEXT | NOT NULL, UNIQUE |
| invoice_date | DATE | NOT NULL |
| invoice_value | NUMERIC(15,2) | NOT NULL |
| currency | TEXT | DEFAULT 'RON' |
| value_ron, value_eur | NUMERIC(15,2) | |
| exchange_rate | NUMERIC(10,6) | |
| status | TEXT | DEFAULT 'new' |
| payment_status | TEXT | DEFAULT 'not_paid' |
| vat_rate | NUMERIC(5,2) | |
| line_items | JSONB | |
| invoice_type | TEXT | DEFAULT 'standard' |
| deleted_at | TIMESTAMP | Soft delete |
| created_at, updated_at | TIMESTAMP | |

### allocations
Invoice allocation to company/department/brand.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| invoice_id | INTEGER | FK → invoices(id) CASCADE |
| company | TEXT | NOT NULL |
| department | TEXT | NOT NULL |
| brand | TEXT | |
| allocation_percent | NUMERIC(7,4) | NOT NULL |
| allocation_value | NUMERIC(15,2) | NOT NULL |
| responsible_user_id | INTEGER | FK → users(id) |
| locked | BOOLEAN | DEFAULT FALSE |

### bank_statements
Uploaded bank statement files.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| filename | TEXT | NOT NULL |
| file_hash | TEXT | UNIQUE |
| company_name, company_cui | TEXT | |
| account_number | TEXT | |
| period_from, period_to | DATE | |
| uploaded_by | INTEGER | FK → users(id) |

### bank_statement_transactions
Individual transactions parsed from statements.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| statement_id | INTEGER | FK → bank_statements(id) |
| transaction_date | DATE | |
| amount | NUMERIC(15,2) | |
| description, vendor_name | TEXT | |
| status | TEXT | DEFAULT 'pending' |
| invoice_id | INTEGER | FK → invoices(id) — linked |
| suggested_invoice_id | INTEGER | FK → invoices(id) — suggestion |
| is_merged_result | BOOLEAN | |
| merged_into_id | INTEGER | FK → self(id) |

---

## Users & Auth

### users

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| name, email | TEXT | NOT NULL, email UNIQUE |
| password_hash | TEXT | |
| role_id | INTEGER | FK → roles(id) |
| is_active | BOOLEAN | DEFAULT TRUE |
| company, brand, department | TEXT | Org assignment |
| org_unit_id | INTEGER | FK → department_structure(id) |

### roles
13 legacy boolean permission columns + name/description.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| name | TEXT | NOT NULL, UNIQUE |
| can_access_settings | BOOLEAN | V1 admin flag |
| can_view/add/edit/delete_invoices | BOOLEAN | V1 invoice perms |
| can_access_hr, is_hr_manager | BOOLEAN | V1 HR flags |

**Seeded:** Admin, Manager, User, Viewer

### permissions_v2
Enhanced permission matrix: module.entity.action with optional scope.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| module_key, entity_key, action_key | TEXT | UNIQUE together |
| module_label, entity_label, action_label | TEXT | Display names |
| is_scope_based | BOOLEAN | TRUE = supports scope filtering |

**Modules:** system, invoices, accounting, efactura, statements, hr, ai_agent, approvals, marketing

### role_permissions_v2

| Column | Type | Constraints |
|--------|------|-------------|
| role_id | INTEGER | FK → roles(id) CASCADE |
| permission_id | INTEGER | FK → permissions_v2(id) CASCADE |
| scope | ENUM | deny, own, department, all |
| granted | BOOLEAN | |

---

## Tags

### tag_groups
Grouping container for tags (Priority, Status, Category).

### tags
Individual tags with color/icon. Can be global or user-scoped.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| group_id | INTEGER | FK → tag_groups(id) SET NULL |
| name | VARCHAR(100) | NOT NULL |
| color | VARCHAR(7) | DEFAULT '#0d6efd' |
| is_global | BOOLEAN | |
| created_by | INTEGER | FK → users(id) CASCADE |

### entity_tags
Polymorphic join table — tags any entity type.

| Column | Type | Constraints |
|--------|------|-------------|
| tag_id | INTEGER | FK → tags(id) CASCADE |
| entity_type | VARCHAR(30) | invoice, allocation, hr_event, statement, efactura_invoice, mkt_project |
| entity_id | INTEGER | |

**Unique:** (tag_id, entity_type, entity_id)

### auto_tag_rules
Condition-based auto-tagging rules.

| Column | Type | Constraints |
|--------|------|-------------|
| tag_id | INTEGER | FK → tags(id) CASCADE |
| entity_type | VARCHAR(30) | |
| conditions | JSONB | Array of {field, operator, value} |
| match_mode | VARCHAR(10) | 'all' or 'any' |
| run_on_create | BOOLEAN | DEFAULT TRUE |

---

## e-Factura

### efactura_invoices
Invoices from ANAF e-Factura system. Three states: unallocated, hidden (`ignored=TRUE`), deleted (`deleted_at`).

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| cif_owner | VARCHAR(20) | NOT NULL |
| company_id | INTEGER | FK → companies(id) |
| direction | VARCHAR(20) | 'received' or 'sent' |
| partner_cif, partner_name | VARCHAR | |
| invoice_number, invoice_series | VARCHAR | |
| total_amount, total_vat | NUMERIC(15,2) | |
| jarvis_invoice_id | INTEGER | FK → invoices(id) SET NULL — allocated |
| type_override, department_override | VARCHAR(255) | Override supplier mapping |
| xml_content | TEXT | Raw XML |
| ignored | BOOLEAN | DEFAULT FALSE — hidden flag |
| deleted_at | TIMESTAMP | Soft delete |

**Trigram indexes** on partner_name, partner_cif, invoice_number for ILIKE search.

### efactura_invoice_refs
ANAF message/upload/download IDs for deduplication.

### efactura_invoice_artifacts
Stored files (ZIP, XML, PDF, signature) per invoice.

### efactura_company_connections
Company-to-ANAF connection config (CIF, environment, sync cursors, cert metadata).

### efactura_supplier_mappings
Maps e-Factura partner names to internal supplier names + department defaults.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| partner_name | VARCHAR(255) | NOT NULL |
| partner_cif | VARCHAR(50) | |
| supplier_name | VARCHAR(255) | NOT NULL |
| department, subdepartment, brand | VARCHAR(255) | |
| type_id | INTEGER | FK → supplier_types(id) |

**Unique:** (partner_name, partner_cif)

### efactura_supplier_types
Supplier categories (Service, Merchandise). `hide_in_filter=TRUE` hides from unallocated view.

### efactura_supplier_mapping_types
Junction table: mapping ↔ type (M:N).

### efactura_sync_runs / efactura_sync_errors
Sync tracking with per-run counters and error logs.

---

## HR (hr schema)

### hr.events
Company events with date ranges.

### hr.event_bonuses
Employee bonuses linked to events. Includes year/month, bonus_days, hours_free, bonus_net.

### hr.bonus_types
Bonus type definitions with amount and days_per_amount.

---

## Approvals

### approval_flows
Named workflow definitions with entity_type targeting.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| name, slug | TEXT | slug UNIQUE |
| entity_type | TEXT | invoice, mkt_project, etc. |
| trigger_conditions | JSONB | |
| auto_approve_below | NUMERIC(15,2) | |
| auto_reject_after_hours | INTEGER | |

### approval_steps
Ordered steps within a flow.

| Column | Type | Constraints |
|--------|------|-------------|
| flow_id | INTEGER | FK → approval_flows(id) CASCADE |
| step_order | INTEGER | |
| approver_type | TEXT | user, role, department_manager, context_approver |
| approver_user_id | INTEGER | FK → users(id) |
| approver_role_name | TEXT | |
| timeout_hours | INTEGER | |

### approval_requests
Submitted approval requests with status tracking.

| Column | Type | Constraints |
|--------|------|-------------|
| entity_type, entity_id | TEXT, INTEGER | What's being approved |
| flow_id | INTEGER | FK → approval_flows(id) |
| current_step_id | INTEGER | FK → approval_steps(id) |
| status | TEXT | pending, in_progress, approved, rejected, cancelled, expired |
| context_snapshot | JSONB | Runtime context (e.g., approver_user_id) |
| requested_by | INTEGER | FK → users(id) |

### approval_decisions
Individual step decisions (approved, rejected, returned, delegated).

### approval_audit_log
Full audit trail of all approval actions.

### approval_delegations
Temporary delegation of approval authority between users.

---

## Notifications

### notifications
In-app notification center.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| user_id | INTEGER | FK → users(id) CASCADE |
| type | TEXT | info, warning, error, success |
| title | TEXT | NOT NULL |
| message, link | TEXT | |
| entity_type | TEXT | |
| entity_id | INTEGER | |
| is_read | BOOLEAN | DEFAULT FALSE |

### smart_notification_state
Deduplication state for AI-powered smart alerts (KPI thresholds, budget utilization).

---

## Marketing

### mkt_projects
Marketing projects with multi-company/brand/department arrays.

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PK |
| name, slug | TEXT | slug UNIQUE |
| company_ids, brand_ids, department_ids | INTEGER[] | |
| project_type | TEXT | campaign, always_on, event, launch, branding, research |
| channel_mix | TEXT[] | |
| status | TEXT | draft → pending_approval → approved → active → completed |
| total_budget | NUMERIC(15,2) | |
| owner_id | INTEGER | FK → users(id) |

### mkt_budget_lines
Budget allocation by channel with planned/approved/spent tracking.

### mkt_budget_transactions
Individual budget transactions (debit/credit) with optional invoice linking.

### mkt_kpi_definitions
Reusable KPI definitions (CPA, ROAS, CTR, etc.) with formulas and benchmarks.

### mkt_project_kpis
KPI instances per project with target/current values and threshold alerts.

### mkt_kpi_snapshots
Time-series KPI value recordings for sparklines and history charts.

### mkt_objectives / mkt_key_results
OKR system. Objectives contain key results; KRs can link to KPIs.

| Column (mkt_key_results) | Type | Constraints |
|---------------------------|------|-------------|
| objective_id | INTEGER | FK → mkt_objectives(id) CASCADE |
| linked_kpi_id | INTEGER | FK → mkt_project_kpis(id) SET NULL |
| target_value, current_value | NUMERIC(15,4) | |
| unit | TEXT | DEFAULT 'number' |

### mkt_project_members / comments / files / activity / events
Standard project collaboration tables (team, threaded comments, file attachments, activity log, HR event linking).

### mkt_sim_benchmarks
Campaign simulator benchmark data: 24 channels × 3 funnel stages × 3 months.

---

## Key Design Patterns

| Pattern | Tables | Notes |
|---------|--------|-------|
| Soft delete | invoices, efactura_invoices, mkt_projects | `deleted_at` timestamp |
| Polymorphic | entity_tags | `entity_type` + `entity_id` |
| JSONB | approval conditions, tag rules, project metadata | Flexible nested data |
| Array columns | mkt_projects (company_ids, brand_ids, channel_mix) | PostgreSQL INTEGER[] / TEXT[] |
| Junction table | supplier_mapping_types, mkt_kpi_budget_lines | M:N relationships |
| Trigram search | efactura partner/invoice fields | GIN indexes with pg_trgm |
| Scope-based perms | role_permissions_v2 | ENUM: deny, own, department, all |
| Context snapshot | approval_requests | JSONB for runtime-selected approvers |

## Indexes

100+ indexes covering:
- **Single-column:** status, date, user_id, created_at (most tables)
- **Composite:** (deleted_at, invoice_date), (invoice_id, company)
- **Unique:** email, slug, invoice_number, file_hash
- **Partial:** `WHERE deleted_at IS NULL`, `WHERE is_active=TRUE`
- **Trigram (GIN):** partner names, invoice numbers, supplier names
