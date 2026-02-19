# API Reference

All endpoints require authentication via session cookie unless marked Public. Responses use JSON format:

```json
{"success": true, "data": {...}}
{"success": false, "error": "message"}
```

## Authentication & Users (`/auth`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET/POST | `/login` | Login page & handler | Public |
| GET | `/logout` | Logout | Session |
| GET/POST | `/forgot-password` | Password reset request | Public |
| GET/POST | `/reset-password/<token>` | Password reset handler | Public |
| GET | `/api/auth/current-user` | Current user info + permissions | Public |
| POST | `/api/auth/change-password` | Change own password | Session |
| POST | `/api/heartbeat` | Update last_seen | Session |
| GET | `/api/online-users` | Online users (3 min window) | Session |
| GET | `/api/users` | List all users | Session |
| GET | `/api/users/<id>` | Get user (self or admin) | Session |
| POST | `/api/users` | Create user | Admin |
| PUT | `/api/users/<id>` | Update user | Admin |
| DELETE | `/api/users/<id>` | Delete user | Admin |
| POST | `/api/users/bulk-delete` | Bulk delete | Admin |
| GET | `/api/employees` | List employees | Session |
| GET | `/api/employees/<id>` | Get employee (self or admin) | Session |
| POST | `/api/employees` | Create employee | Admin |
| PUT | `/api/employees/<id>` | Update employee | Admin |
| DELETE | `/api/employees/<id>` | Delete employee | Admin |
| POST | `/api/auth/update-profile` | Update own profile | Session |
| POST | `/api/users/<id>/set-password` | Admin set password | Admin |
| POST | `/api/users/set-default-passwords` | Bulk set defaults | Admin |
| GET | `/api/events` | User audit log | Admin |
| GET | `/api/events/types` | Distinct event types | Admin |

## Roles & Permissions (`/roles`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/roles` | List roles | Session |
| GET | `/api/roles/<id>` | Get role | Session |
| POST | `/api/roles` | Create role | Admin |
| PUT | `/api/roles/<id>` | Update role | Admin |
| DELETE | `/api/roles/<id>` | Delete role | Admin |
| GET | `/api/permissions` | Permission tree (v1) | Session |
| GET | `/api/permissions/flat` | Flat permission list (v1) | Session |
| GET | `/api/roles/<id>/permissions` | Role permissions (v1) | Session |
| PUT | `/api/roles/<id>/permissions` | Set role permissions (v1) | Admin |
| GET | `/api/permissions/matrix` | Permission matrix (v2) | Session |
| GET | `/api/roles/<id>/permissions/v2` | Role permissions (v2) | Session |
| PUT | `/api/roles/<id>/permissions/v2` | Set role permissions (v2) | Admin |
| PUT | `/api/permissions/v2/<perm_id>/role/<role_id>` | Set single permission | Admin |

## Organization (`/organization`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/companies` | List companies | Session |
| GET | `/api/brands/<company>` | Brands for company | Session |
| GET | `/api/departments/<company>` | Departments for company | Session |
| GET | `/api/subdepartments/<company>/<dept>` | Subdepartments | Session |
| GET | `/api/company-for-department/<dept>` | Company lookup | Session |
| GET | `/api/manager` | Manager for department | Session |
| GET | `/api/companies-vat` | Companies with VAT | Session |
| POST | `/api/companies-vat` | Add company VAT | Session |
| PUT | `/api/companies-vat/<company>` | Update VAT | Session |
| DELETE | `/api/companies-vat/<company>` | Delete company | Session |
| GET | `/api/match-vat/<vat>` | Match VAT to company | Session |
| GET | `/api/companies-config` | Companies for config | Session |
| POST | `/api/companies-config` | Create company | Session |
| PUT | `/api/companies-config/<id>` | Update company | Session |
| DELETE | `/api/companies-config/<id>` | Delete company | Session |
| GET | `/api/department-structures` | All structures | Session |
| POST | `/api/department-structures` | Create structure | Session |
| PUT | `/api/department-structures/<id>` | Update structure | Session |
| DELETE | `/api/department-structures/<id>` | Delete structure | Session |
| GET | `/api/department-structures/unique-departments` | Unique depts | Session |
| GET | `/api/department-structures/unique-brands` | Unique brands | Session |

