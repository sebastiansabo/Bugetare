import { Link, useLocation } from 'react-router-dom'
import { LayoutDashboard, Bot, Calculator, Users, Landmark, FileText, Settings, LogOut, UserCircle, PanelLeftClose, PanelLeft } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useAuth } from '@/hooks/useAuth'
import { ThemeToggle } from './ThemeToggle'
import { Separator } from '@/components/ui/separator'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'

interface NavItem {
  path: string
  label: string
  icon: React.ElementType
  permission?: string
  external?: boolean
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

interface SidebarProps {
  collapsed?: boolean
  onToggle?: () => void
}

export function Sidebar({ collapsed = false, onToggle }: SidebarProps) {
  const { user } = useAuth()
  const location = useLocation()

  const visibleItems = navItems.filter((item) => {
    if (!item.permission) return true
    return user?.[item.permission as keyof typeof user]
  })

  return (
    <TooltipProvider delayDuration={collapsed ? 100 : 400}>
      <div className="flex h-full flex-col">
        {/* Header */}
        <div className={cn('flex h-14 items-center border-b', collapsed ? 'justify-center px-2' : 'px-4')}>
          <Link to="/app/dashboard" className="flex items-center gap-2 text-lg font-semibold">
            <Bot className="h-5 w-5 shrink-0 text-primary" />
            {!collapsed && <span>JARVIS</span>}
          </Link>
        </div>

        {/* Navigation */}
        <nav className={cn('flex-1 space-y-1', collapsed ? 'p-2' : 'p-3')}>
          {visibleItems.map((item) => {
            const Icon = item.icon
            const isActive = location.pathname.startsWith(item.path)
            const classes = cn(
              'flex items-center rounded-md text-sm font-medium transition-colors',
              collapsed ? 'justify-center px-2 py-2' : 'gap-3 px-3 py-2',
              isActive
                ? 'bg-primary text-primary-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
            )

            const linkContent = (
              <>
                <Icon className="h-4 w-4 shrink-0" />
                {!collapsed && <span>{item.label}</span>}
              </>
            )

            const link = item.external ? (
              <a key={item.path} href={item.path} className={classes}>
                {linkContent}
              </a>
            ) : (
              <Link key={item.path} to={item.path} className={classes}>
                {linkContent}
              </Link>
            )

            if (collapsed) {
              return (
                <Tooltip key={item.path}>
                  <TooltipTrigger asChild>{link}</TooltipTrigger>
                  <TooltipContent side="right">{item.label}</TooltipContent>
                </Tooltip>
              )
            }

            return link
          })}
        </nav>

        {/* Footer */}
        <div className={cn('border-t', collapsed ? 'p-2' : 'p-3')}>
          {collapsed ? (
            <>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Link
                    to="/app/profile"
                    className={cn(
                      'flex items-center justify-center rounded-md p-2 transition-colors',
                      location.pathname === '/app/profile'
                        ? 'bg-primary text-primary-foreground'
                        : 'hover:bg-accent',
                    )}
                  >
                    <UserCircle className="h-5 w-5 shrink-0" />
                  </Link>
                </TooltipTrigger>
                <TooltipContent side="right">{user?.name}</TooltipContent>
              </Tooltip>
              <div className="my-2 flex justify-center">
                <ThemeToggle />
              </div>
              <Separator className="my-2" />
              <Tooltip>
                <TooltipTrigger asChild>
                  <a
                    href="/logout"
                    className="flex items-center justify-center rounded-md p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
                  >
                    <LogOut className="h-4 w-4" />
                  </a>
                </TooltipTrigger>
                <TooltipContent side="right">Logout</TooltipContent>
              </Tooltip>
            </>
          ) : (
            <>
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
            </>
          )}

          {/* Collapse toggle — desktop only */}
          {onToggle && (
            <>
              <Separator className="my-2" />
              <button
                onClick={onToggle}
                className={cn(
                  'flex w-full items-center rounded-md text-sm text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground',
                  collapsed ? 'justify-center p-2' : 'gap-2 px-3 py-2',
                )}
              >
                {collapsed ? (
                  <PanelLeft className="h-4 w-4" />
                ) : (
                  <>
                    <PanelLeftClose className="h-4 w-4" />
                    <span>Collapse</span>
                  </>
                )}
              </button>
            </>
          )}
        </div>
      </div>
    </TooltipProvider>
  )
}
