'use client'

import { useState, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { toast } from 'sonner'
import { useDropzone } from 'react-dropzone'
import { Loader2, Upload, X, Save, Globe, Phone, Instagram, Clock, MapPin } from 'lucide-react'
import Image from 'next/image'

interface BizListingFormProps {
  listing: Record<string, unknown>
  plan: string
}

const MAX_PHOTOS_FREE     = 3
const MAX_PHOTOS_STANDARD = 20
const MAX_PHOTOS_PREMIUM  = 50

export default function BizListingForm({ listing, plan }: BizListingFormProps) {
  const supabase = createClient()

  const isPremium  = plan.startsWith('biz_premium')
  const isStandard = plan.startsWith('biz_standard')
  const maxPhotos  = isPremium ? MAX_PHOTOS_PREMIUM : isStandard ? MAX_PHOTOS_STANDARD : MAX_PHOTOS_FREE

  const [saving,    setSaving]    = useState(false)
  const [uploading, setUploading] = useState(false)

  const [form, setForm] = useState({
    description: (listing.description as string) ?? '',
    phone:       (listing.phone       as string) ?? '',
    website:     (listing.website     as string) ?? '',
    instagram:   (listing.instagram   as string) ?? '',
    open_hours:  (listing.open_hours  as string) ?? '',
    address:     (listing.address     as string) ?? '',
    photos:      (listing.photos      as string[]) ?? [],
  })

  const set = (key: keyof typeof form) =>
    (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setForm(f => ({ ...f, [key]: e.target.value }))

  // ── Photo upload ──────────────────────────────────────────
  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const remaining = maxPhotos - form.photos.length
    if (remaining <= 0) {
      toast.error(`You've reached your ${maxPhotos}-photo limit for the ${plan} plan`)
      return
    }
    const toUpload = acceptedFiles.slice(0, remaining)
    setUploading(true)
    const uploaded: string[] = []

    for (const file of toUpload) {
      const ext  = file.name.split('.').pop()
      const path = `listings/${listing.id}_${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`
      const { error } = await supabase.storage.from('listings').upload(path, file, { upsert: false })
      if (!error) {
        const { data } = supabase.storage.from('listings').getPublicUrl(path)
        uploaded.push(data.publicUrl)
      } else {
        toast.error(`Failed to upload ${file.name}: ${error.message}`)
      }
    }

    if (uploaded.length > 0) {
      setForm(f => ({ ...f, photos: [...f.photos, ...uploaded] }))
      toast.success(`${uploaded.length} photo${uploaded.length > 1 ? 's' : ''} uploaded`)
    }
    setUploading(false)
  }, [form.photos, maxPhotos, listing.id, plan, supabase.storage])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': [] },
    disabled: uploading || form.photos.length >= maxPhotos,
  })

  const removePhoto = (url: string) =>
    setForm(f => ({ ...f, photos: f.photos.filter(p => p !== url) }))

  // ── Save ──────────────────────────────────────────────────
  const handleSave = async () => {
    setSaving(true)
    const { error } = await supabase
      .from('listings')
      .update({
        description: form.description,
        phone:       form.phone       || null,
        website:     form.website     || null,
        instagram:   form.instagram   || null,
        open_hours:  form.open_hours  || null,
        address:     form.address     || null,
        photos:      form.photos,
      })
      .eq('id', listing.id as string)

    if (error) {
      toast.error('Failed to save: ' + error.message)
    } else {
      toast.success('Listing updated! Changes are live.')
    }
    setSaving(false)
  }

  return (
    <div className="space-y-6">

      {/* Basic Info — read-only for biz owners */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
        <h3 className="text-white font-semibold mb-1">{listing.name as string}</h3>
        <p className="text-slate-500 text-xs capitalize">
          {listing.category as string} · {(listing.neighborhood as string)?.replace(/([A-Z])/g, ' $1')}
        </p>
        <p className="text-slate-500 text-xs mt-1">
          Contact us to change your business name or category.
        </p>
      </div>

      {/* Description */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-3">
        <h3 className="text-white font-semibold">Description</h3>
        <Textarea
          value={form.description}
          onChange={set('description')}
          rows={5}
          placeholder="Describe your business — what makes it special, what visitors can expect..."
          className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 resize-none focus:border-orange-500"
        />
        <p className="text-slate-500 text-xs">{form.description.length} / 1000 characters</p>
      </div>

      {/* Contact & Links */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-4">
        <h3 className="text-white font-semibold">Contact & Links</h3>
        <div className="grid sm:grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <Label className="text-slate-300 text-sm flex items-center gap-1.5">
              <Phone className="h-3.5 w-3.5" /> Phone
            </Label>
            <Input value={form.phone} onChange={set('phone')} placeholder="+52 322 000 0000"
              className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 focus:border-orange-500" />
          </div>
          <div className="space-y-1.5">
            <Label className="text-slate-300 text-sm flex items-center gap-1.5">
              <Globe className="h-3.5 w-3.5" /> Website
            </Label>
            <Input value={form.website} onChange={set('website')} placeholder="https://yourbusiness.com"
              className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 focus:border-orange-500" />
          </div>
          <div className="space-y-1.5">
            <Label className="text-slate-300 text-sm flex items-center gap-1.5">
              <Instagram className="h-3.5 w-3.5" /> Instagram
            </Label>
            <Input value={form.instagram} onChange={set('instagram')} placeholder="@yourbusiness"
              className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 focus:border-orange-500" />
          </div>
          <div className="space-y-1.5">
            <Label className="text-slate-300 text-sm flex items-center gap-1.5">
              <Clock className="h-3.5 w-3.5" /> Hours
            </Label>
            <Input value={form.open_hours} onChange={set('open_hours')} placeholder="Mon–Sat 9am–10pm"
              className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 focus:border-orange-500" />
          </div>
          <div className="space-y-1.5 sm:col-span-2">
            <Label className="text-slate-300 text-sm flex items-center gap-1.5">
              <MapPin className="h-3.5 w-3.5" /> Address
            </Label>
            <Input value={form.address} onChange={set('address')} placeholder="Calle Basilio Badillo 123, Zona Romántica"
              className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 focus:border-orange-500" />
          </div>
        </div>
      </div>

      {/* Photos */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-white font-semibold">Photos</h3>
          <Badge className="bg-slate-700 text-slate-300 border-slate-600 border text-xs">
            {form.photos.length} / {maxPhotos}
          </Badge>
        </div>

        {/* Dropzone */}
        {form.photos.length < maxPhotos && (
          <div
            {...getRootProps()}
            className={`border-2 border-dashed rounded-xl p-6 text-center cursor-pointer transition-colors
              ${isDragActive
                ? 'border-orange-500 bg-orange-500/5'
                : 'border-white/20 hover:border-orange-500/50 hover:bg-white/5'
              } ${uploading ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            <input {...getInputProps()} />
            {uploading ? (
              <div className="flex flex-col items-center gap-2">
                <Loader2 className="h-8 w-8 text-orange-400 animate-spin" />
                <p className="text-slate-400 text-sm">Uploading...</p>
              </div>
            ) : (
              <div className="flex flex-col items-center gap-2">
                <Upload className="h-8 w-8 text-slate-500" />
                <p className="text-white text-sm font-medium">
                  {isDragActive ? 'Drop photos here' : 'Drag & drop photos or click to browse'}
                </p>
                <p className="text-slate-500 text-xs">JPG, PNG, WebP up to 10MB each</p>
              </div>
            )}
          </div>
        )}

        {/* Photo grid */}
        {form.photos.length > 0 && (
          <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
            {form.photos.map((url, i) => (
              <div key={i} className="relative group aspect-square rounded-xl overflow-hidden bg-slate-800">
                <Image src={url} alt="" fill className="object-cover" sizes="150px" />
                <button
                  onClick={() => removePhoto(url)}
                  className="absolute top-1.5 right-1.5 w-6 h-6 bg-black/70 rounded-full
                    flex items-center justify-center opacity-0 group-hover:opacity-100
                    transition-opacity hover:bg-red-500"
                >
                  <X className="h-3.5 w-3.5 text-white" />
                </button>
                {i === 0 && (
                  <div className="absolute bottom-1.5 left-1.5 bg-orange-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded">
                    Cover
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Plan limit notice */}
        {!isPremium && !isStandard && (
          <p className="text-slate-500 text-xs">
            Free plan: up to {MAX_PHOTOS_FREE} photos.{' '}
            <a href="mailto:hello@vallartapp.com?subject=Upgrade plan" className="text-orange-400 hover:text-orange-300">
              Upgrade to Standard
            </a>{' '}
            for up to {MAX_PHOTOS_STANDARD} photos.
          </p>
        )}
      </div>

      {/* Save button */}
      <Button
        onClick={handleSave}
        disabled={saving}
        className="w-full bg-orange-500 hover:bg-orange-600 text-white font-semibold h-12 text-base"
      >
        {saving ? (
          <><Loader2 className="h-4 w-4 animate-spin mr-2" /> Saving...</>
        ) : (
          <><Save className="h-4 w-4 mr-2" /> Save Changes</>
        )}
      </Button>
    </div>
  )
}
