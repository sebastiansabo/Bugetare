import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Plug,
  PlugZap,
  Plus,
  Trash2,
  ExternalLink,
  RefreshCw,
  Shield,
  ShieldOff,
  AlertTriangle,
  Download,
  Eraser,
  CheckCircle,
  Loader2,
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
  DialogFooter,
} from '@/components/ui/dialog'
import { ConfirmDialog } from '@/components/shared/ConfirmDialog'
import { StatusBadge } from '@/components/shared/StatusBadge'
import { EmptyState } from '@/components/shared/EmptyState'
import { efacturaApi } from '@/api/efactura'
import type { CompanyConnection } from '@/types/efactura'
import { FetchMessagesDialog } from './FetchMessagesDialog'

function ConnectionCard({
  conn,
  onDelete,
  onOAuthConnect,
  onOAuthRevoke,
  onRefreshToken,
  onFetchMessages,
  onCleanup,
}: {
  conn: CompanyConnection
  onDelete: (cif: string) => void
  onOAuthConnect: (cif: string) => void
  onOAuthRevoke: (cif: string) => void
  onRefreshToken: (cif: string) => void
  onFetchMessages: (conn: CompanyConnection) => void
  onCleanup: (conn: CompanyConnection) => void
}) {
  const { data: oauthStatus } = useQuery({
    queryKey: ['efactura-oauth-status', conn.cif],
    queryFn: () => efacturaApi.getOAuthStatus(conn.cif),
    refetchInterval: 60_000,
  })

  const statusColor =
    conn.status === 'active'
      ? 'text-green-600 dark:text-green-400'
      : conn.status === 'error'
        ? 'text-red-600 dark:text-red-400'
        : 'text-yellow-600 dark:text-yellow-400'

  const isAuthenticated = oauthStatus?.authenticated ?? false

  return (
    <div className="rounded-lg border p-4 space-y-3">
      <div className="flex items-start justify-between">
        <div>
          <h3 className="font-semibold text-lg">{conn.display_name}</h3>
          <p className="text-sm text-muted-foreground">CIF: {conn.cif}</p>
        </div>
        <div className="flex items-center gap-2">
          <StatusBadge status={conn.status} />
          <span className="text-xs text-muted-foreground capitalize">
            {conn.environment}
          </span>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-2 text-sm">
        <div>
          <span className="text-muted-foreground">Status: </span>
          <span className={statusColor}>{conn.status}</span>
        </div>
        <div>
          <span className="text-muted-foreground">Last sync: </span>
          <span>{conn.last_sync_at ? new Date(conn.last_sync_at).toLocaleString('ro-RO') : 'Never'}</span>
        </div>
        {conn.status_message && (
          <div className="col-span-2">
            <span className="text-muted-foreground">Message: </span>
            <span className="text-yellow-600">{conn.status_message}</span>
          </div>
        )}
      </div>

      {/* OAuth section */}
      <div className="rounded border p-3 space-y-2 bg-muted/30">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            {isAuthenticated ? (
              <Shield className="h-4 w-4 text-green-600" />
            ) : (
              <ShieldOff className="h-4 w-4 text-muted-foreground" />
            )}
            <span className="text-sm font-medium">
              ANAF OAuth: {isAuthenticated ? 'Connected' : 'Not connected'}
            </span>
          </div>
          {isAuthenticated && oauthStatus?.expires_at && (
            <span className="text-xs text-muted-foreground">
              Expires: {new Date(oauthStatus.expires_at).toLocaleDateString('ro-RO')}
            </span>
          )}
        </div>

        {isAuthenticated && oauthStatus?.expires_in_seconds != null && oauthStatus.expires_in_seconds < 86400 * 7 && (
          <div className="flex items-center gap-1 text-xs text-yellow-600">
            <AlertTriangle className="h-3 w-3" />
            Token expires soon
          </div>
        )}

        <div className="flex gap-2">
          {isAuthenticated ? (
            <>
              <Button size="sm" variant="outline" onClick={() => onRefreshToken(conn.cif)}>
                <RefreshCw className="mr-1 h-3 w-3" /> Refresh Token
              </Button>
              <Button size="sm" variant="destructive" onClick={() => onOAuthRevoke(conn.cif)}>
                <ShieldOff className="mr-1 h-3 w-3" /> Disconnect
              </Button>
            </>
          ) : (
            <Button size="sm" onClick={() => onOAuthConnect(conn.cif)}>
              <ExternalLink className="mr-1 h-3 w-3" /> Connect to ANAF
            </Button>
          )}
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          {isAuthenticated && (
            <Button size="sm" variant="outline" onClick={() => onFetchMessages(conn)}>
              <Download className="mr-1 h-3 w-3" /> Fetch Messages
            </Button>
          )}
          <Button size="sm" variant="outline" onClick={() => onCleanup(conn)}>
            <Eraser className="mr-1 h-3 w-3" /> Clean Up
          </Button>
        </div>
        <Button size="sm" variant="ghost" className="text-destructive" onClick={() => onDelete(conn.cif)}>
          <Trash2 className="mr-1 h-3 w-3" /> Remove
        </Button>
      </div>
    </div>
  )
}

