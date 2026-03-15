'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { toast } from 'sonner'
import { Loader2, Trash2, Upload, X, MapPin } from 'lucide-react'
import { useDropzone } from 'react-dropzone'
import Image from 'next/image'

const CATEGORIES = ['restaurants', 'bars', 'hotels', 'activities', 'yachts', 'rentals', 'events', 'beaches', 'shopping', 'spas']
const NEIGHBORHOODS = ['centro', 'zonaRomantica', 'marina', 'hotelZone', 'puntaMita', 'sayulita', 'sanPancho', 'bucerías', 'nuevaVallarta', 'yelapa']
const PRICE_RANGES = [
  { value: '0', label: 'Free' },
  { value: '1', label: '$ Budget' },
  { value: '2', label: '$$ Moderate' },
  { value: '3', label: '$$$ Upscale' },
  { value: '4', label: '$$$$ Luxury' },
]

interface ListingFormProps {
  initialData?: Record<string, unknown>
  isEdit?: boolean
}

export default function ListingForm({ initialData, isEdit = false }: ListingFormProps) {
  const router = useRouter()
  const supabase = createClient()

  const [saving, setSaving] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [tagInput, setTagInput] = useState('')

  const [form, setForm] = useState({
    name:             (initialData?.name as string)            ?? '',
    category:         (initialData?.category as string)        ?? 'restaurants',
    neighborhood:     (initialData?.neighborhood as string)    ?? 'centro',
    address:          (initialData?.address as string)         ?? '',
    latitude:         String(initialData?.latitude             ?? '20.6534'),
    longitude:        String(initialData?.longitude            ?? '-105.2253'),
    description:      (initialData?.description as string)     ?? '',
    phone:            (initialData?.phone as string)           ?? '',
    website:          (initialData?.website as string)         ?? '',
    instagram:        (initialData?.instagram as string)       ?? '',
    open_hours:       (initialData?.open_hours as string)      ?? '',
    price_range:      String(initialData?.price_range          ?? '2'),
    rating:           String(initialData?.rating               ?? '0'),
    review_count:     String(initialData?.review_count         ?? '0'),
    is_open:          Boolean(initialData?.is_open             ?? true),
    is_featured:      Boolean(initialData?.is_featured         ?? false),
    is_premium:       Boolean(initialData?.is_premium          ?? false),
    is_lgbt_friendly: Boolean(initialData?.is_lgbt_friendly    ?? false),
    tags:             (initialData?.tags as string[])          ?? [],
    photos:           (initialData?.photos as string[])        ?? [],
  })

  const set = (key: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(f => ({ ...f, [key]: e.target.value }))
  const toggle = (key: keyof typeof form) => () =>
    setForm(f => ({ ...f, [key]: !f[key as 'is_open'] }))

  // Image upload via Supabase Storage
  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    setUploading(true)
    const uploaded: string[] = []
    for (const file of acceptedFiles) {
      const ext = file.name.split('.').pop()
      const path = `listings/${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`
      const { error } = await supabase.storage.from('photos').upload(path, file)
      if (!error) {
        const { data } = supabase.storage.from('photos').getPublicUrl(path)
        uploaded.push(data.publicUrl)
      } else {
        toast.error(`Upload failed: ${error.message}`)
      }
    }
    setForm(f => ({ ...f, photos: [...f.photos, ...uploaded] }))
    setUploading(false)
    if (uploaded.length) toast.success(`${uploaded.length} photo(s) uploaded`)
  }, [supabase])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': ['.jpg', '.jpeg', '.png', '.webp'] },
    maxSize: 5 * 1024 * 1024,
  })

  const removePhoto = (url: string) =>
    setForm(f => ({ ...f, photos: f.photos.filter(p => p !== url) }))

  const addTag = () => {
    const t = tagInput.trim()
    if (t && !form.tags.includes(t)) {
      setForm(f => ({ ...f, tags: [...f.tags, t] }))
    }
    setTagInput('')
  }

  const removeTag = (tag: string) =>
    setForm(f => ({ ...f, tags: f.tags.filter(t => t !== tag) }))

  const handleSave = async () => {
    if (!form.name.trim()) { toast.error('Name is required'); return }
    setSaving(true)
    const payload = {
      ...form,
      latitude:     parseFloat(form.latitude)    || 20.6534,
      longitude:    parseFloat(form.longitude)   || -105.2253,
      price_range:  parseInt(form.price_range)   || 2,
      rating:       parseFloat(form.rating)      || 0,
      review_count: parseInt(form.review_count)  || 0,
      updated_at:   new Date().toISOString(),
    }

    let error
    if (isEdit && initialData?.id) {
      ;({ error } = await supabase.from('listings').update(payload).eq('id', initialData.id))
    } else {
      ;({ error } = await supabase.from('listings').insert(payload))
    }

    if (error) {
      toast.error(error.message)
    } else {
      toast.success(isEdit ? 'Listing updated!' : 'Listing created!')
      router.push('/listings')
      router.refresh()
    }
    setSaving(false)
  }

  const handleDelete = async () => {
    if (!confirm('Delete this listing? This cannot be undone.')) return
    setDeleting(true)
    const { error } = await supabase.from('listings').delete().eq('id', initialData?.id)
    if (error) {
      toast.error(error.message)
    } else {
      toast.success('Listing deleted')
      router.push('/listings')
      router.refresh()
    }
    setDeleting(false)
  }

  const Toggle = ({ field, label }: { field: 'is_open' | 'is_featured' | 'is_premium' | 'is_lgbt_friendly'; label: string }) => (
    <button
      type="button"
      onClick={toggle(field)}
      className={`flex items-center gap-2 px-4 py-2 rounded-lg border text-sm font-medium transition-all ${
        form[field]
          ? 'bg-orange-500 text-white border-orange-500'
          : 'bg-white text-slate-600 border-slate-200 hover:border-orange-300'
      }`}
    >
      {form[field] ? '✓' : '○'} {label}
    </button>
  )

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      {/* Basic Info */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Basic Information</h2>
        <div className="grid gap-4">
          <div>
            <Label htmlFor="name">Name *</Label>
            <Input id="name" value={form.name} onChange={set('name')} placeholder="Café des Artistes" className="mt-1.5" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label>Category</Label>
              <Select value={form.category} onValueChange={(v) => setForm(f => ({ ...f, category: v ?? f.category }))}>
                <SelectTrigger className="mt-1.5"><SelectValue /></SelectTrigger>
                <SelectContent>
                  {CATEGORIES.map(c => <SelectItem key={c} value={c}>{c}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label>Neighborhood</Label>
              <Select value={form.neighborhood} onValueChange={(v) => setForm(f => ({ ...f, neighborhood: v ?? f.neighborhood }))}>
                <SelectTrigger className="mt-1.5"><SelectValue /></SelectTrigger>
                <SelectContent>
                  {NEIGHBORHOODS.map(n => <SelectItem key={n} value={n}>{n}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div>
            <Label>Address</Label>
            <Input value={form.address} onChange={set('address')} placeholder="Guadalupe Sánchez 740, Centro" className="mt-1.5" />
          </div>
          <div>
            <Label>Description</Label>
            <Textarea value={form.description} onChange={set('description')} rows={4} placeholder="Write a compelling description..." className="mt-1.5" />
          </div>
        </div>
      </section>

      {/* Location */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg flex items-center gap-2">
          <MapPin className="h-5 w-5 text-orange-500" /> Location Coordinates
        </h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Latitude</Label>
            <Input value={form.latitude} onChange={set('latitude')} placeholder="20.6060" className="mt-1.5" />
          </div>
          <div>
            <Label>Longitude</Label>
            <Input value={form.longitude} onChange={set('longitude')} placeholder="-105.2370" className="mt-1.5" />
          </div>
        </div>
        <p className="text-xs text-slate-400">💡 Tip: Right-click any location in Google Maps → &quot;What&apos;s here&quot; to get coordinates</p>
      </section>

      {/* Contact & Hours */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Contact & Hours</h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Phone</Label>
            <Input value={form.phone} onChange={set('phone')} placeholder="+52 322 222 3228" className="mt-1.5" />
          </div>
          <div>
            <Label>Open Hours</Label>
            <Input value={form.open_hours} onChange={set('open_hours')} placeholder="6:00 PM – 11:30 PM" className="mt-1.5" />
          </div>
          <div>
            <Label>Website</Label>
            <Input value={form.website} onChange={set('website')} placeholder="https://example.com" className="mt-1.5" />
          </div>
          <div>
            <Label>Instagram</Label>
            <Input value={form.instagram} onChange={set('instagram')} placeholder="@handle" className="mt-1.5" />
          </div>
        </div>
      </section>

      {/* Pricing & Rating */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Pricing & Rating</h2>
        <div className="grid grid-cols-3 gap-4">
          <div>
            <Label>Price Range</Label>
            <Select value={form.price_range} onValueChange={(v) => setForm(f => ({ ...f, price_range: v ?? f.price_range }))}>
              <SelectTrigger className="mt-1.5"><SelectValue /></SelectTrigger>
              <SelectContent>
                {PRICE_RANGES.map(p => <SelectItem key={p.value} value={p.value}>{p.label}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div>
            <Label>Rating (0–5)</Label>
            <Input value={form.rating} onChange={set('rating')} type="number" min="0" max="5" step="0.1" className="mt-1.5" />
          </div>
          <div>
            <Label>Review Count</Label>
            <Input value={form.review_count} onChange={set('review_count')} type="number" min="0" className="mt-1.5" />
          </div>
        </div>
      </section>

      {/* Status Flags */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Status Flags</h2>
        <div className="flex flex-wrap gap-2">
          <Toggle field="is_open"          label="Open Now" />
          <Toggle field="is_featured"      label="Featured" />
          <Toggle field="is_premium"       label="Premium" />
          <Toggle field="is_lgbt_friendly" label="🏳️‍🌈 LGBT+ Friendly" />
        </div>
      </section>

      {/* Tags */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Tags</h2>
        <div className="flex gap-2">
          <Input
            value={tagInput}
            onChange={e => setTagInput(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); addTag() } }}
            placeholder="Add a tag, press Enter"
            className="flex-1"
          />
          <Button type="button" variant="outline" onClick={addTag}>Add</Button>
        </div>
        <div className="flex flex-wrap gap-2">
          {form.tags.map(tag => (
            <Badge key={tag} variant="secondary" className="gap-1 pl-3 pr-1 py-1">
              {tag}
              <button onClick={() => removeTag(tag)} className="ml-1 hover:text-red-500">
                <X className="h-3 w-3" />
              </button>
            </Badge>
          ))}
        </div>
      </section>

      {/* Photos */}
      <section className="bg-white rounded-xl border p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-slate-800 text-lg">Photos</h2>
        <div
          {...getRootProps()}
          className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors ${
            isDragActive ? 'border-orange-400 bg-orange-50' : 'border-slate-200 hover:border-orange-300 hover:bg-slate-50'
          }`}
        >
          <input {...getInputProps()} />
          {uploading ? (
            <div className="flex flex-col items-center gap-2">
              <Loader2 className="h-8 w-8 animate-spin text-orange-500" />
              <p className="text-slate-500">Uploading...</p>
            </div>
          ) : (
            <div className="flex flex-col items-center gap-2">
              <Upload className="h-8 w-8 text-slate-400" />
              <p className="text-slate-500 font-medium">
                {isDragActive ? 'Drop photos here...' : 'Drag & drop photos, or click to select'}
              </p>
              <p className="text-xs text-slate-400">JPG, PNG, WebP up to 5MB each</p>
            </div>
          )}
        </div>
        {form.photos.length > 0 && (
          <div className="grid grid-cols-3 gap-3">
            {form.photos.map((url, i) => (
              <div key={url} className="relative group rounded-lg overflow-hidden aspect-video bg-slate-100">
                <Image src={url} alt={`Photo ${i + 1}`} fill className="object-cover" />
                {i === 0 && (
                  <span className="absolute top-2 left-2 bg-orange-500 text-white text-xs px-2 py-0.5 rounded-full">Hero</span>
                )}
                <button
                  onClick={() => removePhoto(url)}
                  className="absolute top-2 right-2 bg-black/60 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <X className="h-3 w-3" />
                </button>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Action buttons */}
      <div className="flex items-center justify-between pb-12">
        {isEdit ? (
          <Button
            variant="outline"
            className="text-red-600 border-red-200 hover:bg-red-50 gap-2"
            onClick={handleDelete}
            disabled={deleting}
          >
            {deleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />}
            Delete Listing
          </Button>
        ) : <div />}

        <div className="flex gap-3">
          <Button variant="outline" onClick={() => router.back()}>Cancel</Button>
          <Button
            onClick={handleSave}
            disabled={saving}
            className="bg-orange-500 hover:bg-orange-600 text-white min-w-32"
          >
            {saving ? <><Loader2 className="h-4 w-4 animate-spin mr-2" /> Saving...</> : isEdit ? 'Save Changes' : 'Create Listing'}
          </Button>
        </div>
      </div>
    </div>
  )
}