## Settings (`/settings`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/themes` | List themes | Session |
| GET | `/api/themes/active` | Active theme | Public |
| POST | `/api/themes` | Create theme | Admin |
| PUT | `/api/themes/<id>` | Update theme | Admin |
| DELETE | `/api/themes/<id>` | Delete theme | Admin |
| POST | `/api/themes/<id>/activate` | Activate theme | Admin |
| GET | `/api/module-menu` | Menu items (filtered) | Session |
| GET | `/api/module-menu/all` | All menu items | Session |
| POST | `/api/module-menu` | Create menu item | Admin |
| PUT | `/api/module-menu/<id>` | Update menu item | Admin |
| DELETE | `/api/module-menu/<id>` | Delete menu item | Admin |
| POST | `/api/module-menu/reorder` | Reorder menu | Admin |
| GET | `/api/vat-rates` | List VAT rates | Session |
| POST | `/api/vat-rates` | Create VAT rate | Admin |
| PUT | `/api/vat-rates/<id>` | Update VAT rate | Admin |
| DELETE | `/api/vat-rates/<id>` | Delete VAT rate | Admin |
| GET | `/api/dropdown-options` | Dropdown options | Session |
| POST | `/api/dropdown-options` | Add option | Admin |
| PUT | `/api/dropdown-options/<id>` | Update option | Admin |
| DELETE | `/api/dropdown-options/<id>` | Delete option | Admin |

## Invoices (`/accounting`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/submit` | Submit new invoice | can_add_invoices |
| POST | `/api/parse-invoice` | Parse uploaded file | can_add_invoices |
| GET | `/api/parse-existing/<path>` | Parse existing file | can_add_invoices |
| GET | `/api/suggest-department` | AI department suggest | can_add_invoices |
| GET | `/api/invoices` | List invoices (Drive) | Session |
| GET | `/api/db/invoices` | List invoices (DB) | can_view_invoices |
| GET | `/api/db/invoices/<id>` | Invoice detail | can_view_invoices |
| PUT | `/api/db/invoices/<id>` | Update invoice | can_edit_invoices |
| DELETE | `/api/db/invoices/<id>` | Soft delete | can_delete_invoices |
| POST | `/api/db/invoices/<id>/restore` | Restore from bin | can_delete_invoices |
| DELETE | `/api/db/invoices/<id>/permanent` | Permanent delete | can_delete_invoices |
| POST | `/api/db/invoices/bulk-delete` | Bulk soft delete | can_delete_invoices |
| POST | `/api/db/invoices/bulk-restore` | Bulk restore | can_delete_invoices |
| POST | `/api/db/invoices/bulk-permanent-delete` | Bulk perm delete | can_delete_invoices |
| GET | `/api/db/invoices/bin` | Deleted invoices | can_view_invoices |
| PUT | `/api/db/invoices/<id>/allocations` | Update allocations | can_edit_invoices |
| PUT | `/api/allocations/<id>/comment` | Allocation comment | can_edit_invoices |
| PUT | `/api/invoices/<id>/drive-link` | Update drive link | can_edit_invoices |
| GET | `/api/db/search` | Search invoices | can_view_invoices |
| GET | `/api/invoices/search` | Search (detailed) | can_view_invoices |
| GET | `/api/db/check-invoice-number` | Check number exists | can_view_invoices |
| GET | `/api/db/summary/company` | Summary by company | can_view_invoices |
| GET | `/api/db/summary/department` | Summary by dept | can_view_invoices |
| GET | `/api/db/summary/brand` | Summary by brand | can_view_invoices |
| GET | `/api/db/summary/supplier` | Summary by supplier | can_view_invoices |

