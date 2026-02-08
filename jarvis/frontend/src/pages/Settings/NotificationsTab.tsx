import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Save, Send } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { settingsApi } from '@/api/settings'
import { toast } from 'sonner'

export default function NotificationsTab() {
  const queryClient = useQueryClient()

  const { data: settings, isLoading } = useQuery({
    queryKey: ['settings', 'notifications'],
    queryFn: settingsApi.getNotificationSettings,
  })

  const [form, setForm] = useState({
    smtp_host: '',
    smtp_port: '',
    smtp_tls: true,
    smtp_username: '',
    smtp_password: '',
    from_email: '',
    from_name: '',
    notify_on_allocation: false,
    global_cc: '',
  })

  const [testEmail, setTestEmail] = useState('')

  useEffect(() => {
    if (settings && typeof settings === 'object') {
      setForm({
        smtp_host: settings.smtp_host || '',
        smtp_port: settings.smtp_port || '',
        smtp_tls: String(settings.smtp_tls) === 'true',
        smtp_username: settings.smtp_username || '',
        smtp_password: settings.smtp_password || '',
        from_email: settings.from_email || '',
        from_name: settings.from_name || '',
        notify_on_allocation: String(settings.notify_on_allocation) === 'true',
        global_cc: settings.global_cc || '',
      })
    }
  }, [settings])

  const saveMutation = useMutation({
    mutationFn: (data: Record<string, string | boolean>) => settingsApi.saveNotificationSettings(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'notifications'] })
      toast.success('Settings saved')
    },
    onError: () => toast.error('Failed to save settings'),
  })

  const testMutation = useMutation({
    mutationFn: (email: string) => settingsApi.testEmail({ to: email }),
    onSuccess: () => toast.success('Test email sent'),
    onError: () => toast.error('Failed to send test email'),
  })

  const handleSave = () => {
    saveMutation.mutate({
      smtp_host: form.smtp_host,
      smtp_port: form.smtp_port,
      smtp_tls: String(form.smtp_tls),
      smtp_username: form.smtp_username,
      smtp_password: form.smtp_password,
      from_email: form.from_email,
      from_name: form.from_name,
      notify_on_allocation: String(form.notify_on_allocation),
      global_cc: form.global_cc,
    })
  }

  if (isLoading) {
    return (
      <div className="space-y-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="h-24 animate-pulse rounded bg-muted" />
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* SMTP Configuration */}
      <Card>
        <CardHeader>
          <CardTitle>SMTP Configuration</CardTitle>
          <CardDescription>Configure the email server for sending notifications.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div className="grid gap-2">
              <Label>SMTP Host</Label>
              <Input value={form.smtp_host} onChange={(e) => setForm({ ...form, smtp_host: e.target.value })} placeholder="smtp.example.com" />
            </div>
            <div className="grid gap-2">
              <Label>SMTP Port</Label>
              <Input value={form.smtp_port} onChange={(e) => setForm({ ...form, smtp_port: e.target.value })} placeholder="587" />
            </div>
            <div className="grid gap-2">
              <Label>Username</Label>
              <Input value={form.smtp_username} onChange={(e) => setForm({ ...form, smtp_username: e.target.value })} />
            </div>
            <div className="grid gap-2">
              <Label>Password</Label>
              <Input type="password" value={form.smtp_password} onChange={(e) => setForm({ ...form, smtp_password: e.target.value })} />
            </div>
            <div className="grid gap-2">
              <Label>From Email</Label>
              <Input value={form.from_email} onChange={(e) => setForm({ ...form, from_email: e.target.value })} placeholder="noreply@example.com" />
            </div>
            <div className="grid gap-2">
              <Label>From Name</Label>
              <Input value={form.from_name} onChange={(e) => setForm({ ...form, from_name: e.target.value })} placeholder="JARVIS" />
            </div>
          </div>
          <div className="mt-4 flex items-center gap-2">
            <Switch checked={form.smtp_tls} onCheckedChange={(v) => setForm({ ...form, smtp_tls: v })} />
            <Label>Use TLS</Label>
          </div>
        </CardContent>
      </Card>

      {/* Notification Preferences */}
      <Card>
        <CardHeader>
          <CardTitle>Preferences</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium">Allocation Notifications</p>
              <p className="text-xs text-muted-foreground">Send email when invoice is allocated to a department</p>
            </div>
            <Switch
              checked={form.notify_on_allocation}
              onCheckedChange={(v) => setForm({ ...form, notify_on_allocation: v })}
            />
          </div>
          <div className="grid gap-2">
            <Label>Global CC Address</Label>
            <Input value={form.global_cc} onChange={(e) => setForm({ ...form, global_cc: e.target.value })} placeholder="cc@example.com" />
          </div>
        </CardContent>
      </Card>

      {/* Actions */}
      <div className="flex items-center gap-3">
        <Button onClick={handleSave} disabled={saveMutation.isPending}>
          <Save className="mr-1.5 h-4 w-4" />
          {saveMutation.isPending ? 'Saving...' : 'Save Settings'}
        </Button>
        <div className="flex gap-2">
          <Input
            placeholder="test@example.com"
            value={testEmail}
            onChange={(e) => setTestEmail(e.target.value)}
            className="w-56"
          />
          <Button
            variant="outline"
            disabled={!testEmail || testMutation.isPending}
            onClick={() => testMutation.mutate(testEmail)}
          >
            <Send className="mr-1.5 h-4 w-4" />
            Send Test
          </Button>
        </div>
      </div>
    </div>
  )
}
