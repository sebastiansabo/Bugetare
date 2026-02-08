import { api } from './client'
import type { User } from '../types'

interface CurrentUserResponse {
  authenticated: boolean
  user?: User
}

export const authApi = {
  getCurrentUser: () => api.get<CurrentUserResponse>('/api/auth/current-user'),
  changePassword: (currentPassword: string, newPassword: string) =>
    api.post<{ success: boolean; message?: string; error?: string }>('/api/auth/change-password', {
      current_password: currentPassword,
      new_password: newPassword,
    }),
}
