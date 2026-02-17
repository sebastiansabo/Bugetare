import { create } from 'zustand'
import type { MktProjectFilters } from '@/types/marketing'

const COLUMNS_KEY = 'marketing-project-columns'

const defaultColumns = [
  'name', 'company_name', 'brand_name', 'project_type', 'status',
  'total_budget', 'total_spent', 'owner_name', 'start_date', 'end_date',
]

function loadColumns(): string[] {
  try {
    const stored = localStorage.getItem(COLUMNS_KEY)
    if (stored) {
      const parsed = JSON.parse(stored) as string[]
      if (Array.isArray(parsed) && parsed.length > 0) return parsed
    }
  } catch { /* ignore */ }
  return defaultColumns
}

function saveColumns(cols: string[]) {
  try { localStorage.setItem(COLUMNS_KEY, JSON.stringify(cols)) } catch { /* ignore */ }
}

interface MarketingState {
  filters: MktProjectFilters
  selectedIds: number[]
  visibleColumns: string[]
  viewMode: 'table' | 'cards'

  updateFilter: <K extends keyof MktProjectFilters>(key: K, value: MktProjectFilters[K]) => void
  clearFilters: () => void
  toggleSelected: (id: number) => void
  selectAll: (ids: number[]) => void
  clearSelected: () => void
  setVisibleColumns: (cols: string[]) => void
  setViewMode: (mode: 'table' | 'cards') => void
}

export const useMarketingStore = create<MarketingState>((set) => ({
  filters: { limit: 50, offset: 0 },
  selectedIds: [],
  visibleColumns: loadColumns(),
  viewMode: (localStorage.getItem('marketing-view-mode') as 'table' | 'cards') || 'table',

  updateFilter: (key, value) =>
    set((s) => ({ filters: { ...s.filters, [key]: value, offset: 0 } })),

  clearFilters: () =>
    set({ filters: { limit: 50, offset: 0 }, selectedIds: [] }),

  toggleSelected: (id) =>
    set((s) => ({
      selectedIds: s.selectedIds.includes(id)
        ? s.selectedIds.filter((x) => x !== id)
        : [...s.selectedIds, id],
    })),

  selectAll: (ids) => set({ selectedIds: ids }),
  clearSelected: () => set({ selectedIds: [] }),

  setVisibleColumns: (cols) => {
    saveColumns(cols)
    set({ visibleColumns: cols })
  },

  setViewMode: (mode) => {
    try { localStorage.setItem('marketing-view-mode', mode) } catch { /* ignore */ }
    set({ viewMode: mode })
  },
}))
