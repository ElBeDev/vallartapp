'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { toast } from 'sonner'
import {
  Bell, Send, Megaphone, CalendarPlus, Tag, Star,
  Users, Loader2, CheckCircle2, Clock
} from 'lucide-react'

const NOTIFICATION_TYPES = [
  { value: 'broadcast', label: 'Broadcast',  icon: Megaphone,   color: 'text-purple-600 bg-purple-50' },
  { value: 'new_event', label: 'New Event',  icon: CalendarPlus, color: 'text-teal-600 bg-teal-50' },
  { value: 'promo',     label: 'Promo / Deal', icon: Tag,        color: 'text-yellow-600 bg-yellow-50' },
  { value: 'review',    label: 'Review Alert', icon: Star,       color: 'text-blue-600 bg-blue-50' },
]

interface SentNotification {
  title: string
  body: string
  type: string
  sent: number
  sentAt: Date
}

export default function NotificationsPage() {
  const supabase = createClient()

  const [title,      setTitle]      = useState('')
  const [body,       setBody]       = useState('')
  const [type,       setType]       = useState('broadcast')
  const [sandbox,    setSandbox]    = useState(true)   // default to sandbox for safety
  const [loading,    setLoading]    = useState(false)
  const [history,    setHistory]    = useState<SentNotification[]>([])
  const [tokenCount, setTokenCount] = useState<number | null>(null)

  // Fetch token count to show how many devices will receive the push
  const refreshTokenCount = async () => {
    const { count } = await supabase
      .from('device_tokens')
      .select('*', { count: 'exact', head: true })
    setTokenCount(count ?? 0)
  }

  useState(() => { refreshTokenCount() })

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !body.trim()) { toast.error('Title and body are required'); return }

    setLoading(true)
    try {
      const { data: { session } } = await supabase.auth.getSession()
      const res = await fetch(
        'https://nvubaobivraevlnlpsjr.supabase.co/functions/v1/send-push-notification',
        {
          method: 'POST',
          headers: {
            'Content-Type':  'application/json',
            'Authorization': `Bearer ${session?.access_token}`,
          },
          body: JSON.stringify({ title, body, type, sandbox, saveToInbox: true }),
        }
      )
      const result = await res.json()
      if (!res.ok) throw new Error(result.error ?? 'Unknown error')

      toast.success(`Sent to ${result.sent} device${result.sent !== 1 ? 's' : ''}!`)
      setHistory(h => [{ title, body, type, sent: result.sent, sentAt: new Date() }, ...h])
      setTitle('')
      setBody('')
    } catch (err) {
      toast.error(String(err))
    }
    setLoading(false)
  }

  return (
    <div className="p-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-slate-800">Push Notifications</h1>
        <p className="text-slate-500 mt-1">
          Send real-time alerts to all VallartApp users
          {tokenCount !== null && (
            <span className="ml-2 text-slate-400">— <strong className="text-slate-600">{tokenCount}</strong> registered devices</span>
          )}
        </p>
      </div>

      <div className="grid lg:grid-cols-5 gap-6">
        {/* Compose form */}
        <div className="lg:col-span-3 bg-white rounded-2xl border shadow-sm p-6 space-y-5">
          <div className="flex items-center gap-2 mb-1">
            <Bell className="h-5 w-5 text-orange-500" />
            <h2 className="text-lg font-semibold text-slate-800">Compose</h2>
          </div>

          <form onSubmit={handleSend} className="space-y-4">
            {/* Type selector */}
            <div className="space-y-2">
              <Label className="text-slate-600 text-sm">Notification Type</Label>
              <div className="grid grid-cols-2 gap-2">
                {NOTIFICATION_TYPES.map(({ value, label, icon: Icon, color }) => (
                  <button
                    key={value}
                    type="button"
                    onClick={() => setType(value)}
                    className={`flex items-center gap-2 px-3 py-2.5 rounded-xl border text-sm font-medium transition-all
                      ${type === value
                        ? 'border-orange-500 bg-orange-50 text-orange-700 shadow-sm'
                        : 'border-slate-200 text-slate-600 hover:border-slate-300'
                      }`}
                  >
                    <div className={`p-1 rounded-lg ${type === value ? 'bg-orange-100' : color}`}>
                      <Icon className="h-3.5 w-3.5" />
                    </div>
                    {label}
                  </button>
                ))}
              </div>
            </div>

            {/* Title */}
            <div className="space-y-1.5">
              <Label className="text-slate-600 text-sm">Title <span className="text-red-400">*</span></Label>
              <Input
                value={title}
                onChange={e => setTitle(e.target.value)}
                placeholder="e.g. New Event This Weekend!"
                maxLength={65}
                className="border-slate-200 focus:border-orange-500"
                required
              />
              <p className="text-slate-400 text-xs">{title.length} / 65</p>
            </div>

            {/* Body */}
            <div className="space-y-1.5">
              <Label className="text-slate-600 text-sm">Message <span className="text-red-400">*</span></Label>
              <Textarea
                value={body}
                onChange={e => setBody(e.target.value)}
                placeholder="e.g. Jazz at the Marina starts at 8pm — tap to see details."
                rows={3}
                maxLength={200}
                className="border-slate-200 focus:border-orange-500 resize-none"
                required
              />
              <p className="text-slate-400 text-xs">{body.length} / 200</p>
            </div>

            {/* Sandbox toggle */}
            <div className="flex items-center gap-3 p-3 bg-amber-50 border border-amber-200 rounded-xl">
              <input
                type="checkbox"
                id="sandbox"
                checked={sandbox}
                onChange={e => setSandbox(e.target.checked)}
                className="w-4 h-4 accent-orange-500"
              />
              <label htmlFor="sandbox" className="text-sm text-amber-800 font-medium cursor-pointer">
                Sandbox mode (development builds only)
              </label>
            </div>

            {/* Preview */}
            {(title || body) && (
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200">
                <p className="text-xs text-slate-400 mb-2 font-medium uppercase tracking-wide">Preview</p>
                <div className="flex gap-3 items-start">
                  <div className="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center flex-shrink-0">
                    <Bell className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-semibold text-slate-800 text-sm">{title || 'Notification title'}</p>
                    <p className="text-slate-500 text-xs mt-0.5 leading-relaxed">{body || 'Message body...'}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Submit */}
            <Button
              type="submit"
              disabled={loading}
              className="w-full bg-orange-500 hover:bg-orange-600 text-white font-semibold h-11"
            >
              {loading ? (
                <><Loader2 className="h-4 w-4 animate-spin mr-2" /> Sending...</>
              ) : (
                <><Send className="h-4 w-4 mr-2" /> Send to {tokenCount ?? '…'} devices</>
              )}
            </Button>
          </form>
        </div>

        {/* Right side: tips + history */}
        <div className="lg:col-span-2 space-y-4">
          {/* Tips */}
          <div className="bg-white rounded-2xl border shadow-sm p-5">
            <div className="flex items-center gap-2 mb-3">
              <Users className="h-4 w-4 text-slate-500" />
              <h3 className="font-semibold text-slate-700 text-sm">Audience</h3>
            </div>
            <div className="space-y-2 text-sm text-slate-600">
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-green-400" />
                <span>Broadcast = all registered devices</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-blue-400" />
                <span>Also saved to in-app notification inbox</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-amber-400" />
                <span>Toggle sandbox for dev device testing</span>
              </div>
            </div>
          </div>

          {/* Setup required banner */}
          <div className="bg-blue-50 border border-blue-200 rounded-2xl p-4 text-sm">
            <p className="font-semibold text-blue-800 mb-1">APNs Setup Required</p>
            <p className="text-blue-700 text-xs leading-relaxed">
              To send real pushes, add these secrets in Supabase Dashboard → Settings → Edge Functions:
            </p>
            <ul className="mt-2 space-y-1 text-blue-600 text-xs font-mono">
              {['APNS_KEY_ID', 'APNS_TEAM_ID', 'APNS_PRIVATE_KEY', 'APNS_BUNDLE_ID'].map(k => (
                <li key={k} className="flex items-center gap-1">
                  <span className="text-blue-400">→</span> {k}
                </li>
              ))}
            </ul>
          </div>

          {/* Send history */}
          {history.length > 0 && (
            <div className="bg-white rounded-2xl border shadow-sm p-5">
              <h3 className="font-semibold text-slate-700 text-sm mb-3 flex items-center gap-2">
                <Clock className="h-4 w-4 text-slate-400" />
                Recent Sends
              </h3>
              <div className="space-y-3">
                {history.slice(0, 5).map((n, i) => (
                  <div key={i} className="flex gap-2.5 items-start">
                    <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 flex-shrink-0" />
                    <div className="min-w-0">
                      <p className="text-slate-700 text-sm font-medium truncate">{n.title}</p>
                      <p className="text-slate-400 text-xs">
                        {n.sent} devices · {n.sentAt.toLocaleTimeString()}
                      </p>
                    </div>
                    <Badge className="bg-slate-100 text-slate-600 border-0 text-xs flex-shrink-0">
                      {n.type}
                    </Badge>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