## Bank Statements (`/statements`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/upload` | Upload & parse | Session |
| GET | `/api/statements` | List statements | Session |
| GET | `/api/statements/<id>` | Statement detail | Session |
| DELETE | `/api/statements/<id>` | Delete statement | Session |
| GET | `/api/filters` | Filter options | Session |
| GET | `/api/transactions` | List transactions | Session |
| GET | `/api/transactions/<id>` | Transaction detail | Session |
| PUT | `/api/transactions/<id>` | Update transaction | Session |
| POST | `/api/transactions/bulk-ignore` | Bulk ignore | Session |
| POST | `/api/transactions/bulk-status` | Bulk status update | Session |
| GET | `/api/summary` | Transaction summary | Session |
| GET | `/api/export/csv` | Export CSV | Session |
| GET | `/api/mappings` | Vendor mappings | Session |
| POST | `/api/mappings` | Create mapping | Session |
| PUT | `/api/mappings/<id>` | Update mapping | Session |
| DELETE | `/api/mappings/<id>` | Delete mapping | Session |
| POST | `/api/transactions/link-invoice` | Link invoice | Session |
| POST | `/api/transactions/<id>/unlink` | Unlink invoice | Session |
| POST | `/api/transactions/auto-match` | Auto-match | Session |
| GET | `/api/transactions/<id>/suggestions` | Match suggestions | Session |
| POST | `/api/transactions/<id>/accept-match` | Accept match | Session |
| POST | `/api/transactions/<id>/reject-match` | Reject match | Session |
| POST | `/api/transactions/merge` | Merge transactions | Session |
| POST | `/api/transactions/<id>/unmerge` | Unmerge | Session |

## Bulk Processing (`/bugetare`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/bulk/process` | Process bulk invoices | Session |
| POST | `/api/bulk/export` | Export to Excel | Session |
| POST | `/api/bulk/export-json` | JSON to Excel | Session |
| POST | `/api/bulk/match-campaigns` | AI match campaigns | Session |
| POST | `/api/bulk/group-similar-items` | AI group items | Session |

## Invoice Templates (`/templates`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/templates` | List templates | Session |
| GET | `/api/templates/<id>` | Get template | Session |
| POST | `/api/templates` | Create template | Session |
| PUT | `/api/templates/<id>` | Update template | Session |
| DELETE | `/api/templates/<id>` | Delete template | Session |
| POST | `/api/templates/generate` | Generate from invoice | Session |

## e-Factura (`/efactura`)

### Company Connections

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/connections` | List connections | Session |
| GET | `/api/connections/<cif>` | Get connection | Session |
| POST | `/api/connections` | Create connection | Session |
| DELETE | `/api/connections/<cif>` | Delete connection | Session |

### Invoices

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/invoices` | List with filters | Session |
| GET | `/api/invoices/<id>` | Invoice + artifacts | Session |
| GET | `/api/invoices/summary` | Stats by direction | Session |
| GET | `/api/invoices/unallocated` | Unallocated list | Session |
| GET | `/api/invoices/unallocated/count` | Badge count | Session |
| GET | `/api/invoices/unallocated/ids` | Select-all IDs | Session |
| PUT | `/api/invoices/<id>/overrides` | Type/dept overrides | Session |
| PUT | `/api/invoices/bulk-overrides` | Bulk overrides | Session |
| GET | `/api/invoices/hidden` | Hidden list | Session |
| GET | `/api/invoices/hidden/count` | Hidden count | Session |
| POST | `/api/invoices/bulk-hide` | Bulk hide | Session |
| POST | `/api/invoices/bulk-restore-hidden` | Restore hidden | Session |
| GET | `/api/invoices/bin` | Deleted list | Session |
| GET | `/api/invoices/bin/count` | Deleted count | Session |
| POST | `/api/invoices/<id>/delete` | Move to bin | Session |
| POST | `/api/invoices/<id>/restore` | Restore from bin | Session |
| POST | `/api/invoices/<id>/permanent-delete` | Permanent delete | Session |
| POST | `/api/invoices/bulk-delete` | Bulk delete | Session |
| POST | `/api/invoices/bulk-restore-bin` | Bulk restore | Session |
| POST | `/api/invoices/bulk-permanent-delete` | Bulk perm delete | Session |

