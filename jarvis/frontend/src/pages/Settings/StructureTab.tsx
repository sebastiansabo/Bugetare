import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Plus, Trash2, Building2, Layers, GitBranch } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { SearchInput } from '@/components/shared/SearchInput'
import { StatCard } from '@/components/shared/StatCard'
import { ConfirmDialog } from '@/components/shared/ConfirmDialog'
import { EmptyState } from '@/components/shared/EmptyState'
import { organizationApi } from '@/api/organization'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import type { CompanyWithBrands, DepartmentStructure } from '@/types/organization'

type SubTab = 'companies' | 'structures'

export default function StructureTab() {
  const [activeTab, setActiveTab] = useState<SubTab>('companies')

  const { data: companies = [] } = useQuery({
    queryKey: ['settings', 'companiesConfig'],
    queryFn: organizationApi.getCompaniesConfig,
  })

  const { data: structures = [] } = useQuery({
    queryKey: ['settings', 'departmentStructures'],
    queryFn: organizationApi.getDepartmentStructures,
  })

  const uniqueDepts = new Set(structures.map((s) => s.department))

  return (
    <div className="space-y-6">
      {/* Summary Stats */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <StatCard title="Companies" value={companies.length} icon={<Building2 className="h-4 w-4" />} />
        <StatCard title="Departments" value={uniqueDepts.size} icon={<Layers className="h-4 w-4" />} />
        <StatCard title="Structure Mappings" value={structures.length} icon={<GitBranch className="h-4 w-4" />} />
      </div>

      {/* Sub-tab Navigation */}
      <div className="flex gap-1 rounded-lg border p-1">
        {(['companies', 'structures'] as SubTab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={cn(
              'rounded-md px-4 py-1.5 text-sm font-medium capitalize transition-colors',
              activeTab === tab ? 'bg-primary text-primary-foreground' : 'text-muted-foreground hover:bg-accent',
            )}
          >
            {tab}
          </button>
        ))}
      </div>

      {activeTab === 'companies' && <CompaniesSection companies={companies} />}
      {activeTab === 'structures' && <StructuresSection structures={structures} />}
    </div>
  )
}

