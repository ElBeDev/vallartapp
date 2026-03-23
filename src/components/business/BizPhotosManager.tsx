'use client'

import { useState, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { toast } from 'sonner'
import { useDropzone } from 'react-dropzone'
import { Loader2, Upload, X, GripVertical, Save } from 'lucide-react'
import Image from 'next/image'

const MAX: Record<string, number> = {
  free: 3,
  biz_standard: 20, biz_standard_yearly: 20,
  biz_premium: 50,  biz_premium_yearly: 50,
}

interface BizPhotosManagerProps {
  listing: Record<string, unknown>
  plan: string
}

export default function BizPhotosManager({ listing, plan }: BizPhotosManagerProps) {
  const supabase  = createClient()
  const maxPhotos = MAX[plan] ?? 3

  const [photos,    setPhotos]    = useState<string[]>((listing.photos as string[]) ?? [])
  const [uploading, setUploading] = useState(false)
  const [saving,    setSaving]    = useState(false)
  const [dragIdx,   setDragIdx]   = useState<number | null>(null)

  // ── Upload ────────────────────────────────────────────────
  const onDrop = useCallback(async (files: File[]) => {
    const remaining = maxPhotos - photos.length
    if (remaining <= 0) { toast.error(`Limit of ${maxPhotos} photos reached`); return }
    const toUpload = files.slice(0, remaining)
    setUploading(true)
    const uploaded: string[] = []
    for (const file of toUpload) {
      const ext  = file.name.split('.').pop()
      const path = `listings/${listing.id}_${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`
      const { error } = await supabase.storage.from('listings').upload(path, file)
      if (!error) {
        uploaded.push(supabase.storage.from('listings').getPublicUrl(path).data.publicUrl)
      } else {
        toast.error(`Upload failed: ${file.name}`)
      }
    }
    if (uploaded.length) {
      setPhotos(p => [...p, ...uploaded])
      toast.success(`${uploaded.length} photo(s) added`)
    }
    setUploading(false)
  }, [photos.length, maxPhotos, listing.id, supabase.storage])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: { 'image/*': [] },
    disabled: uploading || photos.length >= maxPhotos,
  })

  // ── Reorder via drag ──────────────────────────────────────
  const onDragStart = (i: number) => setDragIdx(i)
  const onDragOver  = (e: React.DragEvent, i: number) => {
    e.preventDefault()
    if (dragIdx === null || dragIdx === i) return
    const next = [...photos]
    const [moved] = next.splice(dragIdx, 1)
    next.splice(i, 0, moved)
    setPhotos(next)
    setDragIdx(i)
  }
  const onDragEnd = () => setDragIdx(null)

  // ── Save order + deletions ────────────────────────────────
  const save = async () => {
    setSaving(true)
    const { error } = await supabase
      .from('listings')
      .update({ photos })
      .eq('id', listing.id as string)
    if (error) toast.error('Save failed: ' + error.message)
    else toast.success('Photos saved!')
    setSaving(false)
  }

  const removePhoto = (url: string) =>
    setPhotos(p => p.filter(x => x !== url))

  return (
    <div className="space-y-5">
      {/* Quota */}
      <div className="flex items-center justify-between">
        <Badge className="bg-slate-700 border-slate-600 border text-slate-300 text-xs">
          {photos.length} / {maxPhotos} photos
        </Badge>
        <Button onClick={save} disabled={saving} size="sm"
          className="bg-orange-500 hover:bg-orange-600 text-white">
          {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <><Save className="h-3.5 w-3.5 mr-1.5" />Save order</>}
        </Button>
      </div>

      {/* Dropzone */}
      {photos.length < maxPhotos && (
        <div {...getRootProps()}
          className={`border-2 border-dashed rounded-2xl p-8 text-center cursor-pointer transition
            ${isDragActive ? 'border-orange-500 bg-orange-500/5' : 'border-white/15 hover:border-orange-500/40'}
            ${uploading ? 'opacity-50 pointer-events-none' : ''}`}>
          <input {...getInputProps()} />
          {uploading ? (
            <div className="flex flex-col items-center gap-2">
              <Loader2 className="h-8 w-8 text-orange-400 animate-spin" />
              <p className="text-slate-400 text-sm">Uploading...</p>
            </div>
          ) : (
            <div className="flex flex-col items-center gap-2">
              <Upload className="h-8 w-8 text-slate-500" />
              <p className="text-white font-medium text-sm">
                {isDragActive ? 'Drop here' : 'Drag photos or click to upload'}
              </p>
              <p className="text-slate-500 text-xs">JPG, PNG, WebP · Max 10MB each</p>
            </div>
          )}
        </div>
      )}

      {/* Grid — draggable */}
      {photos.length > 0 && (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
          {photos.map((url, i) => (
            <div
              key={url}
              draggable
              onDragStart={() => onDragStart(i)}
              onDragOver={e => onDragOver(e, i)}
              onDragEnd={onDragEnd}
              className={`relative group aspect-square rounded-xl overflow-hidden bg-slate-800 cursor-grab
                ${dragIdx === i ? 'ring-2 ring-orange-500 opacity-70' : ''}`}
            >
              <Image src={url} alt="" fill className="object-cover" sizes="200px" />
              {/* Drag handle */}
              <div className="absolute top-1.5 left-1.5 opacity-0 group-hover:opacity-100 transition">
                <GripVertical className="h-4 w-4 text-white drop-shadow" />
              </div>
              {/* Remove */}
              <button
                onClick={() => removePhoto(url)}
                className="absolute top-1.5 right-1.5 w-6 h-6 bg-black/70 rounded-full
                  flex items-center justify-center opacity-0 group-hover:opacity-100 transition hover:bg-red-500"
              >
                <X className="h-3.5 w-3.5 text-white" />
              </button>
              {i === 0 && (
                <div className="absolute bottom-1.5 left-1.5 bg-orange-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded">
                  Cover
                </div>
              )}
              <div className="absolute bottom-1.5 right-1.5 bg-black/60 text-white text-[10px] px-1 py-0.5 rounded">
                {i + 1}
              </div>
            </div>
          ))}
        </div>
      )}

      <p className="text-slate-500 text-xs">
        Drag to reorder · First photo is your cover · Click save when done
      </p>
    </div>
  )
}
