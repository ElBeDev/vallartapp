import ListingForm from '@/components/ListingForm'
import Link from 'next/link'
import { ChevronLeft } from 'lucide-react'

export default function NewListingPage() {
  return (
    <div className="p-6">
      <div className="max-w-3xl mx-auto">
        <Link href="/listings" className="flex items-center gap-1 text-slate-500 hover:text-slate-700 text-sm mb-6">
          <ChevronLeft className="h-4 w-4" /> Back to Listings
        </Link>
        <h1 className="text-2xl font-bold text-slate-800 mb-6">Add New Listing</h1>
        <ListingForm />
      </div>
    </div>
  )
}
