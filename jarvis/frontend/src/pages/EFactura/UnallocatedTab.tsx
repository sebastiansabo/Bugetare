import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Send,
  EyeOff,
  Trash2,
  RotateCcw,
  CheckCircle,
  FileStack,
  Archive,
  XCircle,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { EmptyState } from '@/components/shared/EmptyState'
import { StatusBadge } from '@/components/shared/StatusBadge'
import { SearchInput } from '@/components/shared/SearchInput'
import { CurrencyDisplay } from '@/components/shared/CurrencyDisplay'
import { ConfirmDialog } from '@/components/shared/ConfirmDialog'
import { efacturaApi } from '@/api/efactura'
import type { EFacturaInvoice, EFacturaInvoiceFilters } from '@/types/efactura'

type SubView = 'unallocated' | 'hidden' | 'bin'

export default function UnallocatedTab() {
  const qc = useQueryClient()
  const [view, setView] = useState<SubView>('unallocated')
  const [filters, setFilters] = useState<EFacturaInvoiceFilters>({ page: 1, limit: 50 })
  const [search, setSearch] = useState('')
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set())
  const [confirmAction, setConfirmAction] = useState<{ action: string; ids: number[] } | null>(null)

  const updateFilter = (key: string, value: string | number | boolean | undefined) => {
    setFilters((f) => ({ ...f, [key]: value || undefined, page: 1 }))
    setSelectedIds(new Set())
  }

  // ── Queries ──────────────────────────────────────────────
  const { data: unallocData, isLoading: unallocLoading } = useQuery({
    queryKey: ['efactura-unallocated', { ...filters, search }],
    queryFn: () => efacturaApi.getUnallocated({ ...filters, search: search || undefined }),
    enabled: view === 'unallocated',
  })

  const { data: hiddenData, isLoading: hiddenLoading } = useQuery({
    queryKey: ['efactura-hidden', { ...filters, search }],
    queryFn: () => efacturaApi.getHidden({ ...filters, search: search || undefined }),
    enabled: view === 'hidden',
  })

  const { data: binData, isLoading: binLoading } = useQuery({
    queryKey: ['efactura-bin', { ...filters, search }],
    queryFn: () => efacturaApi.getBin({ ...filters, search: search || undefined }),
    enabled: view === 'bin',
  })

  const { data: hiddenCount } = useQuery({
    queryKey: ['efactura-hidden-count'],
    queryFn: () => efacturaApi.getHiddenCount(),
  })

  const { data: binCount } = useQuery({
    queryKey: ['efactura-bin-count'],
    queryFn: () => efacturaApi.getBinCount(),
  })

  // ── Mutations ─────────────────────────────────────────────
  const invalidateAll = () => {
    qc.invalidateQueries({ queryKey: ['efactura-unallocated'] })
    qc.invalidateQueries({ queryKey: ['efactura-hidden'] })
    qc.invalidateQueries({ queryKey: ['efactura-bin'] })
    qc.invalidateQueries({ queryKey: ['efactura-unallocated-count'] })
    qc.invalidateQueries({ queryKey: ['efactura-hidden-count'] })
    qc.invalidateQueries({ queryKey: ['efactura-bin-count'] })
    setSelectedIds(new Set())
    setConfirmAction(null)
  }

  const sendToModuleMut = useMutation({
    mutationFn: (ids: number[]) => efacturaApi.sendToModule(ids),
    onSuccess: invalidateAll,
  })

  const bulkHideMut = useMutation({
    mutationFn: (ids: number[]) => efacturaApi.bulkHide(ids),
    onSuccess: invalidateAll,
  })

  const bulkRestoreHiddenMut = useMutation({
    mutationFn: (ids: number[]) => efacturaApi.bulkRestoreHidden(ids),
    onSuccess: invalidateAll,
  })

  const bulkDeleteMut = useMutation({
    mutationFn: (ids: number[]) => efacturaApi.bulkDelete(ids),
    onSuccess: invalidateAll,
  })

  const bulkRestoreBinMut = useMutation({
    mutationFn: (ids: number[]) => efacturaApi.bulkRestoreBin(ids),
    onSuccess: invalidateAll,
  })

  const bulkPermanentDeleteMut = useMutation({
    mutationFn: (ids: number[]) => efacturaApi.bulkPermanentDelete(ids),
    onSuccess: invalidateAll,
  })

  // ── Derived state ────────────────────────────────────────
  const isLoading = view === 'unallocated' ? unallocLoading : view === 'hidden' ? hiddenLoading : binLoading
  const invoices: EFacturaInvoice[] =
    view === 'unallocated' ? (unallocData?.invoices ?? [])
    : view === 'hidden' ? (hiddenData?.invoices ?? [])
    : (binData?.invoices ?? [])
  const pagination =
    view === 'unallocated' ? unallocData?.pagination
    : view === 'hidden' ? hiddenData?.pagination
    : binData?.pagination
  const companies = unallocData?.companies ?? []

  const toggleSelect = (id: number) => {
    setSelectedIds((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  const toggleAll = () => {
    if (selectedIds.size === invoices.length) setSelectedIds(new Set())
    else setSelectedIds(new Set(invoices.map((i) => i.id)))
  }

  const executeAction = () => {
    if (!confirmAction) return
    const { action, ids } = confirmAction
    switch (action) {
      case 'send': sendToModuleMut.mutate(ids); break
      case 'hide': bulkHideMut.mutate(ids); break
      case 'delete': bulkDeleteMut.mutate(ids); break
      case 'restore-hidden': bulkRestoreHiddenMut.mutate(ids); break
      case 'restore-bin': bulkRestoreBinMut.mutate(ids); break
      case 'permanent-delete': bulkPermanentDeleteMut.mutate(ids); break
    }
  }

  const fmtDate = (d: string | null) => d ? new Date(d).toLocaleDateString('ro-RO') : '—'

  return (
    <div className="space-y-4">
      {/* Sub-view tabs */}
      <div className="flex gap-2">
        {([
          { key: 'unallocated' as SubView, label: 'Unallocated', icon: FileStack },
          { key: 'hidden' as SubView, label: `Hidden (${hiddenCount ?? 0})`, icon: EyeOff },
          { key: 'bin' as SubView, label: `Bin (${binCount ?? 0})`, icon: Archive },
        ]).map((sv) => (
          <Button
            key={sv.key}
            variant={view === sv.key ? 'default' : 'outline'}
            size="sm"
            onClick={() => { setView(sv.key); setSelectedIds(new Set()); setFilters({ page: 1, limit: 50 }) }}
          >
            <sv.icon className="mr-1.5 h-3.5 w-3.5" />
            {sv.label}
          </Button>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-end gap-3">
        {view === 'unallocated' && companies.length > 0 && (
          <div className="space-y-1">
            <Label className="text-xs">Company</Label>
            <Select
              value={filters.company_id?.toString() ?? 'all'}
              onValueChange={(v) => updateFilter('company_id', v === 'all' ? undefined : Number(v))}
            >
              <SelectTrigger className="w-[200px]">
                <SelectValue placeholder="All companies" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All companies</SelectItem>
                {companies.map((c) => (
                  <SelectItem key={c.id} value={c.id.toString()}>
                    {c.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        )}

        <div className="space-y-1">
          <Label className="text-xs">Direction</Label>
          <Select
            value={filters.direction ?? 'all'}
            onValueChange={(v) => updateFilter('direction', v === 'all' ? undefined : v)}
          >
            <SelectTrigger className="w-[130px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All</SelectItem>
              <SelectItem value="received">Received</SelectItem>
              <SelectItem value="sent">Sent</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1">
          <Label className="text-xs">From</Label>
          <Input
            type="date"
            className="w-[150px]"
            value={filters.start_date ?? ''}
            onChange={(e) => updateFilter('start_date', e.target.value)}
          />
        </div>

        <div className="space-y-1">
          <Label className="text-xs">To</Label>
          <Input
            type="date"
            className="w-[150px]"
            value={filters.end_date ?? ''}
            onChange={(e) => updateFilter('end_date', e.target.value)}
          />
        </div>

        <SearchInput
          value={search}
          onChange={setSearch}
          placeholder="Search partner, invoice#..."
          className="w-[200px]"
        />
      </div>

      {/* Bulk actions */}
      {selectedIds.size > 0 && (
        <div className="flex flex-wrap items-center gap-2 rounded border bg-muted/30 px-3 py-2">
          <span className="text-sm font-medium">{selectedIds.size} selected</span>

          {view === 'unallocated' && (
            <>
              <Button size="sm" onClick={() => setConfirmAction({ action: 'send', ids: Array.from(selectedIds) })}>
                <Send className="mr-1 h-3 w-3" /> Send to Module
              </Button>
              <Button size="sm" variant="outline" onClick={() => setConfirmAction({ action: 'hide', ids: Array.from(selectedIds) })}>
                <EyeOff className="mr-1 h-3 w-3" /> Hide
              </Button>
              <Button size="sm" variant="outline" onClick={() => setConfirmAction({ action: 'delete', ids: Array.from(selectedIds) })}>
                <Trash2 className="mr-1 h-3 w-3" /> Delete
              </Button>
            </>
          )}
          {view === 'hidden' && (
            <>
              <Button size="sm" onClick={() => setConfirmAction({ action: 'restore-hidden', ids: Array.from(selectedIds) })}>
                <RotateCcw className="mr-1 h-3 w-3" /> Restore
              </Button>
              <Button size="sm" variant="outline" onClick={() => setConfirmAction({ action: 'delete', ids: Array.from(selectedIds) })}>
                <Trash2 className="mr-1 h-3 w-3" /> Move to Bin
              </Button>
            </>
          )}
          {view === 'bin' && (
            <>
              <Button size="sm" onClick={() => setConfirmAction({ action: 'restore-bin', ids: Array.from(selectedIds) })}>
                <RotateCcw className="mr-1 h-3 w-3" /> Restore
              </Button>
              <Button size="sm" variant="destructive" onClick={() => setConfirmAction({ action: 'permanent-delete', ids: Array.from(selectedIds) })}>
                <XCircle className="mr-1 h-3 w-3" /> Permanent Delete
              </Button>
            </>
          )}

          <Button size="sm" variant="ghost" onClick={() => setSelectedIds(new Set())}>Clear</Button>
        </div>
      )}

      {/* Success banner */}
      {sendToModuleMut.isSuccess && sendToModuleMut.data && (
        <div className="flex items-center gap-2 rounded border border-green-200 bg-green-50 p-3 text-sm text-green-700 dark:border-green-800 dark:bg-green-900/20 dark:text-green-400">
          <CheckCircle className="h-4 w-4" />
          Sent {sendToModuleMut.data.sent} invoice(s) to module.
          {(sendToModuleMut.data.duplicates ?? 0) > 0 && ` ${sendToModuleMut.data.duplicates} duplicate(s) skipped.`}
        </div>
      )}

      {/* Invoice table */}
      {isLoading ? (
        <div className="space-y-2">
          {[1, 2, 3].map((i) => <div key={i} className="h-12 animate-pulse rounded bg-muted/50" />)}
        </div>
      ) : invoices.length === 0 ? (
        <EmptyState
          icon={<FileStack className="h-10 w-10" />}
          title={view === 'unallocated' ? 'No unallocated invoices' : view === 'hidden' ? 'No hidden invoices' : 'Bin is empty'}
          description={view === 'unallocated' ? 'All imported invoices have been allocated' : undefined}
        />
      ) : (
        <div className="rounded border overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-muted/50">
                <th className="p-2 text-left w-8">
                  <Checkbox
                    checked={invoices.length > 0 && selectedIds.size === invoices.length}
                    onCheckedChange={toggleAll}
                  />
                </th>
                <th className="p-2 text-left">Partner</th>
                <th className="p-2 text-left">Invoice #</th>
                <th className="p-2 text-left">Date</th>
                <th className="p-2 text-left">Direction</th>
                <th className="p-2 text-right">Amount</th>
                <th className="p-2 text-left">Company</th>
                <th className="p-2 text-left">Type</th>
                <th className="p-2 text-left">Status</th>
              </tr>
            </thead>
            <tbody>
              {invoices.map((inv) => (
                <tr key={inv.id} className="border-b hover:bg-muted/30">
                  <td className="p-2">
                    <Checkbox
                      checked={selectedIds.has(inv.id)}
                      onCheckedChange={() => toggleSelect(inv.id)}
                    />
                  </td>
                  <td className="p-2">
                    <div className="font-medium">{inv.partner_name}</div>
                    {inv.partner_cif && <div className="text-xs text-muted-foreground">{inv.partner_cif}</div>}
                  </td>
                  <td className="p-2 font-mono text-xs">
                    {inv.invoice_series ? `${inv.invoice_series}-` : ''}
                    {inv.invoice_number}
                  </td>
                  <td className="p-2 text-muted-foreground">{fmtDate(inv.issue_date)}</td>
                  <td className="p-2">
                    <StatusBadge status={inv.direction} />
                  </td>
                  <td className="p-2 text-right">
                    <CurrencyDisplay value={inv.total_amount} currency={inv.currency} />
                  </td>
                  <td className="p-2 text-xs text-muted-foreground">{inv.cif_owner}</td>
                  <td className="p-2">
                    {inv.type_override || inv.mapped_type_names?.join(', ') || '—'}
                  </td>
                  <td className="p-2">
                    <StatusBadge status={inv.status} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      {pagination && pagination.total_pages > 1 && (
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">
            Page {pagination.page} of {pagination.total_pages} ({pagination.total} invoices)
          </span>
          <div className="flex gap-2">
            <Button
              size="sm"
              variant="outline"
              disabled={!pagination.has_prev}
              onClick={() => setFilters((f) => ({ ...f, page: (f.page ?? 1) - 1 }))}
            >
              Previous
            </Button>
            <Button
              size="sm"
              variant="outline"
              disabled={!pagination.has_next}
              onClick={() => setFilters((f) => ({ ...f, page: (f.page ?? 1) + 1 }))}
            >
              Next
            </Button>
          </div>
        </div>
      )}

      {/* Confirm dialog */}
      <ConfirmDialog
        open={!!confirmAction}
        onOpenChange={() => setConfirmAction(null)}
        title={
          confirmAction?.action === 'send' ? 'Send to Invoice Module'
          : confirmAction?.action === 'hide' ? 'Hide Invoices'
          : confirmAction?.action === 'delete' ? 'Delete Invoices'
          : confirmAction?.action === 'restore-hidden' ? 'Restore from Hidden'
          : confirmAction?.action === 'restore-bin' ? 'Restore from Bin'
          : 'Permanently Delete'
        }
        description={`This will affect ${confirmAction?.ids.length ?? 0} invoice(s).${
          confirmAction?.action === 'permanent-delete' ? ' This cannot be undone.' : ''
        }`}
        onConfirm={executeAction}
        destructive={confirmAction?.action === 'permanent-delete' || confirmAction?.action === 'delete'}
      />
    </div>
  )
}
