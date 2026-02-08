import { Link, useLocation } from 'react-router-dom'
import { LayoutDashboard, Bot, Calculator, Users, Landmark, FileText, Settings, LogOut, UserCircle } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useAuth } from '@/hooks/useAuth'
import { ThemeToggle } from './ThemeToggle'
import { Separator } from '@/components/ui/separator'

interface NavItem {
  path: string
  label: string
  icon: React.ElementType
  permission?: string
  external?: boolean // true = Jinja2 page, use <a> instead of <Link>
}

const navItems: NavItem[] = [
  { path: '/app/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/app/ai-agent', label: 'AI Agent', icon: Bot },
  { path: '/app/accounting', label: 'Accounting', icon: Calculator, permission: 'can_access_accounting' },
  { path: '/app/hr', label: 'HR', icon: Users, permission: 'can_access_hr' },
  { path: '/app/statements', label: 'Statements', icon: Landmark, permission: 'can_access_accounting' },
  { path: '/app/efactura', label: 'e-Factura', icon: FileText, permission: 'can_access_accounting' },
  { path: '/app/settings', label: 'Settings', icon: Settings, permission: 'can_access_settings' },
]

export function Sidebar() {
  const { user } = useAuth()
  const location = useLocation()

  const visibleItems = navItems.filter((item) => {
    if (!item.permission) return true
    return user?.[item.permission as keyof typeof user]
  })

  return (
    <div className="flex h-full flex-col">
      <div className="flex h-14 items-center border-b px-4">
        <Link to="/app/dashboard" className="flex items-center gap-2 text-lg font-semibold">
          <Bot className="h-5 w-5 text-primary" />
          JARVIS
        </Link>
      </div>

      <nav className="flex-1 space-y-1 p-3">
        {visibleItems.map((item) => {
          const Icon = item.icon
          const isActive = location.pathname.startsWith(item.path)
          const classes = cn(
            'flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors',
            isActive
              ? 'bg-primary text-primary-foreground'
              : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
          )
          return item.external ? (
            <a key={item.path} href={item.path} className={classes}>
              <Icon className="h-4 w-4" />
              {item.label}
            </a>
          ) : (
            <Link key={item.path} to={item.path} className={classes}>
              <Icon className="h-4 w-4" />
              {item.label}
            </Link>
          )
        })}
      </nav>

      <div className="border-t p-3">
        <Link
          to="/app/profile"
          className={cn(
            'flex items-center gap-3 rounded-md px-3 py-2 transition-colors',
            location.pathname === '/app/profile'
              ? 'bg-primary text-primary-foreground'
              : 'hover:bg-accent',
          )}
        >
          <UserCircle className="h-5 w-5 shrink-0" />
          <div className="min-w-0 flex-1">
            <div className="truncate text-sm font-medium">{user?.name}</div>
            <div className="truncate text-xs text-muted-foreground">{user?.role_name}</div>
          </div>
          <ThemeToggle />
        </Link>
        <Separator className="my-2" />
        <a
          href="/logout"
          className="flex items-center gap-2 rounded-md px-3 py-2 text-sm text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
        >
          <LogOut className="h-4 w-4" />
          Logout
        </a>
      </div>
    </div>
  )
}
