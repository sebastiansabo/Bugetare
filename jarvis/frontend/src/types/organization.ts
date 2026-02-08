export interface Company {
  id: number
  company: string
  vat: string | null
  created_at: string
}

export interface CompanyWithBrands extends Company {
  brands: string
  brands_list: { brand: string }[]
}

export interface Brand {
  id: number
  name: string
  is_active: boolean
}

export interface CompanyBrand {
  id: number
  company_id: number
  company: string
  brand: string
  brand_id: number
  is_active: boolean
  created_at: string
}

export interface Department {
  id: number
  company_id: number
  company: string
  department: string
  subdepartment: string | null
  manager: string | null
  manager_ids: number[] | null
  marketing: boolean
  is_active: boolean
  created_at: string
}

export interface DepartmentStructure {
  id: number
  company_id: number
  company: string
  brand: string | null
  department: string
  subdepartment: string | null
  manager: string | null
  marketing: boolean
  display_name: string
  unique_key: string
}

export interface StructureUnit {
  id: number
  company_id: number
  company: string
  brand: string | null
  department: string
  subdepartment: string | null
  manager: string | null
  marketing: boolean
  display_name: string
  unique_key: string
}
