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
      <Card className={className}>
        <CardContent className="p-4">
          <Skeleton className="mb-2 h-4 w-20" />
          <Skeleton className="h-8 w-24" />
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className={className}>
      <CardContent className="p-4">
        <div className="flex items-center justify-between">
          <p className="text-sm font-medium text-muted-foreground">{title}</p>
          {icon && <div className="text-muted-foreground">{icon}</div>}
        </div>
        <p className="mt-1 text-2xl font-bold">{value}</p>
        {(description || trend) && (
          <p className="mt-1 text-xs text-muted-foreground">
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
