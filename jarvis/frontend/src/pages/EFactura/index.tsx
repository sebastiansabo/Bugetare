import { lazy, Suspense, useMemo } from 'react'
import { Routes, Route, Navigate, NavLink } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import {
  Plug,
  Download,
  FileStack,
  FileSearch,
  ArrowLeftRight,
  RefreshCw,
  Tags,
} from 'lucide-react'
import { Skeleton } from '@/components/ui/skeleton'
import { PageHeader } from '@/components/shared/PageHeader'
import { StatCard } from '@/components/shared/StatCard'
import { efacturaApi } from '@/api/efactura'
import { cn } from '@/lib/utils'

const ConnectionsTab = lazy(() => import('./ConnectionsTab'))
const FetchTab = lazy(() => import('./FetchTab'))
const UnallocatedTab = lazy(() => import('./UnallocatedTab'))
const InvoicesTab = lazy(() => import('./InvoicesTab'))
const MappingsTab = lazy(() => import('./MappingsTab'))
const SyncTab = lazy(() => import('./SyncTab'))

const tabs = [
  { to: '/app/efactura/unallocated', label: 'Unallocated', icon: FileStack },
  { to: '/app/efactura/connections', label: 'Connections', icon: Plug },
  { to: '/app/efactura/fetch', label: 'Fetch', icon: Download },
  { to: '/app/efactura/invoices', label: 'Invoices', icon: FileSearch },
  { to: '/app/efactura/mappings', label: 'Mappings', icon: Tags },
  { to: '/app/efactura/sync', label: 'Sync', icon: RefreshCw },
] as const

function TabLoader() {
  return (
    <div className="space-y-3">
      <Skeleton className="h-10 w-full" />
      <Skeleton className="h-10 w-full" />
      <Skeleton className="h-10 w-full" />
    </div>
  )
}

export default function EFactura() {
  const { data: connections, isLoading: connLoading } = useQuery({
    queryKey: ['efactura-connections'],
    queryFn: () => efacturaApi.getConnections(),
  })

  const { data: unallocatedCount, isLoading: unallocLoading } = useQuery({
    queryKey: ['efactura-unallocated-count'],
    queryFn: () => efacturaApi.getUnallocatedCount(),
  })

  const { data: hiddenCount } = useQuery({
    queryKey: ['efactura-hidden-count'],
    queryFn: () => efacturaApi.getHiddenCount(),
  })

  const { data: binCount } = useQuery({
    queryKey: ['efactura-bin-count'],
    queryFn: () => efacturaApi.getBinCount(),
  })

  const { data: anafStatus } = useQuery({
    queryKey: ['efactura-anaf-status'],
    queryFn: () => efacturaApi.getAnafStatus(),
  })

  const activeConnections = useMemo(
    () => connections?.filter((c) => c.status === 'active').length ?? 0,
    [connections],
  )

  return (
    <div className="space-y-4">
      <PageHeader
        title="e-Factura"
        description="ANAF electronic invoicing — connections, sync & reconciliation"
      />

      {/* Summary stats */}
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-5">
        <StatCard
          title="Connections"
          value={`${activeConnections} / ${connections?.length ?? 0}`}
          icon={<Plug className="h-4 w-4" />}
          isLoading={connLoading}
        />
        <StatCard
          title="Unallocated"
          value={unallocatedCount ?? 0}
          icon={<FileStack className="h-4 w-4" />}
          isLoading={unallocLoading}
        />
        <StatCard
          title="Hidden"
          value={hiddenCount ?? 0}
          icon={<ArrowLeftRight className="h-4 w-4" />}
          isLoading={false}
        />
        <StatCard
          title="Bin"
          value={binCount ?? 0}
          icon={<ArrowLeftRight className="h-4 w-4" />}
          isLoading={false}
        />
        <StatCard
          title="Mode"
          value={anafStatus?.mock_mode ? 'Mock' : 'Live'}
          icon={<RefreshCw className="h-4 w-4" />}
          isLoading={false}
        />
      </div>

      {/* Tab nav */}
      <nav className="flex gap-1 overflow-x-auto border-b">
        {tabs.map((tab) => (
          <NavLink
            key={tab.to}
            to={tab.to}
            className={({ isActive }) =>
              cn(
                'flex shrink-0 items-center gap-1.5 border-b-2 px-4 py-2 text-sm font-medium transition-colors',
                isActive
                  ? 'border-primary text-primary'
                  : 'border-transparent text-muted-foreground hover:text-foreground',
              )
            }
          >
            <tab.icon className="h-4 w-4" />
            {tab.label}
            {tab.label === 'Unallocated' && (unallocatedCount ?? 0) > 0 && (
              <span className="ml-1 rounded-full bg-orange-100 px-1.5 py-0.5 text-xs font-semibold text-orange-700 dark:bg-orange-900/30 dark:text-orange-400">
                {unallocatedCount}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      {/* Tab content */}
      <Suspense fallback={<TabLoader />}>
        <Routes>
          <Route index element={<Navigate to="unallocated" replace />} />
          <Route path="connections" element={<ConnectionsTab />} />
          <Route path="fetch" element={<FetchTab />} />
          <Route path="unallocated" element={<UnallocatedTab />} />
          <Route path="invoices" element={<InvoicesTab />} />
          <Route path="mappings" element={<MappingsTab />} />
          <Route path="sync" element={<SyncTab />} />
        </Routes>
      </Suspense>
    </div>
  )
}