### Module Integration

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/invoices/send-to-module` | Allocate to main | Session |
| GET | `/api/invoices/duplicates` | Find duplicates | Session |
| POST | `/api/invoices/mark-duplicates` | Link existing | Session |
| GET | `/api/invoices/duplicates/ai` | AI duplicate detection | Session |

### Sync & ANAF

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/sync/trigger` | Manual sync | Session |
| GET | `/api/sync/history` | Recent runs | Session |
| GET | `/api/sync/errors/<run_id>` | Run errors | Session |
| GET | `/api/sync/stats` | Error statistics | Session |
| POST | `/api/sync` | Sync all companies | Session |
| POST | `/api/sync/company` | Sync one company | Session |
| POST | `/api/import` | Import messages | Session |
| GET | `/api/anaf/messages` | Fetch from ANAF | Session |
| GET | `/api/anaf/download/<msg_id>` | Download ZIP | Session |
| GET | `/api/anaf/status` | ANAF status | Session |
| GET | `/api/rate-limit` | Rate limit status | Session |
| GET | `/api/company/lookup` | CIF lookup | Session |
| POST | `/api/company/lookup-batch` | Batch CIF lookup | Session |

### OAuth2

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/oauth/authorize` | Start OAuth flow | Session |
| GET | `/oauth/callback` | ANAF callback | Public |
| POST | `/oauth/revoke` | Disconnect | Session |
| GET | `/oauth/status` | Token status | Session |
| POST | `/oauth/refresh` | Refresh token | Session |

### Supplier Mappings

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/mappings` | List mappings | Session |
| GET | `/api/mappings/<id>` | Get mapping | Session |
| POST | `/api/mappings` | Create mapping | Session |
| PUT | `/api/mappings/<id>` | Update mapping | Session |
| DELETE | `/api/mappings/<id>` | Delete mapping | Session |
| GET | `/api/mappings/lookup` | Lookup by partner | Session |
| GET | `/api/suppliers/distinct` | Distinct suppliers | Session |
| POST | `/api/mappings/bulk-delete` | Bulk delete | Session |
| POST | `/api/mappings/bulk-set-type` | Bulk set type | Session |

### Supplier Types

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/supplier-types` | List types | Session |
| GET | `/api/supplier-types/<id>` | Get type | Session |
| POST | `/api/supplier-types` | Create type | Session |
| PUT | `/api/supplier-types/<id>` | Update type | Session |
| DELETE | `/api/supplier-types/<id>` | Delete type | Session |

### PDF Operations

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/invoices/<id>/pdf` | Stored PDF | Session |
| GET | `/api/anaf/export-pdf/<msg_id>` | XML to PDF | Session |

## Tags (`/tags`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/tag-groups` | List groups | Session |
| POST | `/api/tag-groups` | Create group | Admin |
| PUT | `/api/tag-groups/<id>` | Update group | Admin |
| DELETE | `/api/tag-groups/<id>` | Delete group | Admin |
| GET | `/api/tags` | List tags | Session |
| POST | `/api/tags` | Create tag | Session |
| PUT | `/api/tags/<id>` | Update tag | Session |
| DELETE | `/api/tags/<id>` | Delete tag | Session |
| GET | `/api/entity-tags` | Entity tags | Session |
| GET | `/api/entity-tags/bulk` | Bulk entity tags | Session |
| POST | `/api/entity-tags` | Add entity tag | Session |
| DELETE | `/api/entity-tags` | Remove entity tag | Session |
| POST | `/api/entity-tags/bulk` | Bulk operations | Session |
| POST | `/api/entity-tags/suggest` | AI suggestions | Session |
| GET | `/api/auto-tag-rules` | List rules | Session |
| POST | `/api/auto-tag-rules` | Create rule | Admin |
| PUT | `/api/auto-tag-rules/<id>` | Update rule | Admin |
| DELETE | `/api/auto-tag-rules/<id>` | Delete rule | Admin |
| POST | `/api/auto-tag-rules/<id>/run` | Execute rule | Admin |
| GET | `/api/auto-tag-rules/entity-fields` | Available fields | Session |

