import { createClient } from '@/lib/supabase/server'
import Link from 'next/link'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Plus, Pencil, Star } from 'lucide-react'

const CATEGORY_EMOJI: Record<string, string> = {
  restaurants: '🍽️', bars: '🍹', hotels: '🏨', activities: '🏄',
  yachts: '⛵', rentals: '🚗', events: '🎉', beaches: '🏖️',
  shopping: '🛍️', spas: '💆',
}

export default async function ListingsPage() {
  const supabase = await createClient()
  const { data: listings, error } = await supabase
    .from('listings')
    .select('*')
    .order('is_featured', { ascending: false })
    .order('rating', { ascending: false })

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold text-slate-800">Listings</h1>
          <p className="text-slate-500 mt-1">{listings?.length ?? 0} total listings</p>
        </div>
        <Link href="/listings/new">
          <Button className="bg-orange-500 hover:bg-orange-600 text-white gap-2">
            <Plus className="h-4 w-4" /> Add Listing
          </Button>
        </Link>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 text-red-700 text-sm">
          ⚠️ Database error: {error.message}. Make sure you&apos;ve run the SQL schema in Supabase.
        </div>
      )}

      {!listings || listings.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-xl border">
          <div className="text-6xl mb-4">🗺️</div>
          <h3 className="text-xl font-semibold text-slate-700 mb-2">No listings yet</h3>
          <p className="text-slate-400 mb-6">Add your first Puerto Vallarta listing to get started</p>
          <Link href="/listings/new">
            <Button className="bg-orange-500 hover:bg-orange-600 text-white gap-2">
              <Plus className="h-4 w-4" /> Add First Listing
            </Button>
          </Link>
        </div>
      ) : (
        <div className="bg-white rounded-xl border overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-50 border-b">
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Name</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Category</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Neighborhood</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Rating</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Status</th>
                  <th className="text-left px-4 py-3 font-semibold text-slate-600">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {listings.map((listing) => (
                  <tr key={listing.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-4 py-3">
                      <p className="font-medium text-slate-800">{listing.name}</p>
                      <p className="text-xs text-slate-400 truncate max-w-xs">{listing.address}</p>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-600">
                        {CATEGORY_EMOJI[listing.category] ?? '📍'} {listing.category}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-600 capitalize">
                      {listing.neighborhood?.replace(/_/g, ' ')}
                    </td>
                    <td className="px-4 py-3">
                      <span className="flex items-center gap-1 text-slate-700">
                        <Star className="h-3.5 w-3.5 text-yellow-400 fill-yellow-400" />
                        {listing.rating?.toFixed(1) ?? '—'}
                        <span className="text-slate-400 text-xs">({listing.review_count ?? 0})</span>
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex flex-wrap gap-1">
                        {listing.is_featured && <Badge className="bg-orange-100 text-orange-700 border-0 text-xs">Featured</Badge>}
                        {listing.is_premium  && <Badge className="bg-yellow-100 text-yellow-700 border-0 text-xs">Premium</Badge>}
                        {listing.is_open     ? <Badge className="bg-green-100 text-green-700 border-0 text-xs">Open</Badge>
                                             : <Badge className="bg-slate-100 text-slate-500 border-0 text-xs">Closed</Badge>}
                        {listing.is_lgbt_friendly && <Badge className="bg-purple-100 text-purple-700 border-0 text-xs">🏳️‍🌈</Badge>}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <Link href={`/listings/${listing.id}`}>
                        <Button variant="ghost" size="sm" className="gap-1.5 text-slate-600 hover:text-orange-600">
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
