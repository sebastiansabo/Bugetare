import { create } from 'zustand'

type SettingsTab = 'users' | 'roles' | 'themes' | 'menus' | 'accounting' | 'notifications' | 'structure' | 'activity' | 'tags' | 'hr'

interface SettingsState {
  activeTab: SettingsTab
  selectedIds: number[]
  setActiveTab: (tab: SettingsTab) => void
  setSelectedIds: (ids: number[]) => void
  toggleSelected: (id: number) => void
  clearSelected: () => void
}

export const useSettingsStore = create<SettingsState>((set) => ({
  activeTab: 'users',
  selectedIds: [],
  setActiveTab: (tab) => set({ activeTab: tab, selectedIds: [] }),
  setSelectedIds: (ids) => set({ selectedIds: ids }),
  toggleSelected: (id) =>
    set((s) => ({
      selectedIds: s.selectedIds.includes(id)
        ? s.selectedIds.filter((i) => i !== id)
        : [...s.selectedIds, id],
    })),
  clearSelected: () => set({ selectedIds: [] }),
}))
