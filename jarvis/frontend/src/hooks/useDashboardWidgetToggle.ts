import { useCallback, useSyncExternalStore } from 'react'

const STORAGE_KEY = 'jarvis_dashboard_prefs'

function getSnapshot() {
  return localStorage.getItem(STORAGE_KEY) ?? ''
}

function subscribe(cb: () => void) {
  window.addEventListener('storage', cb)
  return () => window.removeEventListener('storage', cb)
}

export function useDashboardWidgetToggle(widgetId: string) {
  const raw = useSyncExternalStore(subscribe, getSnapshot)

  const isOnDashboard = useCallback(() => {
    try {
      const parsed = JSON.parse(raw || '{}')
      const widget = (parsed.widgets ?? []).find((w: { id: string }) => w.id === widgetId)
      return widget?.visible ?? true
    } catch {
      return true
    }
  }, [raw, widgetId])

  const toggleDashboardWidget = useCallback(() => {
    try {
      const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}')
      if (!Array.isArray(parsed.widgets)) return
      parsed.widgets = parsed.widgets.map((w: { id: string; visible: boolean }) =>
        w.id === widgetId ? { ...w, visible: !w.visible } : w,
      )
      localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed))
      // Notify other components (same tab + cross-tab)
      window.dispatchEvent(new Event('storage'))
    } catch { /* noop */ }
  }, [widgetId])

  return { isOnDashboard, toggleDashboardWidget }
}
