import { api } from './client'
import type { Role, Permission, PermissionMatrix, RolePermission } from '@/types/roles'

export const rolesApi = {
  // Roles
  getRoles: () => api.get<Role[]>('/api/roles'),
  getRole: (id: number) => api.get<Role>(`/api/roles/${id}`),
  createRole: (data: Partial<Role>) => api.post<{ success: boolean; id: number }>('/api/roles', data),
  updateRole: (id: number, data: Partial<Role>) => api.put<{ success: boolean }>(`/api/roles/${id}`, data),
  deleteRole: (id: number) => api.delete<{ success: boolean }>(`/api/roles/${id}`),

  // Permissions v1
  getPermissions: () => api.get<Record<string, Permission[]>>('/api/permissions'),
  getPermissionsFlat: () => api.get<Permission[]>('/api/permissions/flat'),
  getRolePermissions: (roleId: number) => api.get<RolePermission[]>(`/api/roles/${roleId}/permissions`),
  setRolePermissions: (roleId: number, permissions: Record<string, boolean>) =>
    api.put<{ success: boolean }>(`/api/roles/${roleId}/permissions`, { permissions }),

  // Permissions v2 (matrix)
  getPermissionMatrix: () => api.get<PermissionMatrix>('/api/permissions/matrix'),
  getRolePermissionsV2: (roleId: number) =>
    api.get<Record<number, RolePermission>>(`/api/roles/${roleId}/permissions/v2`),
  setRolePermissionsV2: (roleId: number, permissions: Record<number, RolePermission>) =>
    api.put<{ success: boolean }>(`/api/roles/${roleId}/permissions/v2`, { permissions }),
  setSinglePermissionV2: (permissionId: number, roleId: number, data: { scope: string; granted: boolean }) =>
    api.put<{ success: boolean }>(`/api/permissions/v2/${permissionId}/role/${roleId}`, data),
}
