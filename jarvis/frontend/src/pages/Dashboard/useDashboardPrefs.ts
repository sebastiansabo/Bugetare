import { useState, useEffect, useMemo, useCallback } from 'react'
import type { User } from '@/types'
import { WIDGET_CATALOG, type DashboardPreferences, type WidgetPref, type WidgetLayout } from './types'

const STORAGE_KEY = 'jarvis_dashboard_prefs'
const CURRENT_VERSION = 2
const COLS = 6

function hasPermission(user: User | null, permission?: keyof User): boolean {
  if (!permission) return true
  return !!user?.[permission]
}

/** Auto-place widgets in a 6-col grid using row-packing. */
function autoPlace(widgets: { id: string; visible: boolean }[]): WidgetPref[] {
  const catalogMap = new Map(WIDGET_CATALOG.map(w => [w.id, w]))
  let x = 0, y = 0, rowMaxH = 0
  return widgets.map(w => {
    const def = catalogMap.get(w.id)
    const width = def?.defaultLayout.w ?? 2
    const height = def?.defaultLayout.h ?? 3
    if (x + width > COLS) { x = 0; y += rowMaxH; rowMaxH = 0 }
    const layout: WidgetLayout = {
      i: w.id, x, y, w: width, h: height,
      minW: def?.defaultLayout.minW, minH: def?.defaultLayout.minH,
    }
    x += width
    rowMaxH = Math.max(rowMaxH, height)
    return { id: w.id, visible: w.visible, layout }
  })
}

function buildDefaults(): DashboardPreferences {
  const widgets = WIDGET_CATALOG.map(w => ({ id: w.id, visible: w.defaultVisible }))
  return { version: CURRENT_VERSION, widgets: autoPlace(widgets) }
}

function loadPrefs(): DashboardPreferences {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return buildDefaults()
    const parsed = JSON.parse(raw)

    // Migrate v1 → v2: convert order-based to layout-based
    if (parsed.version === 1 && Array.isArray(parsed.widgets)) {
      const sorted = [...parsed.widgets].sort((a: { order: number }, b: { order: number }) => a.order - b.order)
      const migrated = autoPlace(sorted.map((w: { id: string; visible: boolean }) => ({ id: w.id, visible: w.visible })))
      return { version: CURRENT_VERSION, widgets: migrated }
    }

    if (parsed.version !== CURRENT_VERSION) return buildDefaults()

    // Ensure any new widgets are added
    const existing = new Set((parsed.widgets as WidgetPref[]).map(w => w.id))
    let maxY = 0
    for (const wp of parsed.widgets as WidgetPref[]) {
      maxY = Math.max(maxY, (wp.layout?.y ?? 0) + (wp.layout?.h ?? 3))
    }
    for (const def of WIDGET_CATALOG) {
      if (!existing.has(def.id)) {
        parsed.widgets.push({
          id: def.id,
          visible: def.defaultVisible,
          layout: { i: def.id, x: 0, y: maxY, w: def.defaultLayout.w, h: def.defaultLayout.h, minW: def.defaultLayout.minW, minH: def.defaultLayout.minH },
        })
        maxY += def.defaultLayout.h
      }
    }
    // Remove widgets no longer in catalog
    const catalogIds = new Set(WIDGET_CATALOG.map(w => w.id))
    parsed.widgets = parsed.widgets.filter((w: WidgetPref) => catalogIds.has(w.id))
    return parsed as DashboardPreferences
  } catch {
    return buildDefaults()
  }
}

export function useDashboardPrefs(user: User | null) {
  const [prefs, setPrefs] = useState<DashboardPreferences>(loadPrefs)

  // Persist to localStorage
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
  }, [prefs])

  // Listen for cross-page storage events (module publishing)
  useEffect(() => {
    const handler = () => setPrefs(loadPrefs())
    window.addEventListener('storage', handler)
    return () => window.removeEventListener('storage', handler)
  }, [])

  const permittedWidgets = useMemo(() => {
    const catalogMap = new Map(WIDGET_CATALOG.map(w => [w.id, w]))
    return prefs.widgets.filter(w => {
      const def = catalogMap.get(w.id)
      return def && hasPermission(user, def.permission)
    })
  }, [prefs, user])

  const visibleWidgets = useMemo(() => {
    return permittedWidgets.filter(w => w.visible)
  }, [permittedWidgets])

  const toggleWidget = useCallback((id: string) => {
    setPrefs(prev => ({
      ...prev,
      widgets: prev.widgets.map(w =>
        w.id === id ? { ...w, visible: !w.visible } : w,
      ),
    }))
  }, [])

  /** Called by react-grid-layout onLayoutChange */
  const updateLayout = useCallback((layouts: WidgetLayout[]) => {
    setPrefs(prev => {
      const layoutMap = new Map(layouts.map(l => [l.i, l]))
      return {
        ...prev,
        widgets: prev.widgets.map(w => {
          const nl = layoutMap.get(w.id)
          if (!nl) return w
          return { ...w, layout: { ...w.layout, x: nl.x, y: nl.y, w: nl.w, h: nl.h } }
        }),
      }
    })
  }, [])

  /** Update a single widget's width from CustomizeSheet */
  const setWidgetWidth = useCallback((id: string, width: number) => {
    setPrefs(prev => ({
      ...prev,
      widgets: prev.widgets.map(w =>
        w.id === id ? { ...w, layout: { ...w.layout, w: Math.max(1, Math.min(6, width)) } } : w,
      ),
    }))
  }, [])

  const resetDefaults = useCallback(() => {
    setPrefs(buildDefaults())
  }, [])

  const isVisible = useCallback((id: string) => {
    return visibleWidgets.some(w => w.id === id)
  }, [visibleWidgets])

  return { permittedWidgets, visibleWidgets, toggleWidget, updateLayout, setWidgetWidth, resetDefaults, isVisible }
}
