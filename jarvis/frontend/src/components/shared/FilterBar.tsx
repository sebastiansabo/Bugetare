import { X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { cn } from '@/lib/utils'

export interface FilterField {
  key: string
  label: string
  type: 'select' | 'date' | 'text'
  options?: { value: string; label: string }[]
  placeholder?: string
}

interface FilterBarProps {
  fields: FilterField[]
  values: Record<string, string>
  onChange: (values: Record<string, string>) => void
  className?: string
}

export function FilterBar({ fields, values, onChange, className }: FilterBarProps) {
  const activeCount = Object.values(values).filter(Boolean).length

  const updateField = (key: string, value: string) => {
    onChange({ ...values, [key]: value })
  }

  const clearAll = () => {
    const cleared: Record<string, string> = {}
    fields.forEach((f) => (cleared[f.key] = ''))
    onChange(cleared)
  }

  return (
    <div className={cn('flex flex-wrap items-center gap-2', className)}>
      {fields.map((field) => (
        <div key={field.key} className="min-w-0">
          {field.type === 'select' ? (
            <Select value={values[field.key] || '__all__'} onValueChange={(v) => updateField(field.key, v === '__all__' ? '' : v)}>
              <SelectTrigger className="h-8 w-auto min-w-[120px] gap-1 text-xs">
                <span className="text-muted-foreground">{field.label}:</span>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">All</SelectItem>
                {field.options?.map((opt) => (
                  <SelectItem key={opt.value} value={opt.value}>
                    {opt.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          ) : (
            <Input
              type={field.type}
              value={values[field.key] || ''}
              onChange={(e) => updateField(field.key, e.target.value)}
              placeholder={field.placeholder || field.label}
              className="h-8 w-auto min-w-[130px] text-xs"
            />
          )}
        </div>
      ))}
      {activeCount > 0 && (
        <Button variant="ghost" size="sm" onClick={clearAll} className="h-8 text-xs text-muted-foreground">
          <X className="mr-1 h-3 w-3" />
          Clear
        </Button>
      )}
    </div>
  )
}
