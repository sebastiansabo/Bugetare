import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  RefreshCw,
  Play,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Loader2,
  ChevronDown,
  ChevronRight,
  Clock,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
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
import { efacturaApi } from '@/api/efactura'
import type { SyncRun, SyncError, SyncCompany } from '@/types/efactura'

export default function SyncTab() {
  const qc = useQueryClient()
  const [filterCif, setFilterCif] = useState<string>('all')
  const [expandedRun, setExpandedRun] = useState<string | null>(null)

  const { data: companies = [] } = useQuery({
    queryKey: ['efactura-sync-companies'],
    queryFn: () => efacturaApi.getSyncCompanies(),
  })

  const { data: history = [], isLoading } = useQuery({
    queryKey: ['efactura-sync-history', filterCif],
    queryFn: () => efacturaApi.getSyncHistory(filterCif === 'all' ? undefined : filterCif, 50),
  })

  const { data: errorStats } = useQuery({
    queryKey: ['efactura-error-stats', filterCif],
    queryFn: () => efacturaApi.getErrorStats(filterCif === 'all' ? undefined : filterCif, 24),
  })

  const syncAllMut = useMutation({
    mutationFn: () => efacturaApi.syncAll(60),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['efactura-sync-history'] })
      qc.invalidateQueries({ queryKey: ['efactura-unallocated-count'] })
    },
  })

  const syncCompanyMut = useMutation({
    mutationFn: (cif: string) => efacturaApi.syncSingleCompany(cif, 60),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['efactura-sync-history'] })
      qc.invalidateQueries({ queryKey: ['efactura-unallocated-count'] })
    },
  })

  const fmtDate = (d: string | null) => d ? new Date(d).toLocaleString('ro-RO') : '—'
  const duration = (start: string | null, end: string | null) => {
    if (!start || !end) return '—'
    const ms = new Date(end).getTime() - new Date(start).getTime()
    if (ms < 1000) return `${ms}ms`
    return `${(ms / 1000).toFixed(1)}s`
  }

  return (
    <div className="space-y-4">
      {/* Controls */}
      <div className="flex flex-wrap items-end gap-3">
        <div className="space-y-1">
          <Label className="text-xs">Filter by company</Label>
          <Select value={filterCif} onValueChange={setFilterCif}>
            <SelectTrigger className="w-[220px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All companies</SelectItem>
              {companies.map((c: SyncCompany) => (
                <SelectItem key={c.cif} value={c.cif}>{c.display_name}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <Button
          onClick={() => syncAllMut.mutate()}
          disabled={syncAllMut.isPending}
        >
          {syncAllMut.isPending ? (
            <Loader2 className="mr-1.5 h-4 w-4 animate-spin" />
          ) : (
            <Play className="mr-1.5 h-4 w-4" />
          )}
          Sync All Companies
        </Button>

        {filterCif !== 'all' && (
          <Button
            variant="outline"
            onClick={() => syncCompanyMut.mutate(filterCif)}
            disabled={syncCompanyMut.isPending}
          >
            {syncCompanyMut.isPending ? (
              <Loader2 className="mr-1.5 h-4 w-4 animate-spin" />
            ) : (
              <RefreshCw className="mr-1.5 h-4 w-4" />
            )}
            Sync {companies.find((c) => c.cif === filterCif)?.display_name || filterCif}
          </Button>
        )}
      </div>

      {/* Sync result banner */}
      {syncAllMut.isSuccess && syncAllMut.data && (
        <div className="rounded border border-green-200 bg-green-50 p-3 text-sm dark:border-green-800 dark:bg-green-900/20">
          <div className="flex items-center gap-2 font-medium text-green-700 dark:text-green-400">
            <CheckCircle className="h-4 w-4" /> Sync complete
          </div>
          <div className="mt-1 text-green-600 dark:text-green-300">
            Companies: {syncAllMut.data.companies_synced} ·
            Fetched: {syncAllMut.data.total_fetched} ·
            Imported: {syncAllMut.data.total_imported} ·
            Skipped: {syncAllMut.data.total_skipped}
          </div>
        </div>
      )}

      {/* Error stats */}
      {errorStats && errorStats.total_errors > 0 && (
        <div className="rounded border border-yellow-200 bg-yellow-50 p-3 text-sm dark:border-yellow-800 dark:bg-yellow-900/20">
          <div className="flex items-center gap-2 font-medium text-yellow-700 dark:text-yellow-400">
            <AlertTriangle className="h-4 w-4" />
            {errorStats.total_errors} error(s) in the last 24 hours
            {errorStats.retryable_count > 0 && ` (${errorStats.retryable_count} retryable)`}
          </div>
          {Object.keys(errorStats.by_type).length > 0 && (
            <div className="mt-1 flex flex-wrap gap-2">
              {Object.entries(errorStats.by_type).map(([type, count]) => (
                <span key={type} className="text-yellow-600 dark:text-yellow-300">
                  {type}: {count}
                </span>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Sync history table */}
      {isLoading ? (
        <div className="space-y-2">
          {[1, 2, 3].map((i) => <div key={i} className="h-12 animate-pulse rounded bg-muted/50" />)}
        </div>
      ) : history.length === 0 ? (
        <EmptyState
          icon={<RefreshCw className="h-10 w-10" />}
          title="No sync history"
          description="Run a sync to see history here"
        />
      ) : (
        <div className="rounded border">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-muted/50">
                <th className="p-2 text-left w-8" />
                <th className="p-2 text-left">Company</th>
                <th className="p-2 text-left">Started</th>
                <th className="p-2 text-left">Duration</th>
                <th className="p-2 text-center">Status</th>
                <th className="p-2 text-center">Checked</th>
                <th className="p-2 text-center">Fetched</th>
                <th className="p-2 text-center">Created</th>
                <th className="p-2 text-center">Skipped</th>
                <th className="p-2 text-center">Errors</th>
              </tr>
            </thead>
            <tbody>
              {history.map((run) => (
                <SyncRunRow
                  key={run.run_id}
                  run={run}
                  expanded={expandedRun === run.run_id}
                  onToggle={() => setExpandedRun(expandedRun === run.run_id ? null : run.run_id)}
                  fmtDate={fmtDate}
                  duration={duration}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

function SyncRunRow({
  run,
  expanded,
  onToggle,
  fmtDate,
  duration,
}: {
  run: SyncRun
  expanded: boolean
  onToggle: () => void
  fmtDate: (d: string | null) => string
  duration: (s: string | null, e: string | null) => string
}) {
  const { data: errors } = useQuery({
    queryKey: ['efactura-sync-errors', run.run_id],
    queryFn: () => efacturaApi.getSyncErrors(run.run_id),
    enabled: expanded && run.errors_count > 0,
  })

  return (
    <>
      <tr className="border-b hover:bg-muted/30 cursor-pointer" onClick={onToggle}>
        <td className="p-2">
          {run.errors_count > 0 && (
            expanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />
          )}
        </td>
        <td className="p-2 font-medium">{run.company_cif}</td>
        <td className="p-2 text-muted-foreground">{fmtDate(run.started_at)}</td>
        <td className="p-2">
          <div className="flex items-center gap-1 text-muted-foreground">
            <Clock className="h-3 w-3" />
            {duration(run.started_at, run.finished_at)}
          </div>
        </td>
        <td className="p-2 text-center">
          {run.success ? (
            <CheckCircle className="mx-auto h-4 w-4 text-green-600" />
          ) : (
            <XCircle className="mx-auto h-4 w-4 text-red-600" />
          )}
        </td>
        <td className="p-2 text-center">{run.messages_checked}</td>
        <td className="p-2 text-center">{run.invoices_fetched}</td>
        <td className="p-2 text-center">{run.invoices_created}</td>
        <td className="p-2 text-center">{run.invoices_skipped}</td>
        <td className="p-2 text-center">
          {run.errors_count > 0 ? (
            <span className="rounded bg-red-100 px-1.5 py-0.5 text-xs font-semibold text-red-700 dark:bg-red-900/30 dark:text-red-400">
              {run.errors_count}
            </span>
          ) : (
            <span className="text-muted-foreground">0</span>
          )}
        </td>
      </tr>

      {/* Expanded errors */}
      {expanded && run.errors_count > 0 && (
        <tr>
          <td colSpan={10} className="bg-muted/20 p-0">
            <div className="p-3 space-y-2">
              <h4 className="text-xs font-semibold text-muted-foreground uppercase">Errors</h4>
              {!errors ? (
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                  <Loader2 className="h-3 w-3 animate-spin" /> Loading errors...
                </div>
              ) : errors.length === 0 ? (
                <span className="text-sm text-muted-foreground">No error details available</span>
              ) : (
                <div className="space-y-1">
                  {errors.map((err: SyncError) => (
                    <div key={err.id} className="flex items-start gap-2 rounded border bg-background p-2 text-xs">
                      <StatusBadge status={err.error_type} />
                      <div className="flex-1">
                        <span className="font-medium">{err.error_message}</span>
                        {err.message_id && (
                          <span className="ml-2 text-muted-foreground">MSG: {err.message_id}</span>
                        )}
                        {err.is_retryable && (
                          <span className="ml-2 text-yellow-600">(retryable)</span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
              {run.error_summary && (
                <div className="text-xs text-muted-foreground mt-1">
                  Summary: {run.error_summary}
                </div>
              )}
            </div>
          </td>
        </tr>
      )}
    </>
  )
}
