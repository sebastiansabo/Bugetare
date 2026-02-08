import { api } from './client'
import type { RecentInvoice, OnlineUsersResponse, CompanySummary } from '@/types/dashboard'

export const dashboardApi = {
  getRecentInvoices: async (limit = 10): Promise<RecentInvoice[]> => {
    const data = await api.get<{ invoices: RecentInvoice[] }>(
      `/api/db/invoices?limit=${limit}&include_allocations=false`,
    )
    return data.invoices ?? data as unknown as RecentInvoice[]
  },

  getOnlineUsers: () => api.get<OnlineUsersResponse>('/api/online-users'),

  getCompanySummary: () =>
    api.get<CompanySummary[]>('/api/db/summary/company'),
}
