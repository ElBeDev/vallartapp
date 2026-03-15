import { createClient } from '@/lib/supabase/server'
import ListingForm from '@/components/ListingForm'
import Link from 'next/link'
import { ChevronLeft } from 'lucide-react'
import { notFound } from 'next/navigation'

export default async function EditListingPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const supabase = await createClient()
  const { data: listing } = await supabase.from('listings').select('*').eq('id', id).single()

  if (!listing) notFound()

  return (
    <div className="p-6">
      <div className="max-w-3xl mx-auto">
        <Link href="/listings" className="flex items-center gap-1 text-slate-500 hover:text-slate-700 text-sm mb-6">
          <ChevronLeft className="h-4 w-4" /> Back to Listings
        </Link>
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-slate-800">Edit: {listing.name}</h1>
          <span className="text-xs text-slate-400 font-mono">{listing.id}</span>
        </div>
        <ListingForm initialData={listing} isEdit />
      </div>
    </div>
  )
}
