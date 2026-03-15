import { createClient } from '@/lib/supabase/server'
import Link from 'next/link'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Plus, Pencil, Calendar } from 'lucide-react'

export default async function EventsPage() {
  const supabase = await createClient()
  const { data: events, error } = await supabase
    .from('events')
    .select('*')
    .order('start_date', { ascending: true })

  const fmt = (d: string) => d ? new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '—'

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-slate-800">Events</h1>
          <p className="text-slate-500 mt-1">{events?.length ?? 0} total events</p>
        </div>
        <Link href="/events/new">
          <Button className="bg-teal-500 hover:bg-teal-600 text-white gap-2">
            <Plus className="h-4 w-4" /> Add Event
          </Button>
        </Link>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 text-red-700 text-sm">
          ⚠️ {error.message}
        </div>
      )}

      {!events || events.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-xl border">
          <Calendar className="h-16 w-16 text-slate-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-slate-700 mb-2">No events yet</h3>
          <p className="text-slate-400 mb-6">Add your first Puerto Vallarta event</p>
          <Link href="/events/new">
            <Button className="bg-teal-500 hover:bg-teal-600 text-white gap-2">
              <Plus className="h-4 w-4" /> Add First Event
            </Button>
          </Link>
        </div>
      ) : (
        <div className="bg-white rounded-xl border overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-50 border-b">
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Title</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Dates</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Neighborhood</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Flags</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {events.map((event) => (
                  <tr key={event.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-4 py-3">
                      <p className="font-medium text-slate-800">{event.title}</p>
                      <p className="text-xs text-slate-400">{event.organizer}</p>
                    </td>
                    <td className="px-4 py-3 text-slate-600 text-xs">
                      <p>{fmt(event.start_date)}</p>
                      <p className="text-slate-400">→ {fmt(event.end_date)}</p>
                    </td>
                    <td className="px-4 py-3 text-slate-600 capitalize">
                      {event.neighborhood?.replace(/_/g, ' ')}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex flex-wrap gap-1">
                        {event.is_featured  && <Badge className="bg-orange-100 text-orange-700 border-0 text-xs">Featured</Badge>}
                        {event.is_free      ? <Badge className="bg-green-100 text-green-700 border-0 text-xs">Free</Badge>
                                            : <Badge className="bg-blue-100 text-blue-700 border-0 text-xs">${event.ticket_price}</Badge>}
                        {event.is_public    ? <Badge className="bg-slate-100 text-slate-600 border-0 text-xs">Public</Badge>
                                            : <Badge className="bg-yellow-100 text-yellow-700 border-0 text-xs">Private</Badge>}
                        {event.is_recurring && <Badge className="bg-purple-100 text-purple-700 border-0 text-xs">↻ {event.recurrence_label}</Badge>}
                        {event.is_lgbt_friendly && <Badge className="bg-pink-100 text-pink-700 border-0 text-xs">🏳️‍🌈</Badge>}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <Link href={`/events/${event.id}`}>
                        <Button variant="ghost" size="sm" className="gap-1.5 text-slate-600 hover:text-teal-600">
                          <Pencil className="h-3.5 w-3.5" /> Edit
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
