import { create } from 'zustand'
import type { InvoiceFilters } from '../types/invoices'

interface AccountingState {
  filters: InvoiceFilters
  selectedInvoiceIds: number[]
  visibleColumns: string[]
  showRecycleBin: boolean
  setFilters: (filters: InvoiceFilters) => void
  updateFilter: <K extends keyof InvoiceFilters>(key: K, value: InvoiceFilters[K]) => void
  clearFilters: () => void
  setSelectedInvoiceIds: (ids: number[]) => void
  toggleInvoiceSelected: (id: number) => void
  clearSelected: () => void
  setVisibleColumns: (columns: string[]) => void
  setShowRecycleBin: (show: boolean) => void
}

const defaultColumns = [
  'supplier',
  'invoice_number',
  'invoice_date',
  'invoice_value',
  'currency',
  'company',
  'department',
  'status',
  'payment_status',
  'drive_link',
]

export const useAccountingStore = create<AccountingState>((set) => ({
  filters: {},
  selectedInvoiceIds: [],
  visibleColumns: defaultColumns,
  showRecycleBin: false,
  setFilters: (filters) => set({ filters }),
  updateFilter: (key, value) =>
    set((s) => ({ filters: { ...s.filters, [key]: value } })),
  clearFilters: () => set({ filters: {} }),
  setSelectedInvoiceIds: (ids) => set({ selectedInvoiceIds: ids }),
  toggleInvoiceSelected: (id) =>
    set((s) => ({
      selectedInvoiceIds: s.selectedInvoiceIds.includes(id)
        ? s.selectedInvoiceIds.filter((i) => i !== id)
        : [...s.selectedInvoiceIds, id],
    })),
  clearSelected: () => set({ selectedInvoiceIds: [] }),
  setVisibleColumns: (columns) => set({ visibleColumns: columns }),
  setShowRecycleBin: (show) => set({ showRecycleBin: show, selectedInvoiceIds: [] }),
}))
