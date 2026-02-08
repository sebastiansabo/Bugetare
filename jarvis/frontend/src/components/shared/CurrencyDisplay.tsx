import { cn } from '@/lib/utils'

interface CurrencyDisplayProps {
  value: number
  currency?: string
  className?: string
  showSign?: boolean
}

export function CurrencyDisplay({ value, currency = 'RON', className, showSign }: CurrencyDisplayProps) {
  const formatted = new Intl.NumberFormat('ro-RO', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(Math.abs(value))

  const isNegative = value < 0

  return (
    <span
      className={cn(
        'tabular-nums',
        isNegative && 'text-red-600 dark:text-red-400',
        !isNegative && showSign && 'text-green-600 dark:text-green-400',
        className,
      )}
    >
      {isNegative ? '-' : showSign && value > 0 ? '+' : ''}
      {formatted} {currency}
    </span>
  )
}
