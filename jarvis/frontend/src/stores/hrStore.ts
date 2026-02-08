import { create } from 'zustand'

interface HrFilters {
  company?: string
  brand?: string
  department?: string
  year?: number
  month?: number
  search?: string
}

interface HrState {
  filters: HrFilters
  selectedBonusIds: number[]
  setFilters: (filters: HrFilters) => void
  updateFilter: <K extends keyof HrFilters>(key: K, value: HrFilters[K]) => void
  clearFilters: () => void
  setSelectedBonusIds: (ids: number[]) => void
  toggleBonusSelected: (id: number) => void
  clearSelected: () => void
}

const now = new Date()

export const useHrStore = create<HrState>((set) => ({
  filters: { year: now.getFullYear(), month: now.getMonth() + 1 },
  selectedBonusIds: [],
  setFilters: (filters) => set({ filters }),
  updateFilter: (key, value) =>
    set((s) => ({ filters: { ...s.filters, [key]: value } })),
  clearFilters: () =>
    set({ filters: { year: now.getFullYear(), month: now.getMonth() + 1 } }),
  setSelectedBonusIds: (ids) => set({ selectedBonusIds: ids }),
  toggleBonusSelected: (id) =>
    set((s) => ({
      selectedBonusIds: s.selectedBonusIds.includes(id)
        ? s.selectedBonusIds.filter((i) => i !== id)
        : [...s.selectedBonusIds, id],
    })),
  clearSelected: () => set({ selectedBonusIds: [] }),
}))
