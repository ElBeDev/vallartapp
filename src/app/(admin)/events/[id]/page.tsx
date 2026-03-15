import { createClient } from '@/lib/supabase/server'
import EventForm from '@/components/EventForm'
import Link from 'next/link'
import { ChevronLeft } from 'lucide-react'
import { notFound } from 'next/navigation'

export default async function EditEventPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const supabase = await createClient()
  const { data: event } = await supabase.from('events').select('*').eq('id', id).single()

  if (!event) notFound()

  return (
    <div className="p-6">
      <div className="max-w-3xl mx-auto">
        <Link href="/events" className="flex items-center gap-1 text-slate-500 hover:text-slate-700 text-sm mb-6">
          <ChevronLeft className="h-4 w-4" /> Back to Events
        </Link>
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-slate-800">Edit: {event.title}</h1>
          <span className="text-xs text-slate-400 font-mono">{event.id}</span>
        </div>
        <EventForm initialData={event} isEdit />
      </div>
    </div>
  )
}
