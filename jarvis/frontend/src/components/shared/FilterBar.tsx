import { useState } from 'react'
import { ChevronDown, ChevronUp, Filter, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
  const [expanded, setExpanded] = useState(false)
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
    <div className={cn('rounded-lg border bg-card', className)}>
      <button
        onClick={() => setExpanded(!expanded)}
        className="flex w-full items-center justify-between px-4 py-2 text-sm font-medium"
      >
        <span className="flex items-center gap-2">
          <Filter className="h-4 w-4" />
          Filters
          {activeCount > 0 && (
            <span className="rounded-full bg-primary px-2 py-0.5 text-xs text-primary-foreground">{activeCount}</span>
          )}
        </span>
        {expanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
      </button>

      {expanded && (
        <div className="border-t px-4 py-3">
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
            {fields.map((field) => (
              <div key={field.key} className="space-y-1">
                <Label className="text-xs">{field.label}</Label>
                {field.type === 'select' ? (
                  <Select value={values[field.key] || '__all__'} onValueChange={(v) => updateField(field.key, v === '__all__' ? '' : v)}>
                    <SelectTrigger className="h-8 text-xs">
                      <SelectValue placeholder={field.placeholder || `All ${field.label}`} />
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
                    placeholder={field.placeholder}
                    className="h-8 text-xs"
                  />
                )}
              </div>
            ))}
          </div>
          {activeCount > 0 && (
            <div className="mt-3 flex justify-end">
              <Button variant="ghost" size="sm" onClick={clearAll} className="text-xs">
                <X className="mr-1 h-3 w-3" />
                Clear filters
              </Button>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