## Approvals (`/approvals`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/requests` | Submit for approval | Session |
| GET | `/api/requests` | List requests | Session |
| GET | `/api/requests/<id>` | Request detail | Session |
| POST | `/api/requests/<id>/decide` | Approve/reject/return | Session |
| POST | `/api/requests/<id>/cancel` | Cancel request | Session |
| POST | `/api/requests/<id>/resubmit` | Resubmit rejected | Session |
| POST | `/api/requests/<id>/escalate` | Escalate | Session |
| GET | `/api/my-queue` | Pending for user | Session |
| GET | `/api/my-queue/count` | Queue count | Session |
| GET | `/api/my-requests` | My submissions | Session |
| GET | `/api/flows` | List flows | Session |
| POST | `/api/flows` | Create flow | Admin |
| GET | `/api/flows/<id>` | Flow + steps | Session |
| PUT | `/api/flows/<id>` | Update flow | Admin |
| DELETE | `/api/flows/<id>` | Deactivate flow | Admin |
| POST | `/api/flows/<id>/steps` | Add step | Admin |
| PUT | `/api/flows/<id>/steps/<step_id>` | Update step | Admin |
| DELETE | `/api/flows/<id>/steps/<step_id>` | Remove step | Admin |
| PATCH | `/api/flows/<id>/steps/reorder` | Reorder steps | Admin |
| GET | `/api/delegations` | User delegations | Session |
| POST | `/api/delegations` | Create delegation | Session |
| DELETE | `/api/delegations/<id>` | Revoke delegation | Session |
| GET | `/api/requests/<id>/audit` | Audit trail | Session |
| GET | `/api/audit` | Global audit log | Admin |
| GET | `/api/entity/<type>/<id>/history` | Entity history | Session |

## Notifications (`/notifications`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/notification-settings` | Get settings | Session |
| POST | `/api/notification-settings` | Save settings | Session |
| GET | `/api/notification-logs` | Notification logs | Session |
| POST | `/api/notification-settings/test` | Send test email | Session |
| GET | `/api/default-columns` | Column configs | Session |
| POST | `/api/default-columns` | Set column config | Admin |
| GET | `/notifications/api/list` | In-app list | Session |
| GET | `/notifications/api/unread-count` | Unread count | Session |
| POST | `/notifications/api/mark-read/<id>` | Mark read | Session |
| POST | `/notifications/api/mark-all-read` | Mark all read | Session |

## HR Events (`/hr`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/events` | List events | hr_required |
| POST | `/api/events` | Create event | hr_permission(events, add) |
| GET | `/api/events/<id>` | Event detail | hr_required |
| PUT | `/api/events/<id>` | Update event | hr_permission(events, edit) |
| DELETE | `/api/events/<id>` | Delete event | hr_permission(events, delete) |
| POST | `/api/events/bulk-delete` | Bulk delete | hr_permission(events, delete) |
| GET | `/api/event-bonuses` | List bonuses | hr_required |
| POST | `/api/event-bonuses` | Create bonus | hr_permission(bonuses, add) |
| POST | `/api/event-bonuses/bulk` | Bulk create | hr_permission(bonuses, add) |
| PUT | `/api/event-bonuses/<id>` | Update bonus | hr_permission(bonuses, edit) |
| DELETE | `/api/event-bonuses/<id>` | Delete bonus | hr_permission(bonuses, delete) |
| POST | `/api/event-bonuses/bulk-delete` | Bulk delete | hr_permission(bonuses, delete) |
| GET | `/api/employees` | List employees | hr_required |
| GET | `/api/employees/search` | Search employees | hr_required |
| POST | `/api/employees` | Create employee | hr_permission(employees, add) |
| PUT | `/api/employees/<id>` | Update employee | hr_permission(employees, edit) |
| DELETE | `/api/employees/<id>` | Delete employee | hr_permission(employees, delete) |
| GET | `/api/summary` | Summary stats | hr_required |
| GET | `/api/summary/by-month` | By month | hr_required |
| GET | `/api/summary/by-employee` | By employee | hr_required |
| GET | `/api/export` | Export Excel | hr_permission(bonuses, export) |
| GET | `/api/bonus-types` | List bonus types | hr_required |
| POST | `/api/bonus-types` | Create bonus type | hr_permission(bonuses, add) |
| PUT | `/api/bonus-types/<id>` | Update bonus type | hr_permission(bonuses, edit) |
| DELETE | `/api/bonus-types/<id>` | Delete bonus type | hr_permission(bonuses, delete) |
| GET/POST/PUT/DELETE | `/api/structure/*` | Company structure | hr_permission(structure, edit) |

