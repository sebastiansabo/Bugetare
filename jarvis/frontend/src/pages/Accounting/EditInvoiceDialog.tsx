import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import { invoicesApi } from '@/api/invoices'
import { toast } from 'sonner'
import type { Invoice } from '@/types/invoices'

interface SelectOption {
  value: string
  label: string
}

interface EditInvoiceDialogProps {
  invoice: Invoice
  open: boolean
  onClose: () => void
  statusOptions: SelectOption[]
  paymentOptions: SelectOption[]
}

export function EditInvoiceDialog({ invoice, open, onClose, statusOptions, paymentOptions }: EditInvoiceDialogProps) {
  const queryClient = useQueryClient()
  const [supplier, setSupplier] = useState(invoice.supplier)
  const [invoiceNumber, setInvoiceNumber] = useState(invoice.invoice_number)
  const [invoiceDate, setInvoiceDate] = useState(invoice.invoice_date)
  const [invoiceValue, setInvoiceValue] = useState(String(invoice.invoice_value))
  const [currency, setCurrency] = useState(invoice.currency)
  const [status, setStatus] = useState(invoice.status)
  const [paymentStatus, setPaymentStatus] = useState(invoice.payment_status)
  const [subtractVat, setSubtractVat] = useState(invoice.subtract_vat)
  const [vatRate, setVatRate] = useState(invoice.vat_rate != null ? String(invoice.vat_rate) : '')
  const [netValue, setNetValue] = useState(invoice.net_value != null ? String(invoice.net_value) : '')
  const [comment, setComment] = useState(invoice.comment || '')
  const [driveLink, setDriveLink] = useState(invoice.drive_link || '')

  const updateMutation = useMutation({
    mutationFn: (data: Partial<Invoice>) => invoicesApi.updateInvoice(invoice.id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['invoices'] })
      toast.success('Invoice updated')
      onClose()
    },
    onError: () => toast.error('Failed to update invoice'),
  })

  const handleSave = () => {
    updateMutation.mutate({
      supplier,
      invoice_number: invoiceNumber,
      invoice_date: invoiceDate,
      invoice_value: parseFloat(invoiceValue),
      currency,
      status,
      payment_status: paymentStatus,
      subtract_vat: subtractVat,
      vat_rate: vatRate ? parseFloat(vatRate) : null,
      net_value: netValue ? parseFloat(netValue) : null,
      comment: comment || null,
      drive_link: driveLink || null,
    })
  }

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Edit Invoice #{invoice.id}</DialogTitle>
          <DialogDescription>
            {invoice.supplier} &mdash; {invoice.invoice_number}
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <Label className="text-xs">Supplier</Label>
              <Input value={supplier} onChange={(e) => setSupplier(e.target.value)} />
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Invoice #</Label>
              <Input value={invoiceNumber} onChange={(e) => setInvoiceNumber(e.target.value)} />
            </div>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <div className="space-y-1.5">
              <Label className="text-xs">Date</Label>
              <Input type="date" value={invoiceDate} onChange={(e) => setInvoiceDate(e.target.value)} />
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Value</Label>
              <Input type="number" step="0.01" value={invoiceValue} onChange={(e) => setInvoiceValue(e.target.value)} />
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Currency</Label>
              <Input value={currency} onChange={(e) => setCurrency(e.target.value)} />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <Label className="text-xs">Status</Label>
              <Select value={status} onValueChange={setStatus}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {statusOptions.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Payment Status</Label>
              <Select value={paymentStatus} onValueChange={setPaymentStatus}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {paymentOptions.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <Switch checked={subtractVat} onCheckedChange={setSubtractVat} id="subtract-vat" />
              <Label htmlFor="subtract-vat" className="text-xs">Subtract VAT</Label>
            </div>
            {subtractVat && (
              <>
                <div className="space-y-1.5 flex-1">
                  <Label className="text-xs">VAT Rate (%)</Label>
                  <Input type="number" step="0.01" value={vatRate} onChange={(e) => setVatRate(e.target.value)} placeholder="19" />
                </div>
                <div className="space-y-1.5 flex-1">
                  <Label className="text-xs">Net Value</Label>
                  <Input type="number" step="0.01" value={netValue} onChange={(e) => setNetValue(e.target.value)} />
                </div>
              </>
            )}
          </div>
          <div className="space-y-1.5">
            <Label className="text-xs">Drive Link</Label>
            <Input value={driveLink} onChange={(e) => setDriveLink(e.target.value)} placeholder="https://drive.google.com/..." />
          </div>
          <div className="space-y-1.5">
            <Label className="text-xs">Comment</Label>
            <Textarea value={comment} onChange={(e) => setComment(e.target.value)} rows={2} />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSave} disabled={updateMutation.isPending}>
            {updateMutation.isPending ? 'Saving...' : 'Save'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
