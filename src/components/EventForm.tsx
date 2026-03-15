'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { toast } from 'sonner'
import { Loader2, Trash2, X } from 'lucide-react'

const NEIGHBORHOODS = ['centro','zonaRomantica','marina','hotelZone','puntaMita','sayulita','sanPancho','bucerías','nuevaVallarta','yelapa']

interface EventFormProps {
  initialData?: Record<string, unknown>
  isEdit?: boolean
}

const toDatetimeLocal = (iso?: string) => iso ? iso.slice(0, 16) : ''

export default function EventForm({ initialData, isEdit = false }: EventFormProps) {
  const router = useRouter()
  const supabase = createClient()
  const [saving, setSaving] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const [tagInput, setTagInput] = useState('')

  const [form, setForm] = useState({
    title:            (initialData?.title as string)           ?? '',
    description:      (initialData?.description as string)     ?? '',
    neighborhood:     (initialData?.neighborhood as string)    ?? 'centro',
    address:          (initialData?.address as string)         ?? '',
    latitude:         String(initialData?.latitude             ?? '20.6534'),
    longitude:        String(initialData?.longitude            ?? '-105.2253'),
    start_date:       toDatetimeLocal(initialData?.start_date as string),
    end_date:         toDatetimeLocal(initialData?.end_date as string),
    organizer:        (initialData?.organizer as string)       ?? '',
    phone:            (initialData?.phone as string)           ?? '',
    instagram:        (initialData?.instagram as string)       ?? '',
    ticket_price:     String(initialData?.ticket_price         ?? ''),
    ticket_url:       (initialData?.ticket_url as string)      ?? '',
    recurrence_label: (initialData?.recurrence_label as string) ?? '',
    is_public:        Boolean(initialData?.is_public           ?? true),
    is_free:          Boolean(initialData?.is_free             ?? true),
    is_featured:      Boolean(initialData?.is_featured         ?? false),
    is_premium:       Boolean(initialData?.is_premium          ?? false),
    is_recurring:     Boolean(initialData?.is_recurring        ?? false),
    is_lgbt_friendly: Boolean(initialData?.is_lgbt_friendly    ?? false),
    tags:             (initialData?.tags as string[])          ?? [],
  })

  const set = (key: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [key]: e.target.value }))

  const toggle = (key: 'is_public' | 'is_free' | 'is_featured' | 'is_premium' | 'is_recurring' | 'is_lgbt_friendly') =>
    () => setForm(f => ({ ...f, [key]: !f[key] }))

  const addTag = () => {
    const t = tagInput.trim()
    if (t && !form.tags.includes(t)) setForm(f => ({ ...f, tags: [...f.tags, t] }))
    setTagInput('')
  }

  const handleSave = async () => {
    if (!form.title.trim()) { toast.error('Title is required'); return }
    setSaving(true)
    const payload = {
      ...form,
      latitude:     parseFloat(form.latitude)  || 20.6534,
      longitude:    parseFloat(form.longitude) || -105.2253,
      ticket_price: form.ticket_price ? parseFloat(form.ticket_price) : null,
      start_date:   form.start_date ? new Date(form.start_date).toISOString() : null,
      end_date:     form.end_date   ? new Date(form.end_date).toISOString()   : null,
      updated_at:   new Date().toISOString(),
    }
    let error
    if (isEdit && initialData?.id) {
      ;({ error } = await supabase.from('events').update(payload).eq('id', initialData.id))
    } else {
      ;({ error } = await supabase.from('events').insert(payload))
    }
    if (error) { toast.error(error.message) }
    else { toast.success(isEdit ? 'Event updated!' : 'Event created!'); router.push('/events'); router.refresh() }
    setSaving(false)
  }

  const handleDelete = async () => {
    if (!confirm('Delete this event?')) return
    setDeleting(true)
    const { error } = await supabase.from('events').delete().eq('id', initialData?.id)
    if (error) { toast.error(error.message) }
    else { toast.success('Event deleted'); router.push('/events'); router.refresh() }
    setDeleting(false)
  }

  const Toggle = ({ field, label }: { field: 'is_public' | 'is_free' | 'is_featured' | 'is_premium' | 'is_recurring' | 'is_lgbt_friendly'; label: string }) => (
    <button type="button" onClick={toggle(field)}
      className={`flex items-center gap-2 px-4 py-2 rounded-lg border text-sm font-medium transition-all ${
        form[field] ? 'bg-teal-500 text-white border-teal-500' : 'bg-white text-slate-600 border-slate-200 hover:border-teal-300'
      }`}>
      {form[field] ? '✓' : '○'} {label}
    </button>
  )

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      {/* Basic */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Event Details</h2>
        <div>
          <Label>Title *</Label>
          <Input value={form.title} onChange={set('title')} placeholder="Vallarta Pride 2026" className="mt-1.5" />
        </div>
        <div>
          <Label>Description</Label>
          <Textarea value={form.description} onChange={set('description')} rows={4} placeholder="Describe this event..." className="mt-1.5" />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Neighborhood</Label>
            <Select value={form.neighborhood} onValueChange={(v) => setForm(prev => ({ ...prev, neighborhood: v ?? prev.neighborhood }))}>
              <SelectTrigger className="mt-1.5"><SelectValue /></SelectTrigger>
              <SelectContent>{NEIGHBORHOODS.map(n => <SelectItem key={n} value={n}>{n}</SelectItem>)}</SelectContent>
            </Select>
          </div>
          <div>
            <Label>Address</Label>
            <Input value={form.address} onChange={set('address')} placeholder="Zona Romántica & Malecón" className="mt-1.5" />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div><Label>Start Date & Time</Label><Input type="datetime-local" value={form.start_date} onChange={set('start_date')} className="mt-1.5" /></div>
          <div><Label>End Date & Time</Label><Input type="datetime-local" value={form.end_date} onChange={set('end_date')} className="mt-1.5" /></div>
        </div>
      </section>

      {/* Organizer */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Organizer & Contact</h2>
        <div className="grid grid-cols-2 gap-4">
          <div><Label>Organizer</Label><Input value={form.organizer} onChange={set('organizer')} placeholder="Vallarta Pride Organization" className="mt-1.5" /></div>
          <div><Label>Phone</Label><Input value={form.phone} onChange={set('phone')} placeholder="+52 322..." className="mt-1.5" /></div>
          <div><Label>Instagram</Label><Input value={form.instagram} onChange={set('instagram')} placeholder="@handle" className="mt-1.5" /></div>
          <div><Label>Ticket URL</Label><Input value={form.ticket_url} onChange={set('ticket_url')} placeholder="https://tickets.com" className="mt-1.5" /></div>
          <div><Label>Ticket Price (MXN)</Label><Input value={form.ticket_price} onChange={set('ticket_price')} type="number" min="0" placeholder="0 = Free" className="mt-1.5" /></div>
          <div><Label>Recurrence Label</Label><Input value={form.recurrence_label} onChange={set('recurrence_label')} placeholder="Annual / Monthly / Weekly" className="mt-1.5" /></div>
        </div>
      </section>

      {/* Flags */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Flags</h2>
        <div className="flex flex-wrap gap-2">
          <Toggle field="is_public"       label="Public" />
          <Toggle field="is_free"         label="Free Entry" />
          <Toggle field="is_featured"     label="Featured" />
          <Toggle field="is_premium"      label="Premium" />
          <Toggle field="is_recurring"    label="Recurring" />
          <Toggle field="is_lgbt_friendly" label="🏳️‍🌈 LGBT+" />
        </div>
      </section>

      {/* Tags */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Tags</h2>
        <div className="flex gap-2">
          <Input value={tagInput} onChange={e => setTagInput(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); addTag() } }}
            placeholder="Add a tag, press Enter" className="flex-1" />
          <Button type="button" variant="outline" onClick={addTag}>Add</Button>
        </div>
        <div className="flex flex-wrap gap-2">
          {form.tags.map(tag => (
            <Badge key={tag} variant="secondary" className="gap-1 pl-3 pr-1 py-1">
              {tag}
              <button onClick={() => setForm(f => ({ ...f, tags: f.tags.filter(t => t !== tag) }))} className="ml-1 hover:text-red-500">
                <X className="h-3 w-3" />
              </button>
            </Badge>
          ))}
        </div>
      </section>

      {/* Actions */}
      <div className="flex items-center justify-between pb-12">
        {isEdit ? (
          <Button variant="outline" className="text-red-600 border-red-200 hover:bg-red-50 gap-2" onClick={handleDelete} disabled={deleting}>
            {deleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />} Delete Event
          </Button>
        ) : <div />}
        <div className="flex gap-3">
          <Button variant="outline" onClick={() => router.back()}>Cancel</Button>
          <Button onClick={handleSave} disabled={saving} className="bg-teal-500 hover:bg-teal-600 text-white min-w-32">
            {saving ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Saving...</> : isEdit ? 'Save Changes' : 'Create Event'}
          </Button>
        </div>
      </div>
    </div>
  )
}
