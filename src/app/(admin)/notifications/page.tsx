import { Bell } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export default function NotificationsPage() {
  return (
    <div className="p-6 max-w-3xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-slate-800">Push Notifications</h1>
        <p className="text-slate-500 mt-1">Send push notifications to app users</p>
      </div>

      <Card className="border-dashed border-2 border-slate-200">
        <CardContent className="py-16 text-center">
          <Bell className="h-16 w-16 text-slate-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-slate-600 mb-2">Coming in Phase 3</h3>
          <p className="text-slate-400 max-w-sm mx-auto text-sm">
            Push notifications via Supabase Edge Functions + APNs.<br />
            You&apos;ll be able to send alerts to all users or users who saved a specific listing.
          </p>
        </CardContent>
      </Card>

      <Card className="mt-6">
        <CardHeader>
          <CardTitle className="text-sm text-slate-600">📋 Planned notification types</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 text-sm text-slate-600">
          {[
            '📣 Broadcast to all users',
            '💾 Alert users who saved a specific listing',
            '🎉 Event reminder (X hours before start)',
            '🔥 New featured listing in your area',
            '⭐ New review on your business',
          ].map(item => (
            <div key={item} className="flex items-center gap-2">
              <span className="text-slate-300">○</span> {item}
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  )
}
