import EventForm from '@/components/EventForm'
import Link from 'next/link'
import { ChevronLeft } from 'lucide-react'

export default function NewEventPage() {
  return (
    <div className="p-6">
      <div className="max-w-3xl mx-auto">
        <Link href="/events" className="flex items-center gap-1 text-slate-500 hover:text-slate-700 text-sm mb-6">
          <ChevronLeft className="h-4 w-4" /> Back to Events
        </Link>
        <h1 className="text-2xl font-bold text-slate-800 mb-6">Add New Event</h1>
        <EventForm />
      </div>
    </div>
  )
}
