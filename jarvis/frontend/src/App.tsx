import { lazy, Suspense } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/Layout'
import { Skeleton } from '@/components/ui/skeleton'

const Dashboard = lazy(() => import('./pages/Dashboard'))
const AiAgent = lazy(() => import('./pages/AiAgent/AiAgent'))
const Settings = lazy(() => import('./pages/Settings'))
const Profile = lazy(() => import('./pages/Profile'))
const Accounting = lazy(() => import('./pages/Accounting'))
const AddInvoice = lazy(() => import('./pages/Accounting/AddInvoice'))
const Hr = lazy(() => import('./pages/Hr'))
const Statements = lazy(() => import('./pages/Statements'))
const EFactura = lazy(() => import('./pages/EFactura'))

function PageLoader() {
  return (
    <div className="p-6 space-y-4">
      <Skeleton className="h-8 w-48" />
      <Skeleton className="h-4 w-96" />
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 mt-6">
        <Skeleton className="h-24" />
        <Skeleton className="h-24" />
        <Skeleton className="h-24" />
      </div>
    </div>
  )
}

export default function App() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route path="/app" element={<Layout />}>
          <Route index element={<Navigate to="dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="ai-agent" element={<AiAgent />} />
          <Route path="settings/*" element={<Settings />} />
          <Route path="profile" element={<Profile />} />
          <Route path="accounting" element={<Accounting />} />
          <Route path="accounting/add" element={<AddInvoice />} />
          <Route path="hr/*" element={<Hr />} />
          <Route path="statements/*" element={<Statements />} />
          <Route path="efactura/*" element={<EFactura />} />
          <Route path="*" element={<Navigate to="dashboard" replace />} />
        </Route>
      </Routes>
    </Suspense>
  )
}
