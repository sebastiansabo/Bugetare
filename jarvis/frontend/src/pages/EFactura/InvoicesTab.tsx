import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { FileSearch, FileText } from 'lucide-react'
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
import { EmptyState } from '@/components/shared/EmptyState'
import { StatusBadge } from '@/components/shared/StatusBadge'
import { CurrencyDisplay } from '@/components/shared/CurrencyDisplay'
import { efacturaApi } from '@/api/efactura'
import type { EFacturaInvoiceFilters, SyncCompany } from '@/types/efactura'

export default function InvoicesTab() {
  const [selectedCif, setSelectedCif] = useState('')
  const [direction, setDirection] = useState<string>('all')
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')
  const [page, setPage] = useState(1)
  const limit = 50

  const { data: companies = [] } = useQuery({
    queryKey: ['efactura-sync-companies'],
    queryFn: () => efacturaApi.getSyncCompanies(),
  })

  const filters: EFacturaInvoiceFilters = {
    cif: selectedCif || undefined,
    direction: direction !== 'all' ? (direction as 'received' | 'sent') : undefined,
    start_date: startDate || undefined,
    end_date: endDate || undefined,
    limit,
    page,
  }

  const { data, isLoading } = useQuery({
    queryKey: ['efactura-invoices', filters],
    queryFn: () => efacturaApi.getInvoices(filters),
    enabled: !!selectedCif,
  })

  const { data: summary } = useQuery({
    queryKey: ['efactura-invoice-summary', selectedCif, startDate, endDate],
    queryFn: () => efacturaApi.getInvoiceSummary(selectedCif, startDate || undefined, endDate || undefined),
    enabled: !!selectedCif,
  })

  const invoices = data?.invoices ?? []
  const pagination = data?.pagination

  const fmtDate = (d: string | null) => d ? new Date(d).toLocaleDateString('ro-RO') : '—'
  const fmtAmount = (v: number) =>
    new Intl.NumberFormat('ro-RO', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v)

  return (
    <div className="space-y-4">
      {/* Controls */}
      <div className="flex flex-wrap items-end gap-3">
        <div className="space-y-1">
          <Label className="text-xs">Company</Label>
          <Select value={selectedCif} onValueChange={(v) => { setSelectedCif(v); setPage(1) }}>
            <SelectTrigger className="w-[220px]">
              <SelectValue placeholder="Select company..." />
            </SelectTrigger>
            <SelectContent>
              {companies.map((c: SyncCompany) => (
                <SelectItem key={c.cif} value={c.cif}>
                  {c.display_name} ({c.cif})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1">
          <Label className="text-xs">Direction</Label>
          <Select value={direction} onValueChange={(v) => { setDirection(v); setPage(1) }}>
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
            value={startDate}
            onChange={(e) => { setStartDate(e.target.value); setPage(1) }}
          />
        </div>

        <div className="space-y-1">
          <Label className="text-xs">To</Label>
          <Input
            type="date"
            className="w-[150px]"
            value={endDate}
            onChange={(e) => { setEndDate(e.target.value); setPage(1) }}
          />
        </div>
      </div>

      {/* Summary */}
      {summary && (
        <div className="flex flex-wrap gap-4 text-sm">
          <div>
            <span className="text-muted-foreground">Total: </span>
            <span className="font-semibold">{summary.total_count}</span>
          </div>
          <div>
            <span className="text-muted-foreground">Amount: </span>
            <span className="font-semibold">{fmtAmount(summary.total_amount)} RON</span>
          </div>
          {summary.by_direction?.received && (
            <div>
              <span className="text-muted-foreground">Received: </span>
              <span>{summary.by_direction.received.count} ({fmtAmount(summary.by_direction.received.amount)})</span>
            </div>
          )}
          {summary.by_direction?.sent && (
            <div>
              <span className="text-muted-foreground">Sent: </span>
              <span>{summary.by_direction.sent.count} ({fmtAmount(summary.by_direction.sent.amount)})</span>
            </div>
          )}
        </div>
      )}

      {/* Table */}
      {!selectedCif ? (
        <EmptyState
          icon={<FileSearch className="h-10 w-10" />}
          title="Select a company"
          description="Choose a company to browse stored invoices"
        />
      ) : isLoading ? (
        <div className="space-y-2">
          {[1, 2, 3].map((i) => <div key={i} className="h-12 animate-pulse rounded bg-muted/50" />)}
        </div>
      ) : invoices.length === 0 ? (
        <EmptyState
          icon={<FileText className="h-10 w-10" />}
          title="No invoices found"
          description="No invoices match the current filters"
        />
      ) : (
        <div className="rounded border overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-muted/50">
                <th className="p-2 text-left">Partner</th>
                <th className="p-2 text-left">Invoice #</th>
                <th className="p-2 text-left">Issue Date</th>
                <th className="p-2 text-left">Due Date</th>
                <th className="p-2 text-left">Direction</th>
                <th className="p-2 text-right">Without VAT</th>
                <th className="p-2 text-right">VAT</th>
                <th className="p-2 text-right">Total</th>
                <th className="p-2 text-left">Status</th>
                <th className="p-2 text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              {invoices.map((inv) => (
                <tr key={inv.id} className="border-b hover:bg-muted/30">
                  <td className="p-2">
                    <div className="font-medium">{inv.partner_name}</div>
                    {inv.partner_cif && <div className="text-xs text-muted-foreground">{inv.partner_cif}</div>}
                  </td>
                  <td className="p-2 font-mono text-xs">
                    {inv.invoice_series ? `${inv.invoice_series}-` : ''}
                    {inv.invoice_number}
                  </td>
                  <td className="p-2 text-muted-foreground">{fmtDate(inv.issue_date)}</td>
                  <td className="p-2 text-muted-foreground">{fmtDate(inv.due_date)}</td>
                  <td className="p-2"><StatusBadge status={inv.direction} /></td>
                  <td className="p-2 text-right">
                    <CurrencyDisplay value={inv.total_without_vat} currency={inv.currency} />
                  </td>
                  <td className="p-2 text-right">
                    <CurrencyDisplay value={inv.total_vat} currency={inv.currency} />
                  </td>
                  <td className="p-2 text-right">
                    <CurrencyDisplay value={inv.total_amount} currency={inv.currency} />
                  </td>
                  <td className="p-2"><StatusBadge status={inv.status} /></td>
                  <td className="p-2">
                    <Button size="sm" variant="ghost" asChild title="View PDF">
                      <a href={efacturaApi.getInvoicePdfUrl(inv.id)} target="_blank" rel="noopener noreferrer">
                        <FileText className="h-3 w-3" />
                      </a>
                    </Button>
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
            <Button size="sm" variant="outline" disabled={!pagination.has_prev} onClick={() => setPage((p) => p - 1)}>
              Previous
            </Button>
            <Button size="sm" variant="outline" disabled={!pagination.has_next} onClick={() => setPage((p) => p + 1)}>
              Next
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}
