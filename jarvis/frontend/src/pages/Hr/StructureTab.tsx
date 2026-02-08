import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Plus,
  Trash2,
  Pencil,
  Building2,
  Tag,
  FolderTree,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { ConfirmDialog } from '@/components/shared/ConfirmDialog'
import { Badge } from '@/components/ui/badge'
import { hrApi } from '@/api/hr'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import type { StructureCompany, MasterItem } from '@/types/hr'

type Section = 'companies' | 'brands' | 'departments' | 'subdepartments' | 'dept-structure'

export default function StructureTab() {
  const [section, setSection] = useState<Section>('companies')

  const sections: { key: Section; label: string; icon: typeof Building2 }[] = [
    { key: 'companies', label: 'Companies', icon: Building2 },
    { key: 'brands', label: 'Brands', icon: Tag },
    { key: 'departments', label: 'Departments', icon: FolderTree },
    { key: 'subdepartments', label: 'Subdepartments', icon: FolderTree },
    { key: 'dept-structure', label: 'Dept Structure', icon: Building2 },
  ]

  return (
    <div className="space-y-4">
      <div className="flex gap-1">
        {sections.map((s) => (
          <button
            key={s.key}
            onClick={() => setSection(s.key)}
            className={cn(
              'flex items-center gap-1.5 rounded-md px-3 py-1.5 text-xs font-medium transition-colors',
              section === s.key
                ? 'bg-primary text-primary-foreground'
                : 'bg-muted text-muted-foreground hover:text-foreground',
            )}
          >
            <s.icon className="h-3.5 w-3.5" />
            {s.label}
          </button>
        ))}
      </div>

      {section === 'companies' && <CompaniesSection />}
      {section === 'brands' && <MasterSection type="brands" title="Master Brands" />}
      {section === 'departments' && <MasterSection type="departments" title="Master Departments" />}
      {section === 'subdepartments' && <MasterSection type="subdepartments" title="Master Subdepartments" />}
      {section === 'dept-structure' && <DeptStructureSection />}
    </div>
  )
}

/* ──── Companies ──── */

