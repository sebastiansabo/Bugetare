import { useState } from 'react'
import { ChevronDown, ChevronUp, FileText } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import type { RagSource } from '@/types/aiAgent'

interface RagSourcesProps {
  sources: RagSource[]
}

export function RagSources({ sources }: RagSourcesProps) {
  const [expanded, setExpanded] = useState(false)

  if (!sources.length) return null

  return (
    <div className="mt-2 rounded-lg border bg-muted/30 text-sm">
      <button
        onClick={() => setExpanded(!expanded)}
        className="flex w-full items-center justify-between px-3 py-2 text-xs font-medium text-muted-foreground hover:text-foreground"
      >
        <span className="flex items-center gap-1">
          <FileText className="h-3 w-3" />
          {sources.length} source{sources.length !== 1 && 's'} referenced
        </span>
        {expanded ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
      </button>

      {expanded && (
        <div className="space-y-2 border-t px-3 py-2">
          {sources.map((source, i) => (
            <div key={i} className="rounded border bg-background p-2">
              <div className="mb-1 flex items-center gap-2">
                <span className="text-xs font-medium text-muted-foreground">{source.source_type}</span>
                <Badge variant="secondary" className="text-[10px]">
                  {(source.score * 100).toFixed(0)}% match
                </Badge>
              </div>
              <p className="line-clamp-3 text-xs text-muted-foreground">{source.snippet}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