## AI Agent (`/ai`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/conversations` | List conversations | ai_agent_required |
| POST | `/api/conversations` | Create conversation | ai_agent_required |
| GET | `/api/conversations/<id>` | Get conversation | ai_agent_required |
| POST | `/api/conversations/<id>/archive` | Archive | ai_agent_required |
| DELETE | `/api/conversations/<id>` | Delete | ai_agent_required |
| POST | `/api/chat` | Send message | ai_agent_required |
| POST | `/api/chat/stream` | SSE stream response | ai_agent_required |
| GET | `/api/models` | Available models | ai_agent_required |
| POST | `/api/rag/reindex` | Trigger reindex | Admin |
| GET | `/api/rag/stats` | RAG statistics | ai_agent_required |
| GET | `/api/models/all` | All models | Admin |
| PUT | `/api/models/<id>/default` | Set default model | Admin |
| PUT | `/api/models/<id>/toggle` | Enable/disable | Admin |
| PUT | `/api/models/<id>/api-key` | Update API key | Admin |
| GET | `/api/settings` | AI settings | Admin |
| POST | `/api/settings` | Save AI settings | Admin |

## Marketing (`/marketing`)

### Projects

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects` | List projects | mkt(project, view) |
| POST | `/api/projects` | Create project | mkt(project, create) |
| GET | `/api/projects/<id>` | Project detail | mkt(project, view) |
| PUT | `/api/projects/<id>` | Update project | mkt(project, edit) |
| DELETE | `/api/projects/<id>` | Delete project | mkt(project, delete) |
| POST | `/api/projects/<id>/submit-approval` | Submit approval | mkt(project, edit) |
| PUT | `/api/projects/<id>/status` | Update status | mkt(project, edit) |

### Budget

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects/<id>/budget-lines` | Budget lines | mkt(budget, view) |
| POST | `/api/projects/<id>/budget-lines` | Add budget line | mkt(budget, edit) |
| PUT | `/api/budget-lines/<id>` | Update line | mkt(budget, edit) |
| DELETE | `/api/budget-lines/<id>` | Delete line | mkt(budget, edit) |
| GET | `/api/budget-lines/<id>/transactions` | Transactions | mkt(budget, view) |
| POST | `/api/budget-lines/<id>/transactions` | Add transaction | mkt(budget, edit) |
| POST | `/api/budget-lines/<id>/link-invoice` | Link invoice | mkt(budget, edit) |
| DELETE | `/api/budget-lines/<id>/unlink-invoice/<inv_id>` | Unlink | mkt(budget, edit) |
| GET | `/api/budget-lines/<id>/invoices` | Linked invoices | mkt(budget, view) |
| GET | `/api/invoices/search` | Search for linking | mkt(budget, view) |

