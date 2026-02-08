import { Card, CardContent } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'

interface StatCardProps {
  title: string
  value: string | number
  icon?: React.ReactNode
  description?: string
  trend?: { value: number; label: string }
  isLoading?: boolean
  className?: string
}

export function StatCard({ title, value, icon, description, trend, isLoading, className }: StatCardProps) {
  if (isLoading) {
    return (
      <Card className={cn('gap-0 py-0', className)}>
        <CardContent className="px-3 py-2">
          <Skeleton className="mb-1 h-3 w-16" />
          <Skeleton className="h-5 w-20" />
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className={cn('gap-0 py-0', className)}>
      <CardContent className="px-3 py-2">
        <div className="flex items-center justify-between">
          <p className="text-xs font-medium text-muted-foreground">{title}</p>
          {icon && <div className="text-muted-foreground [&>svg]:h-3 [&>svg]:w-3">{icon}</div>}
        </div>
        <p className="text-base font-semibold leading-snug">{value}</p>
        {(description || trend) && (
          <p className="text-[11px] text-muted-foreground">
            {trend && (
              <span className={cn('mr-1 font-medium', trend.value >= 0 ? 'text-green-600' : 'text-red-600')}>
                {trend.value >= 0 ? '+' : ''}
                {trend.value}%
              </span>
            )}
            {description || trend?.label}
          </p>
        )}
      </CardContent>
    </Card>
  )
}