function CompaniesSection({ companies }: { companies: CompanyWithBrands[] }) {
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [showAdd, setShowAdd] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [newCompany, setNewCompany] = useState('')
  const [newVat, setNewVat] = useState('')

  const createMutation = useMutation({
    mutationFn: (data: { company: string; vat?: string }) => organizationApi.createCompanyConfig(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'companiesConfig'] })
      setShowAdd(false)
      setNewCompany('')
      setNewVat('')
      toast.success('Company created')
    },
    onError: () => toast.error('Failed to create company'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => organizationApi.deleteCompanyConfig(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'companiesConfig'] })
      setDeleteId(null)
      toast.success('Company deleted')
    },
    onError: () => toast.error('Failed to delete company'),
  })

  const filtered = companies.filter(
    (c) => !search || c.company.toLowerCase().includes(search.toLowerCase()),
  )

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Companies</CardTitle>
          <Button size="sm" onClick={() => setShowAdd(true)}>
            <Plus className="mr-1.5 h-4 w-4" />
            Add Company
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <SearchInput value={search} onChange={setSearch} placeholder="Search companies..." className="mb-4" />

        {filtered.length === 0 ? (
          <EmptyState title="No companies found" description={search ? 'Try a different search.' : 'Add your first company.'} />
        ) : (
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
              {filtered.map((c) => (
                <TableRow key={c.id}>
                  <TableCell className="font-medium">{c.company}</TableCell>
                  <TableCell className="text-muted-foreground font-mono text-xs">{c.vat || '-'}</TableCell>
                  <TableCell className="text-muted-foreground text-xs">
                    {c.brands || '-'}
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setDeleteId(c.id)}>
                      <Trash2 className="h-3.5 w-3.5" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>

      <Dialog open={showAdd} onOpenChange={setShowAdd}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>Add Company</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label>Company Name</Label>
              <Input value={newCompany} onChange={(e) => setNewCompany(e.target.value)} />
            </div>
            <div className="grid gap-2">
              <Label>VAT Number</Label>
              <Input value={newVat} onChange={(e) => setNewVat(e.target.value)} placeholder="Optional" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAdd(false)}>Cancel</Button>
            <Button
              disabled={!newCompany || createMutation.isPending}
              onClick={() => createMutation.mutate({ company: newCompany, vat: newVat || undefined })}
            >
              {createMutation.isPending ? 'Creating...' : 'Create'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete Company"
        description="This will also remove associated brands and structures."
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        destructive
      />
    </Card>
  )
}

function StructuresSection({ structures }: { structures: DepartmentStructure[] }) {
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [showAdd, setShowAdd] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)

  const deleteMutation = useMutation({
    mutationFn: (id: number) => organizationApi.deleteDepartmentStructure(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'departmentStructures'] })
      setDeleteId(null)
      toast.success('Structure deleted')
    },
    onError: () => toast.error('Failed to delete structure'),
  })

  const createMutation = useMutation({
    mutationFn: (data: Record<string, unknown>) => organizationApi.createDepartmentStructure(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'departmentStructures'] })
      setShowAdd(false)
      toast.success('Structure created')
    },
    onError: () => toast.error('Failed to create structure'),
  })

  const filtered = structures.filter(
    (s) =>
      !search ||
      s.company?.toLowerCase().includes(search.toLowerCase()) ||
      s.department?.toLowerCase().includes(search.toLowerCase()),
  )

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Structure Mappings</CardTitle>
          <Button size="sm" onClick={() => setShowAdd(true)}>
            <Plus className="mr-1.5 h-4 w-4" />
            Add Mapping
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <SearchInput value={search} onChange={setSearch} placeholder="Search structures..." className="mb-4" />

        {filtered.length === 0 ? (
          <EmptyState title="No structures found" description={search ? 'Try a different search.' : 'Add your first mapping.'} />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Company</TableHead>
                <TableHead>Brand</TableHead>
                <TableHead>Department</TableHead>
                <TableHead>Subdepartment</TableHead>
                <TableHead>Manager</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.map((s) => (
                <TableRow key={s.id}>
                  <TableCell className="font-medium">{s.company}</TableCell>
                  <TableCell className="text-muted-foreground">{s.brand || '-'}</TableCell>
                  <TableCell>{s.department}</TableCell>
                  <TableCell className="text-muted-foreground">{s.subdepartment || '-'}</TableCell>
                  <TableCell className="text-muted-foreground">{s.manager || '-'}</TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setDeleteId(s.id)}>
                      <Trash2 className="h-3.5 w-3.5" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>

      <AddStructureDialog
        open={showAdd}
        onClose={() => setShowAdd(false)}
        onSave={(data) => createMutation.mutate(data)}
        isPending={createMutation.isPending}
      />

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete Structure Mapping"
        description="This action cannot be undone."
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        destructive
      />
    </Card>
  )
}

function AddStructureDialog({
  open,
  onClose,
  onSave,
  isPending,
}: {
  open: boolean
  onClose: () => void
  onSave: (data: Record<string, unknown>) => void
  isPending: boolean
}) {
  const [form, setForm] = useState({ company: '', brand: '', department: '', subdepartment: '', manager: '' })

  return (
    <Dialog open={open} onOpenChange={(o) => { if (!o) onClose() }}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Add Structure Mapping</DialogTitle>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-2">
              <Label>Company</Label>
              <Input value={form.company} onChange={(e) => setForm({ ...form, company: e.target.value })} />
            </div>
            <div className="grid gap-2">
              <Label>Brand</Label>
              <Input value={form.brand} onChange={(e) => setForm({ ...form, brand: e.target.value })} placeholder="Optional" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-2">
              <Label>Department</Label>
              <Input value={form.department} onChange={(e) => setForm({ ...form, department: e.target.value })} />
            </div>
            <div className="grid gap-2">
              <Label>Subdepartment</Label>
              <Input value={form.subdepartment} onChange={(e) => setForm({ ...form, subdepartment: e.target.value })} placeholder="Optional" />
            </div>
          </div>
          <div className="grid gap-2">
            <Label>Manager</Label>
            <Input value={form.manager} onChange={(e) => setForm({ ...form, manager: e.target.value })} placeholder="Optional" />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button
            disabled={!form.company || !form.department || isPending}
            onClick={() => onSave(form)}
          >
            {isPending ? 'Creating...' : 'Create'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
