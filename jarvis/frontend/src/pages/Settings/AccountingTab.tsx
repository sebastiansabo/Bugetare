import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Plus, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { ConfirmDialog } from '@/components/shared/ConfirmDialog'
import { EmptyState } from '@/components/shared/EmptyState'
import { settingsApi } from '@/api/settings'
import { toast } from 'sonner'
import type { VatRate, DropdownOption } from '@/types/settings'

export default function AccountingTab() {
  return (
    <div className="space-y-6">
      <VatRatesSection />
      <DropdownSection type="invoice_status" title="Invoice Status Options" />
      <DropdownSection type="payment_status" title="Payment Status Options" />
    </div>
  )
}

function VatRatesSection() {
  const queryClient = useQueryClient()
  const [name, setName] = useState('')
  const [rate, setRate] = useState('')
  const [isDefault, setIsDefault] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)

  const { data: vatRates = [], isLoading } = useQuery({
    queryKey: ['settings', 'vatRates'],
    queryFn: () => settingsApi.getVatRates(),
  })

  const createMutation = useMutation({
    mutationFn: (data: Partial<VatRate>) => settingsApi.createVatRate(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'vatRates'] })
      setName('')
      setRate('')
      setIsDefault(false)
      toast.success('VAT rate added')
    },
    onError: () => toast.error('Failed to add VAT rate'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => settingsApi.deleteVatRate(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'vatRates'] })
      setDeleteId(null)
      toast.success('VAT rate deleted')
    },
    onError: () => toast.error('Failed to delete VAT rate'),
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle>VAT Rates</CardTitle>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-10 animate-pulse rounded bg-muted" />
            ))}
          </div>
        ) : vatRates.length === 0 ? (
          <EmptyState title="No VAT rates" description="Add your first VAT rate below." />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Rate (%)</TableHead>
                <TableHead>Default</TableHead>
                <TableHead>Active</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {vatRates.map((vr) => (
                <TableRow key={vr.id}>
                  <TableCell className="font-medium">{vr.name}</TableCell>
                  <TableCell>{vr.rate}%</TableCell>
                  <TableCell>{vr.is_default ? 'Yes' : '-'}</TableCell>
                  <TableCell>{vr.is_active ? 'Yes' : 'No'}</TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setDeleteId(vr.id)}>
                      <Trash2 className="h-3.5 w-3.5" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}

        {/* Add Form */}
        <div className="mt-4 flex items-end gap-3 rounded-lg border p-3">
          <div className="grid gap-1">
            <Label className="text-xs">Name</Label>
            <Input className="h-8 w-32" value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="grid gap-1">
            <Label className="text-xs">Rate (%)</Label>
            <Input className="h-8 w-24" type="number" value={rate} onChange={(e) => setRate(e.target.value)} />
          </div>
          <div className="flex items-center gap-1.5">
            <Switch checked={isDefault} onCheckedChange={setIsDefault} />
            <Label className="text-xs">Default</Label>
          </div>
          <Button
            size="sm"
            disabled={!name || !rate || createMutation.isPending}
            onClick={() => createMutation.mutate({ name, rate: Number(rate), is_default: isDefault, is_active: true })}
          >
            <Plus className="mr-1 h-3.5 w-3.5" />
            Add
          </Button>
        </div>
      </CardContent>

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete VAT Rate"
        description="This action cannot be undone."
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        destructive
      />
    </Card>
  )
}

function DropdownSection({ type, title }: { type: string; title: string }) {
  const queryClient = useQueryClient()
  const [value, setValue] = useState('')
  const [label, setLabel] = useState('')
  const [color, setColor] = useState('#3b82f6')
  const [deleteId, setDeleteId] = useState<number | null>(null)

  const { data: options = [], isLoading } = useQuery({
    queryKey: ['settings', 'dropdownOptions', type],
    queryFn: () => settingsApi.getDropdownOptions(type),
  })

  const createMutation = useMutation({
    mutationFn: (data: Partial<DropdownOption>) => settingsApi.addDropdownOption(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'dropdownOptions', type] })
      setValue('')
      setLabel('')
      toast.success('Option added')
    },
    onError: () => toast.error('Failed to add option'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => settingsApi.deleteDropdownOption(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'dropdownOptions', type] })
      setDeleteId(null)
      toast.success('Option deleted')
    },
    onError: () => toast.error('Failed to delete option'),
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <CardDescription>Manage {type.replace('_', ' ')} options for invoices.</CardDescription>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-10 animate-pulse rounded bg-muted" />
            ))}
          </div>
        ) : options.length === 0 ? (
          <EmptyState title="No options" description="Add your first option below." />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Color</TableHead>
                <TableHead>Value</TableHead>
                <TableHead>Label</TableHead>
                <TableHead>Order</TableHead>
                <TableHead>Notify</TableHead>
                <TableHead>Active</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {options.map((opt) => (
                <TableRow key={opt.id}>
                  <TableCell>
                    {opt.color && (
                      <div
                        className="h-5 w-5 rounded border"
                        style={{ backgroundColor: opt.color, opacity: opt.opacity ?? 1 }}
                      />
                    )}
                  </TableCell>
                  <TableCell className="font-mono text-xs">{opt.value}</TableCell>
                  <TableCell className="font-medium">{opt.label}</TableCell>
                  <TableCell>{opt.sort_order}</TableCell>
                  <TableCell>{opt.notify_on_status ? 'Yes' : '-'}</TableCell>
                  <TableCell>{opt.is_active ? 'Yes' : 'No'}</TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setDeleteId(opt.id)}>
                      <Trash2 className="h-3.5 w-3.5" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}

        {/* Add Form */}
        <div className="mt-4 flex items-end gap-3 rounded-lg border p-3">
          <div className="grid gap-1">
            <Label className="text-xs">Value</Label>
            <Input className="h-8 w-28" value={value} onChange={(e) => setValue(e.target.value)} />
          </div>
          <div className="grid gap-1">
            <Label className="text-xs">Label</Label>
            <Input className="h-8 w-28" value={label} onChange={(e) => setLabel(e.target.value)} />
          </div>
          <div className="grid gap-1">
            <Label className="text-xs">Color</Label>
            <input type="color" value={color} onChange={(e) => setColor(e.target.value)} className="h-8 w-8 cursor-pointer rounded border" />
          </div>
          <Button
            size="sm"
            disabled={!value || !label || createMutation.isPending}
            onClick={() =>
              createMutation.mutate({
                dropdown_type: type,
                value,
                label,
                color,
                is_active: true,
                sort_order: options.length,
              })
            }
          >
            <Plus className="mr-1 h-3.5 w-3.5" />
            Add
          </Button>
        </div>
      </CardContent>

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete Option"
        description="This action cannot be undone."
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        destructive
      />
    </Card>
  )
}
