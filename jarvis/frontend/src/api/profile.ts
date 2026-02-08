import { api } from './client'
import type { ProfileSummary, ProfileInvoice, ProfileActivity, ProfileBonus } from '@/types/profile'

export const profileApi = {
  getSummary: () => api.get<ProfileSummary>('/profile/api/summary'),

  getInvoices: (params?: { status?: string; start_date?: string; end_date?: string; search?: string; page?: number; per_page?: number }) => {
    const sp = new URLSearchParams()
    if (params?.status) sp.set('status', params.status)
    if (params?.start_date) sp.set('start_date', params.start_date)
    if (params?.end_date) sp.set('end_date', params.end_date)
    if (params?.search) sp.set('search', params.search)
    if (params?.page) sp.set('page', String(params.page))
    if (params?.per_page) sp.set('per_page', String(params.per_page))
    const qs = sp.toString()
    return api.get<{ invoices: ProfileInvoice[]; total: number; page: number; per_page: number }>(
      `/profile/api/invoices${qs ? `?${qs}` : ''}`,
    )
  },

  getHrEvents: (params?: { year?: number; month?: number; search?: string; page?: number; per_page?: number }) => {
    const sp = new URLSearchParams()
    if (params?.year) sp.set('year', String(params.year))
    if (params?.month) sp.set('month', String(params.month))
    if (params?.search) sp.set('search', params.search)
    if (params?.page) sp.set('page', String(params.page))
    if (params?.per_page) sp.set('per_page', String(params.per_page))
    const qs = sp.toString()
    return api.get<{ bonuses: ProfileBonus[]; total: number; page: number; per_page: number }>(
      `/profile/api/hr-events${qs ? `?${qs}` : ''}`,
    )
  },

  getActivity: (params?: { event_type?: string; page?: number; per_page?: number }) => {
    const sp = new URLSearchParams()
    if (params?.event_type) sp.set('event_type', params.event_type)
    if (params?.page) sp.set('page', String(params.page))
    if (params?.per_page) sp.set('per_page', String(params.per_page))
    const qs = sp.toString()
    return api.get<{ events: ProfileActivity[]; total: number; page: number; per_page: number }>(
      `/profile/api/activity${qs ? `?${qs}` : ''}`,
    )
  },
}