### KPIs

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects/<id>/kpis` | Project KPIs | mkt(kpi, view) |
| POST | `/api/projects/<id>/kpis` | Add KPI | mkt(kpi, add) |
| PUT | `/api/kpis/<id>` | Update KPI | mkt(kpi, edit) |
| DELETE | `/api/kpis/<id>` | Delete KPI | mkt(kpi, delete) |
| POST | `/api/kpis/<id>/snapshots` | Record snapshot | mkt(kpi, edit) |
| GET | `/api/kpis/<id>/snapshots` | Snapshot history | mkt(kpi, view) |

### OKR

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects/<id>/objectives` | Objectives | mkt(kpi, view) |
| POST | `/api/projects/<id>/objectives` | Add objective | mkt(kpi, edit) |
| PUT | `/api/objectives/<id>` | Update objective | mkt(kpi, edit) |
| DELETE | `/api/objectives/<id>` | Delete objective | mkt(kpi, edit) |
| POST | `/api/objectives/<id>/key-results` | Add KR | mkt(kpi, edit) |
| PUT | `/api/key-results/<id>` | Update KR | mkt(kpi, edit) |
| DELETE | `/api/key-results/<id>` | Delete KR | mkt(kpi, edit) |
| POST | `/api/projects/<id>/sync-kpis` | Sync KPI values | mkt(kpi, edit) |

### Team, Comments, Files, Events, Dashboard

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET/POST | `/api/projects/<id>/members` | Team members | mkt(project, view/edit) |
| PUT/DELETE | `/api/members/<id>` | Update/remove member | mkt(project, edit) |
| GET/POST | `/api/projects/<id>/comments` | Comments | mkt(project, view/edit) |
| PUT/DELETE | `/api/comments/<id>` | Edit/delete comment | mkt(project, edit) |
| GET/POST | `/api/projects/<id>/files` | Files | mkt(project, view/edit) |
| DELETE | `/api/files/<id>` | Delete file | mkt(project, edit) |
| GET/POST/DELETE | `/api/projects/<id>/events` | Event linking | mkt(project, view/edit) |
| GET | `/api/hr-events/search` | Search HR events | mkt(project, view) |
| GET | `/api/dashboard/summary` | Dashboard stats | mkt(project, view) |
| GET | `/api/reports/budget-vs-actual` | Budget report | mkt(project, view) |
| GET | `/api/reports/channel-performance` | Channel report | mkt(project, view) |

### Admin

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/admin/kpi-definitions` | KPI definitions | Admin |
| POST | `/api/admin/kpi-definitions` | Create definition | Admin |
| PUT | `/api/admin/kpi-definitions/<id>` | Update definition | Admin |
| DELETE | `/api/admin/kpi-definitions/<id>` | Delete definition | Admin |

## Profile (`/profile`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/summary` | Profile summary | Session |
| GET | `/api/invoices` | User's invoices | Session |
| GET | `/api/hr-events` | HR bonuses | Session |
| GET | `/api/notifications` | Notifications | Session |
| GET | `/api/activity` | Activity log | Session |

## Presets (`/presets`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/presets` | Filter presets | Session |
| POST | `/api/presets` | Create preset | Session |
| PUT | `/api/presets/<id>` | Update preset | Session |
| DELETE | `/api/presets/<id>` | Delete preset | Session |

## Google Drive (`/drive`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/drive/status` | Auth status | Session |
| POST | `/api/drive/upload` | Upload invoice | Session |
| POST | `/api/drive/upload-attachment` | Upload attachment | Session |
| GET | `/api/drive/folder-link` | Folder link | Session |

---

**Auth Legend:**
- **Public** — No authentication required
- **Session** — `@login_required` (any authenticated user)
- **Admin** — `@admin_required` (`can_access_settings` flag)
- **can_*_invoices** — V1 permission boolean flag
- **hr_required** — `can_access_hr` flag + V2 scope
- **hr_permission(entity, action)** — V2 permission check
- **mkt(entity, action)** — `@mkt_permission_required` V2 decorator
- **ai_agent_required** — AI agent access permission
