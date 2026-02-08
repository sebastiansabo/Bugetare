export interface Role {
  id: number
  name: string
  description: string | null
  can_add_invoices: boolean
  can_edit_invoices: boolean
  can_delete_invoices: boolean
  can_view_invoices: boolean
  can_access_accounting: boolean
  can_access_settings: boolean
  can_access_connectors: boolean
  can_access_templates: boolean
  can_access_hr: boolean
  is_hr_manager: boolean
  can_access_efactura: boolean
  can_access_statements: boolean
  created_at: string
}

export interface Permission {
  id: number
  module: string
  entity: string
  action: string
  description: string | null
}

export interface PermissionMatrix {
  modules: {
    key: string
    label: string
    entities: {
      key: string
      label: string
      actions: {
        id: number
        key: string
        label: string
        description: string | null
        is_scope_based: boolean
      }[]
    }[]
  }[]
}

export interface RolePermission {
  permission_id: number
  scope: 'deny' | 'own' | 'department' | 'all'
  granted: boolean
}
