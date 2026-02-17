import { useState, useMemo } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { Tags, Search, Loader2, Wand2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Checkbox } from '@/components/ui/checkbox'
import { Input } from '@/components/ui/input'
import { tagsApi } from '@/api/tags'
import type { Tag, EntityTag } from '@/types/tags'

interface TagPickerProps {
  entityType: string
  entityId?: number
  entityIds?: number[]
  currentTags: EntityTag[]
  onTagsChanged: () => void
  children: React.ReactNode
}

export function TagPicker({
  entityType,
  entityId,
  entityIds,
  currentTags,
  onTagsChanged,
  children,
}: TagPickerProps) {
  const [open, setOpen] = useState(false)
  const [search, setSearch] = useState('')
  const [busy, setBusy] = useState<number | null>(null)
  const [suggestedIds, setSuggestedIds] = useState<Set<number>>(new Set())
  const [isSuggesting, setIsSuggesting] = useState(false)
  const qc = useQueryClient()

  const { data: allTags = [] } = useQuery({
    queryKey: ['tags'],
    queryFn: () => tagsApi.getTags(),
    enabled: open,
    staleTime: 30_000,
  })

  const currentTagIds = useMemo(() => new Set(currentTags.map((t) => t.id)), [currentTags])

  const filtered = useMemo(() => {
    if (!search) return allTags
    const q = search.toLowerCase()
    return allTags.filter((t) => t.name.toLowerCase().includes(q) || t.group_name?.toLowerCase().includes(q))
  }, [allTags, search])

  // Group by group_name
  const grouped = useMemo(() => {
    const map = new Map<string, Tag[]>()
    for (const tag of filtered) {
      const group = tag.group_name ?? 'Other'
      if (!map.has(group)) map.set(group, [])
      map.get(group)!.push(tag)
    }
    return map
  }, [filtered])

  const toggle = async (tag: Tag) => {
    setBusy(tag.id)
    try {
      const isActive = currentTagIds.has(tag.id)
      if (entityIds && entityIds.length > 0) {
        await tagsApi.bulkEntityTags(entityType, entityIds, tag.id, isActive ? 'remove' : 'add')
      } else if (entityId) {
        if (isActive) {
          await tagsApi.removeEntityTag(entityType, entityId, tag.id)
        } else {
          await tagsApi.addEntityTag(entityType, entityId, tag.id)
        }
      }
      qc.invalidateQueries({ queryKey: ['entity-tags'] })
      onTagsChanged()
    } catch { /* ignore */ }
    setBusy(null)
  }

  const handleSuggest = async () => {
    if (!entityId) return
    setIsSuggesting(true)
    try {
      const res = await tagsApi.suggestTags(entityType, entityId)
      const ids = new Set((res.suggestions ?? []).map((s) => s.id))
      setSuggestedIds(ids)
    } catch { setSuggestedIds(new Set()) }
    setIsSuggesting(false)
  }

  return (
    <Popover open={open} onOpenChange={(v) => { setOpen(v); if (!v) { setSearch(''); setSuggestedIds(new Set()) } }}>
      <PopoverTrigger asChild>
        {children}
      </PopoverTrigger>
      <PopoverContent align="start" className="w-56 p-0" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center gap-1.5 border-b px-2 py-1.5">
          <Search className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search tags..."
            className="h-7 border-none bg-transparent px-0 text-sm shadow-none focus-visible:ring-0"
          />
        </div>
        <div className="max-h-60 overflow-y-auto p-1">
          {allTags.length === 0 ? (
            <div className="py-4 text-center text-xs text-muted-foreground">No tags yet</div>
          ) : filtered.length === 0 ? (
            <div className="py-4 text-center text-xs text-muted-foreground">No matching tags</div>
          ) : (
            Array.from(grouped.entries()).map(([group, tags]) => (
              <div key={group}>
                <p className="px-2 py-1 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                  {group}
                </p>
                {tags.map((tag) => {
                  const isActive = currentTagIds.has(tag.id)
                  const isBusy = busy === tag.id
                  const isSuggested = suggestedIds.has(tag.id)
                  return (
                    <button
                      key={tag.id}
                      onClick={() => toggle(tag)}
                      disabled={isBusy}
                      className={`flex w-full items-center gap-2 rounded px-2 py-1 text-sm hover:bg-accent/50 disabled:opacity-50${isSuggested ? ' bg-amber-50 dark:bg-amber-950/30' : ''}`}
                    >
                      {isBusy ? (
                        <Loader2 className="h-3.5 w-3.5 animate-spin shrink-0" />
                      ) : (
                        <Checkbox checked={isActive} className="pointer-events-none" tabIndex={-1} />
                      )}
                      <span
                        className="h-2.5 w-2.5 rounded-full shrink-0"
                        style={{ backgroundColor: tag.color ?? '#6c757d' }}
                      />
                      <span className="truncate">{tag.name}</span>
                      {isSuggested && <span className="ml-auto text-[10px] text-amber-600 dark:text-amber-400">AI</span>}
                    </button>
                  )
                })}
              </div>
            ))
          )}
        </div>
        {entityId && (
          <div className="border-t px-2 py-1.5">
            <Button
              size="sm"
              variant="ghost"
              className="h-7 w-full justify-start gap-1.5 text-xs"
              disabled={isSuggesting}
              onClick={handleSuggest}
            >
              {isSuggesting ? <Loader2 className="h-3 w-3 animate-spin" /> : <Wand2 className="h-3 w-3" />}
              {isSuggesting ? 'Thinking...' : 'AI Suggest'}
            </Button>
          </div>
        )}
      </PopoverContent>
    </Popover>
  )
}

/** Convenience trigger button for use in bulk action bars. */
export function TagPickerButton({
  entityType,
  entityIds,
  onTagsChanged,
}: {
  entityType: string
  entityIds: number[]
  onTagsChanged: () => void
}) {
  return (
    <TagPicker
      entityType={entityType}
      entityIds={entityIds}
      currentTags={[]}
      onTagsChanged={onTagsChanged}
    >
      <button className="inline-flex items-center gap-1 rounded-md border px-2.5 py-1.5 text-sm font-medium hover:bg-accent">
        <Tags className="h-3.5 w-3.5" />
        Tag
      </button>
    </TagPicker>
  )
}