function CompaniesSection() {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editing, setEditing] = useState<StructureCompany | null>(null)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [name, setName] = useState('')
  const [vat, setVat] = useState('')

  const { data: companies = [] } = useQuery({
    queryKey: ['hr-companies-full'],
    queryFn: () => hrApi.getCompaniesFull(),
  })

  const createMutation = useMutation({
    mutationFn: (data: { company: string; vat?: string }) => hrApi.createCompany(data),
    onSuccess: () => { toast.success('Created'); queryClient.invalidateQueries({ queryKey: ['hr-companies-full'] }); setDialogOpen(false) },
    onError: () => toast.error('Failed'),
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: { company: string; vat?: string } }) => hrApi.updateCompany(id, data),
    onSuccess: () => { toast.success('Updated'); queryClient.invalidateQueries({ queryKey: ['hr-companies-full'] }); setDialogOpen(false) },
    onError: () => toast.error('Failed'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => hrApi.deleteCompany(id),
    onSuccess: () => { toast.success('Deleted'); queryClient.invalidateQueries({ queryKey: ['hr-companies-full'] }) },
    onError: () => toast.error('Failed'),
  })

  const openAdd = () => { setEditing(null); setName(''); setVat(''); setDialogOpen(true) }
  const openEdit = (c: StructureCompany) => { setEditing(c); setName(c.company); setVat(c.vat ?? ''); setDialogOpen(true) }

  const handleSave = () => {
    if (!name.trim()) return toast.error('Name required')
    const data = { company: name.trim(), vat: vat || undefined }
    if (editing) updateMutation.mutate({ id: editing.id, data })
    else createMutation.mutate(data)
  }

  return (
    <>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-3">
          <CardTitle className="text-sm">Companies ({companies.length})</CardTitle>
          <Button size="sm" onClick={openAdd}><Plus className="mr-1 h-3.5 w-3.5" />Add</Button>
        </CardHeader>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Company</TableHead>
                <TableHead>VAT</TableHead>
                <TableHead>Brands</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {companies.map((c) => (
                <TableRow key={c.id}>
                  <TableCell className="text-sm font-medium">{c.company}</TableCell>
                  <TableCell className="text-sm text-muted-foreground">{c.vat ?? '—'}</TableCell>
                  <TableCell>
                    <div className="flex flex-wrap gap-1">
                      {c.brands_list?.map((b) => (
                        <Badge key={b.brand} variant="outline" className="text-xs">{b.brand}</Badge>
                      ))}
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-1">
                      <Button variant="ghost" size="icon" className="h-7 w-7" onClick={() => openEdit(c)}>
                        <Pencil className="h-3.5 w-3.5" />
                      </Button>
                      <Button variant="ghost" size="icon" className="h-7 w-7 text-destructive" onClick={() => setDeleteId(c.id)}>
                        <Trash2 className="h-3.5 w-3.5" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>{editing ? 'Edit Company' : 'Add Company'}</DialogTitle>
            <DialogDescription>Company name and VAT number.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <div className="space-y-1.5">
              <Label className="text-xs">Company Name *</Label>
              <Input value={name} onChange={(e) => setName(e.target.value)} />
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">VAT Number</Label>
              <Input value={vat} onChange={(e) => setVat(e.target.value)} />
            </div>
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleSave}>{editing ? 'Update' : 'Create'}</Button>
          </div>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={deleteId !== null}
        title="Delete Company"
        description="This will delete the company and all associated data."
        onOpenChange={() => setDeleteId(null)}
        onConfirm={() => deleteId !== null && deleteMutation.mutate(deleteId)}
        destructive
      />
    </>
  )
}

/* ──── Master Brands/Departments/Subdepartments (generic) ──── */

function MasterSection({ type, title }: { type: 'brands' | 'departments' | 'subdepartments'; title: string }) {
  const queryClient = useQueryClient()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editing, setEditing] = useState<MasterItem | null>(null)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [name, setName] = useState('')

  const queryKey = [`hr-master-${type}`]

  const getFn = type === 'brands' ? hrApi.getMasterBrands : type === 'departments' ? hrApi.getMasterDepartments : hrApi.getMasterSubdepartments
  const createFn = type === 'brands' ? hrApi.createMasterBrand : type === 'departments' ? hrApi.createMasterDepartment : hrApi.createMasterSubdepartment
  const updateFn = type === 'brands' ? hrApi.updateMasterBrand : type === 'departments' ? hrApi.updateMasterDepartment : hrApi.updateMasterSubdepartment
  const deleteFn = type === 'brands' ? hrApi.deleteMasterBrand : type === 'departments' ? hrApi.deleteMasterDepartment : hrApi.deleteMasterSubdepartment

  const { data: items = [] } = useQuery({ queryKey, queryFn: getFn })

  const createMutation = useMutation({
    mutationFn: (data: { name: string }) => createFn(data),
    onSuccess: () => { toast.success('Created'); queryClient.invalidateQueries({ queryKey }); setDialogOpen(false) },
    onError: () => toast.error('Failed'),
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: { name: string; is_active: boolean } }) => updateFn(id, data),
    onSuccess: () => { toast.success('Updated'); queryClient.invalidateQueries({ queryKey }); setDialogOpen(false) },
    onError: () => toast.error('Failed'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteFn(id),
    onSuccess: () => { toast.success('Deleted'); queryClient.invalidateQueries({ queryKey }) },
    onError: () => toast.error('Failed'),
  })

  const openAdd = () => { setEditing(null); setName(''); setDialogOpen(true) }
  const openEdit = (item: MasterItem) => { setEditing(item); setName(item.name); setDialogOpen(true) }

  const handleSave = () => {
    if (!name.trim()) return toast.error('Name required')
    if (editing) updateMutation.mutate({ id: editing.id, data: { name: name.trim(), is_active: editing.is_active } })
    else createMutation.mutate({ name: name.trim() })
  }

  const active = items.filter((i) => i.is_active)
  const inactive = items.filter((i) => !i.is_active)

  return (
    <>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-3">
          <CardTitle className="text-sm">{title} ({active.length} active, {inactive.length} inactive)</CardTitle>
          <Button size="sm" onClick={openAdd}><Plus className="mr-1 h-3.5 w-3.5" />Add</Button>
        </CardHeader>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.map((item) => (
                <TableRow key={item.id} className={cn(!item.is_active && 'opacity-50')}>
                  <TableCell className="text-sm font-medium">{item.name}</TableCell>
                  <TableCell>
                    <Badge variant={item.is_active ? 'default' : 'secondary'} className="text-xs">
                      {item.is_active ? 'Active' : 'Inactive'}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-1">
                      <Button variant="ghost" size="icon" className="h-7 w-7" onClick={() => openEdit(item)}>
                        <Pencil className="h-3.5 w-3.5" />
                      </Button>
                      <Button variant="ghost" size="icon" className="h-7 w-7 text-destructive" onClick={() => setDeleteId(item.id)}>
                        <Trash2 className="h-3.5 w-3.5" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>{editing ? 'Edit' : 'Add'} {type.slice(0, -1)}</DialogTitle>
            <DialogDescription>Enter the name.</DialogDescription>
          </DialogHeader>
          <div className="space-y-1.5">
            <Label className="text-xs">Name *</Label>
            <Input value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleSave}>{editing ? 'Update' : 'Create'}</Button>
          </div>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={deleteId !== null}
        title="Delete Item"
        description="This will deactivate the item."
        onOpenChange={() => setDeleteId(null)}
        onConfirm={() => deleteId !== null && deleteMutation.mutate(deleteId)}
        destructive
      />
    </>
  )
}

/* ──── Department Structure ──── */

function DeptStructureSection() {
  const { data: structures = [] } = useQuery({
    queryKey: ['hr-dept-structure'],
    queryFn: () => hrApi.getDepartmentsFull(),
  })

  return (
    <Card>
      <CardHeader className="pb-3">
        <CardTitle className="text-sm">Department Structure ({structures.length})</CardTitle>
      </CardHeader>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Company</TableHead>
              <TableHead>Brand</TableHead>
              <TableHead>Department</TableHead>
              <TableHead>Subdepartment</TableHead>
              <TableHead>Manager</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {structures.map((s) => (
              <TableRow key={s.id}>
                <TableCell className="text-sm">{s.company}</TableCell>
                <TableCell className="text-sm text-muted-foreground">{s.brand || '—'}</TableCell>
                <TableCell className="text-sm font-medium">{s.department}</TableCell>
                <TableCell className="text-sm text-muted-foreground">{s.subdepartment || '—'}</TableCell>
                <TableCell className="text-sm text-muted-foreground">{s.manager || '—'}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  )
}