export default function ConnectorsTab() {
  const qc = useQueryClient()
  const [showAdd, setShowAdd] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<string | null>(null)
  const [fetchTarget, setFetchTarget] = useState<CompanyConnection | null>(null)
  const [cleanupTarget, setCleanupTarget] = useState<CompanyConnection | null>(null)
  const [newConn, setNewConn] = useState({ cif: '', display_name: '', environment: 'test' })

  const { data: connections = [], isLoading } = useQuery({
    queryKey: ['efactura-connections'],
    queryFn: () => efacturaApi.getConnections(),
  })

  const createMut = useMutation({
    mutationFn: () => efacturaApi.createConnection(newConn),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['efactura-connections'] })
      setShowAdd(false)
      setNewConn({ cif: '', display_name: '', environment: 'test' })
    },
  })

  const deleteMut = useMutation({
    mutationFn: (cif: string) => efacturaApi.deleteConnection(cif),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['efactura-connections'] })
      setDeleteTarget(null)
    },
  })

  const revokeMut = useMutation({
    mutationFn: (cif: string) => efacturaApi.oauthRevoke(cif),
    onSuccess: (_d, cif) => {
      qc.invalidateQueries({ queryKey: ['efactura-oauth-status', cif] })
    },
  })

  const refreshMut = useMutation({
    mutationFn: (cif: string) => efacturaApi.refreshOAuth(cif),
    onSuccess: (_d, cif) => {
      qc.invalidateQueries({ queryKey: ['efactura-oauth-status', cif] })
    },
  })

  const cleanupMut = useMutation({
    mutationFn: (cif: string) => efacturaApi.cleanupOldUnallocated(cif),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['efactura-unallocated'] })
      qc.invalidateQueries({ queryKey: ['efactura-unallocated-count'] })
    },
  })

  const handleOAuthConnect = (cif: string) => {
    window.open(efacturaApi.oauthAuthorizeUrl(cif), '_blank')
  }

  if (isLoading) {
    return (
      <div className="space-y-3">
        {[1, 2].map((i) => (
          <div key={i} className="h-48 animate-pulse rounded-lg border bg-muted/50" />
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">e-Factura Connections</h2>
        <Button onClick={() => setShowAdd(true)}>
          <Plus className="mr-1.5 h-4 w-4" /> Add Connection
        </Button>
      </div>

      {connections.length === 0 ? (
        <EmptyState
          icon={<Plug className="h-10 w-10" />}
          title="No connections"
          description="Add a company connection to start using e-Factura"
          action={
            <Button onClick={() => setShowAdd(true)}>
              <PlugZap className="mr-1.5 h-4 w-4" /> Add Connection
            </Button>
          }
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {connections.map((conn) => (
            <ConnectionCard
              key={conn.id}
              conn={conn}
              onDelete={setDeleteTarget}
              onOAuthConnect={handleOAuthConnect}
              onOAuthRevoke={(cif) => revokeMut.mutate(cif)}
              onRefreshToken={(cif) => refreshMut.mutate(cif)}
              onFetchMessages={setFetchTarget}
              onCleanup={setCleanupTarget}
            />
          ))}
        </div>
      )}

      {/* Add Connection Dialog */}
      <Dialog open={showAdd} onOpenChange={setShowAdd}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add Connection</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>CIF (Tax ID)</Label>
              <Input
                placeholder="e.g. 12345678"
                value={newConn.cif}
                onChange={(e) => setNewConn({ ...newConn, cif: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>Display Name</Label>
              <Input
                placeholder="e.g. AUTOWORLD SRL"
                value={newConn.display_name}
                onChange={(e) => setNewConn({ ...newConn, display_name: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>Environment</Label>
              <Select value={newConn.environment} onValueChange={(v) => setNewConn({ ...newConn, environment: v })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="test">Test (Sandbox)</SelectItem>
                  <SelectItem value="production">Production</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAdd(false)}>Cancel</Button>
            <Button
              onClick={() => createMut.mutate()}
              disabled={!newConn.cif || !newConn.display_name || createMut.isPending}
            >
              {createMut.isPending ? 'Creating...' : 'Create'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirm */}
      <ConfirmDialog
        open={!!deleteTarget}
        onOpenChange={() => setDeleteTarget(null)}
        title="Delete Connection"
        description={`Remove connection for CIF ${deleteTarget}? This will not delete imported invoices.`}
        onConfirm={() => deleteTarget && deleteMut.mutate(deleteTarget)}
        destructive
      />

      {/* Cleanup Confirm */}
      <ConfirmDialog
        open={!!cleanupTarget}
        onOpenChange={() => setCleanupTarget(null)}
        title="Clean Up Old Invoices"
        description={`Permanently delete unallocated invoices older than 15 days for ${cleanupTarget?.display_name} (${cleanupTarget?.cif})?`}
        onConfirm={() => {
          if (cleanupTarget) cleanupMut.mutate(cleanupTarget.cif)
          setCleanupTarget(null)
        }}
        destructive
      />

      {/* Cleanup result toast */}
      {cleanupMut.isSuccess && cleanupMut.data && (
        <div className="fixed bottom-4 right-4 z-50 flex items-center gap-2 rounded border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700 shadow-lg dark:border-green-800 dark:bg-green-900/90 dark:text-green-300">
          <CheckCircle className="h-4 w-4" />
          Cleaned up {cleanupMut.data.deleted} old invoice(s)
        </div>
      )}
      {cleanupMut.isPending && (
        <div className="fixed bottom-4 right-4 z-50 flex items-center gap-2 rounded border bg-background px-4 py-3 text-sm shadow-lg">
          <Loader2 className="h-4 w-4 animate-spin" />
          Cleaning up...
        </div>
      )}

      {/* Fetch Messages Dialog */}
      {fetchTarget && (
        <FetchMessagesDialog
          open={!!fetchTarget}
          onOpenChange={(v) => { if (!v) setFetchTarget(null) }}
          cif={fetchTarget.cif}
          displayName={fetchTarget.display_name}
        />
      )}
    </div>
  )
}
