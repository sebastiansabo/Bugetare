import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Plus, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { StatusBadge } from '@/components/shared/StatusBadge'
import { ConfirmDialog } from '@/components/shared/ConfirmDialog'
import { EmptyState } from '@/components/shared/EmptyState'
import { toast } from 'sonner'
import { api } from '@/api/client'

interface TagGroup {
  id: number
  name: string
  description: string | null
  color: string | null
  sort_order: number
  is_active: boolean
}

interface Tag {
  id: number
  name: string
  group_id: number | null
  group_name?: string
  color: string | null
  icon: string | null
  sort_order: number
  is_global: boolean
  is_active: boolean
}

const tagsApiLocal = {
  getGroups: () => api.get<TagGroup[]>('/api/tag-groups'),
  createGroup: (data: Partial<TagGroup>) => api.post<{ success: boolean; id: number }>('/api/tag-groups', data),
  updateGroup: (id: number, data: Partial<TagGroup>) => api.put<{ success: boolean }>(`/api/tag-groups/${id}`, data),
  deleteGroup: (id: number) => api.delete<{ success: boolean }>(`/api/tag-groups/${id}`),
  getTags: () => api.get<Tag[]>('/api/tags'),
  createTag: (data: Partial<Tag>) => api.post<{ success: boolean; id: number }>('/api/tags', data),
  updateTag: (id: number, data: Partial<Tag>) => api.put<{ success: boolean }>(`/api/tags/${id}`, data),
  deleteTag: (id: number) => api.delete<{ success: boolean }>(`/api/tags/${id}`),
}

export default function TagsTab() {
  return (
    <div className="space-y-6">
      <TagGroupsSection />
      <TagsSection />
    </div>
  )
}

function TagGroupsSection() {
  const queryClient = useQueryClient()
  const [showAdd, setShowAdd] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [color, setColor] = useState('#3b82f6')

  const { data: groups = [], isLoading } = useQuery({
    queryKey: ['settings', 'tagGroups'],
    queryFn: tagsApiLocal.getGroups,
  })

  const createMutation = useMutation({
    mutationFn: (data: Partial<TagGroup>) => tagsApiLocal.createGroup(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'tagGroups'] })
      setShowAdd(false)
      setName('')
      setDescription('')
      toast.success('Tag group created')
    },
    onError: () => toast.error('Failed to create tag group'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => tagsApiLocal.deleteGroup(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'tagGroups'] })
      setDeleteId(null)
      toast.success('Tag group deleted')
    },
    onError: () => toast.error('Failed to delete tag group'),
  })

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle>Tag Groups</CardTitle>
            <CardDescription>Organize tags into groups.</CardDescription>
          </div>
          <Button size="sm" onClick={() => setShowAdd(true)}>
            <Plus className="mr-1.5 h-4 w-4" />
            Add Group
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-10 animate-pulse rounded bg-muted" />
            ))}
          </div>
        ) : groups.length === 0 ? (
          <EmptyState title="No tag groups" description="Add your first group." />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Color</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Order</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {groups.map((g) => (
                <TableRow key={g.id}>
                  <TableCell>
                    {g.color && <div className="h-5 w-5 rounded border" style={{ backgroundColor: g.color }} />}
                  </TableCell>
                  <TableCell className="font-medium">{g.name}</TableCell>
                  <TableCell className="text-muted-foreground text-sm">{g.description || '-'}</TableCell>
                  <TableCell>{g.sort_order}</TableCell>
                  <TableCell>
                    <StatusBadge status={g.is_active ? 'active' : 'archived'} />
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setDeleteId(g.id)}>
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
            <DialogTitle>Add Tag Group</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label>Name</Label>
              <Input value={name} onChange={(e) => setName(e.target.value)} />
            </div>
            <div className="grid gap-2">
              <Label>Description</Label>
              <Input value={description} onChange={(e) => setDescription(e.target.value)} />
            </div>
            <div className="grid gap-2">
              <Label>Color</Label>
              <div className="flex gap-2">
                <input type="color" value={color} onChange={(e) => setColor(e.target.value)} className="h-8 w-8 cursor-pointer rounded border" />
                <Input value={color} onChange={(e) => setColor(e.target.value)} className="h-8" />
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAdd(false)}>Cancel</Button>
            <Button
              disabled={!name || createMutation.isPending}
              onClick={() => createMutation.mutate({ name, description, color, is_active: true })}
            >
              {createMutation.isPending ? 'Creating...' : 'Create'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete Tag Group"
        description="Tags in this group will become ungrouped."
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        destructive
      />
    </Card>
  )
}

function TagsSection() {
  const queryClient = useQueryClient()
  const [showAdd, setShowAdd] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [name, setName] = useState('')
  const [color, setColor] = useState('#3b82f6')

  const { data: tags = [], isLoading } = useQuery({
    queryKey: ['settings', 'tags'],
    queryFn: tagsApiLocal.getTags,
  })

  const createMutation = useMutation({
    mutationFn: (data: Partial<Tag>) => tagsApiLocal.createTag(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'tags'] })
      setShowAdd(false)
      setName('')
      toast.success('Tag created')
    },
    onError: () => toast.error('Failed to create tag'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => tagsApiLocal.deleteTag(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'tags'] })
      setDeleteId(null)
      toast.success('Tag deleted')
    },
    onError: () => toast.error('Failed to delete tag'),
  })

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle>Tags</CardTitle>
            <CardDescription>Tags can be attached to invoices, transactions, and more.</CardDescription>
          </div>
          <Button size="sm" onClick={() => setShowAdd(true)}>
            <Plus className="mr-1.5 h-4 w-4" />
            Add Tag
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="h-10 animate-pulse rounded bg-muted" />
            ))}
          </div>
        ) : tags.length === 0 ? (
          <EmptyState title="No tags" description="Add your first tag." />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Color</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Group</TableHead>
                <TableHead>Scope</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-20">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {tags.map((t) => (
                <TableRow key={t.id}>
                  <TableCell>
                    {t.color && <div className="h-5 w-5 rounded border" style={{ backgroundColor: t.color }} />}
                  </TableCell>
                  <TableCell className="font-medium">{t.name}</TableCell>
                  <TableCell className="text-muted-foreground">{t.group_name || '-'}</TableCell>
                  <TableCell>{t.is_global ? 'Global' : 'Personal'}</TableCell>
                  <TableCell>
                    <StatusBadge status={t.is_active ? 'active' : 'archived'} />
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" className="text-destructive" onClick={() => setDeleteId(t.id)}>
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
            <DialogTitle>Add Tag</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label>Name</Label>
              <Input value={name} onChange={(e) => setName(e.target.value)} />
            </div>
            <div className="grid gap-2">
              <Label>Color</Label>
              <div className="flex gap-2">
                <input type="color" value={color} onChange={(e) => setColor(e.target.value)} className="h-8 w-8 cursor-pointer rounded border" />
                <Input value={color} onChange={(e) => setColor(e.target.value)} className="h-8" />
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAdd(false)}>Cancel</Button>
            <Button
              disabled={!name || createMutation.isPending}
              onClick={() => createMutation.mutate({ name, color, is_global: true })}
            >
              {createMutation.isPending ? 'Creating...' : 'Create'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete Tag"
        description="This will remove the tag from all entities."
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        destructive
      />
    </Card>
  )
}
