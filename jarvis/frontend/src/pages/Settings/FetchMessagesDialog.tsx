import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Download,
  Search,
  FileDown,
  CheckCircle,
  Loader2,
  FileText,
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
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Checkbox } from '@/components/ui/checkbox'
import { EmptyState } from '@/components/shared/EmptyState'
import { StatusBadge } from '@/components/shared/StatusBadge'
import { efacturaApi } from '@/api/efactura'

interface FetchMessagesDialogProps {
  open: boolean
  onOpenChange: (v: boolean) => void
  cif: string
  displayName: string
}

export function FetchMessagesDialog({ open, onOpenChange, cif, displayName }: FetchMessagesDialogProps) {
  const qc = useQueryClient()
  const [days, setDays] = useState(60)
  const [filter, setFilter] = useState<'all' | 'received' | 'sent'>('all')
  const [page, setPage] = useState(1)
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())
  const [fetched, setFetched] = useState(false)

  const { data: fetchResult, isLoading: isFetching, refetch } = useQuery({
    queryKey: ['efactura-anaf-messages', cif, days, filter, page],
    queryFn: () => efacturaApi.fetchMessages({ cif, days, page, filter }),
    enabled: fetched,
  })

  const importMut = useMutation({
    mutationFn: () => efacturaApi.importFromAnaf(cif, Array.from(selectedIds)),
    onSuccess: () => {
      setSelectedIds(new Set())
      qc.invalidateQueries({ queryKey: ['efactura-anaf-messages'] })
      qc.invalidateQueries({ queryKey: ['efactura-unallocated-count'] })
    },
  })

  const messages = fetchResult?.messages ?? []
  const pagination = fetchResult?.pagination
  const mockMode = fetchResult?.mock_mode ?? false

  const toggleSelect = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  const toggleAll = () => {
    if (selectedIds.size === messages.length) setSelectedIds(new Set())
    else setSelectedIds(new Set(messages.map((m) => m.id)))
  }

  const handleClose = (v: boolean) => {
    if (!v) {
      setPage(1)
      setSelectedIds(new Set())
      setFetched(false)
      importMut.reset()
    }
    onOpenChange(v)
  }

  const handleFetch = () => {
    setFetched(true)
    setPage(1)
    setSelectedIds(new Set())
    importMut.reset()
    setTimeout(() => refetch(), 0)
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="max-w-3xl max-h-[85vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Fetch Messages — {displayName} ({cif})</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          {/* Controls */}
          <div className="flex flex-wrap items-end gap-3">
            <div className="space-y-1">
              <Label className="text-xs">Lookback (days)</Label>
              <Input
                type="number"
                className="w-[100px]"
                value={days}
                onChange={(e) => setDays(Number(e.target.value) || 60)}
                min={1}
                max={365}
              />
            </div>

            <div className="space-y-1">
              <Label className="text-xs">Direction</Label>
              <Select value={filter} onValueChange={(v) => { setFilter(v as typeof filter); setPage(1) }}>
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

            <Button onClick={handleFetch} disabled={isFetching}>
              {isFetching ? <Loader2 className="mr-1.5 h-4 w-4 animate-spin" /> : <Search className="mr-1.5 h-4 w-4" />}
              Fetch Messages
            </Button>

            {mockMode && (
              <span className="rounded bg-yellow-100 px-2 py-1 text-xs font-medium text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300">
                Mock Mode
              </span>
            )}
          </div>

          {/* Bulk actions */}
          {selectedIds.size > 0 && (
            <div className="flex items-center gap-3 rounded border bg-muted/30 px-3 py-2">
              <span className="text-sm font-medium">{selectedIds.size} selected</span>
              <Button
                size="sm"
                onClick={() => importMut.mutate()}
                disabled={importMut.isPending}
              >
                {importMut.isPending ? (
                  <Loader2 className="mr-1.5 h-4 w-4 animate-spin" />
                ) : (
                  <FileDown className="mr-1.5 h-4 w-4" />
                )}
                Import Selected
              </Button>
              <Button size="sm" variant="outline" onClick={() => setSelectedIds(new Set())}>
                Clear
              </Button>
            </div>
          )}

          {/* Import result */}
          {importMut.isSuccess && importMut.data && (
            <div className="rounded border border-green-200 bg-green-50 p-3 text-sm dark:border-green-800 dark:bg-green-900/20">
              <div className="flex items-center gap-2 font-medium text-green-700 dark:text-green-400">
                <CheckCircle className="h-4 w-4" />
                Import complete
              </div>
              <div className="mt-1 text-green-600 dark:text-green-300">
                Imported: {importMut.data.imported} · Skipped: {importMut.data.skipped}
                {importMut.data.errors?.length > 0 && (
                  <span className="text-red-600"> · Errors: {importMut.data.errors.length}</span>
                )}
              </div>
            </div>
          )}

          {/* Messages table */}
          {!fetched ? (
            <EmptyState
              icon={<Download className="h-10 w-10" />}
              title="Ready to fetch"
              description={`Click "Fetch Messages" to retrieve messages from ANAF for ${displayName}`}
            />
          ) : messages.length === 0 && !isFetching ? (
            <EmptyState
              icon={<FileText className="h-10 w-10" />}
              title="No messages"
              description={`No messages found for CIF ${cif} in the last ${days} days`}
            />
          ) : isFetching ? (
            <div className="space-y-2">
              {[1, 2, 3].map((i) => <div key={i} className="h-12 animate-pulse rounded bg-muted/50" />)}
            </div>
          ) : (
            <div className="rounded border">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b bg-muted/50">
                    <th className="p-2 text-left w-8">
                      <Checkbox
                        checked={messages.length > 0 && selectedIds.size === messages.length}
                        onCheckedChange={toggleAll}
                      />
                    </th>
                    <th className="p-2 text-left">Message ID</th>
                    <th className="p-2 text-left">Type</th>
                    <th className="p-2 text-left">Date</th>
                    <th className="p-2 text-left">Status</th>
                    <th className="p-2 text-left">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {messages.map((msg) => (
                    <tr key={msg.id} className="border-b hover:bg-muted/30">
                      <td className="p-2">
                        <Checkbox
                          checked={selectedIds.has(msg.id)}
                          onCheckedChange={() => toggleSelect(msg.id)}
                        />
                      </td>
                      <td className="p-2 font-mono text-xs">{msg.id}</td>
                      <td className="p-2">
                        <StatusBadge status={msg.message_type || msg.tip || '—'} />
                      </td>
                      <td className="p-2 text-muted-foreground">
                        {msg.creation_date
                          ? new Date(msg.creation_date).toLocaleDateString('ro-RO')
                          : msg.data_creare || '—'}
                      </td>
                      <td className="p-2">
                        <StatusBadge status={msg.status || '—'} />
                      </td>
                      <td className="p-2">
                        <div className="flex gap-1">
                          <Button size="sm" variant="ghost" asChild title="Download ZIP">
                            <a href={efacturaApi.downloadMessageUrl(msg.id, cif)} download>
                              <Download className="h-3 w-3" />
                            </a>
                          </Button>
                          <Button size="sm" variant="ghost" asChild title="Export PDF">
                            <a href={efacturaApi.exportPdfUrl(msg.id, cif)} target="_blank" rel="noopener noreferrer">
                              <FileText className="h-3 w-3" />
                            </a>
                          </Button>
                        </div>
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
                Page {pagination.page} of {pagination.total_pages} ({pagination.total} messages)
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
      </DialogContent>
    </Dialog>
  )
}
