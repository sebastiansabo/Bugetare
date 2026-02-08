import { create } from 'zustand'

interface AiAgentState {
  selectedConversationId: number | null
  selectedModel: string | null
  isSidebarOpen: boolean
  setConversation: (id: number | null) => void
  setModel: (model: string | null) => void
  toggleSidebar: () => void
  setSidebarOpen: (open: boolean) => void
}

export const useAiAgentStore = create<AiAgentState>((set) => ({
  selectedConversationId: null,
  selectedModel: null,
  isSidebarOpen: false,
  setConversation: (id) => set({ selectedConversationId: id }),
  setModel: (model) => set({ selectedModel: model }),
  toggleSidebar: () => set((s) => ({ isSidebarOpen: !s.isSidebarOpen })),
  setSidebarOpen: (open) => set({ isSidebarOpen: open }),
}))
