import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Star, MessageSquare, Eye, ImageIcon,
  MapPin, Phone, Globe, Instagram,
  Clock, ChevronRight, Crown, TrendingUp
} from 'lucide-react'

export default async function BizDashboardPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/business/login')

  // Get business owner record
  const { data: biz } = await supabase
    .from('business_owners')
    .select('*, listings(*)')
    .eq('user_id', user.id)
    .single()

  if (!biz) redirect('/business/login?reason=not_registered')

  const listing = biz.listings as unknown as Record<string, unknown> | null
  const plan    = (biz.plan as string) ?? 'free'
  const isPremium  = plan.startsWith('biz_premium')
  const isStandard = plan.startsWith('biz_standard')
  const isPaid     = isPremium || isStandard

  // Reviews for this listing
  const reviewsRes = listing
    ? await supabase
        .from('reviews')
        .select('id, rating, comment, created_at, user_id')
        .eq('listing_id', listing.id as string)
        .order('created_at', { ascending: false })
        .limit(5)
    : { data: [] }

  const reviews = reviewsRes.data ?? []

  const planLabel = isPremium ? 'Premium' : isStandard ? 'Standard' : 'Free'
  const planColor = isPremium ? 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20'
                 : isStandard ? 'bg-blue-500/10 text-blue-400 border-blue-500/20'
                 : 'bg-slate-700 text-slate-400 border-slate-600'

  return (
    <div className="p-6 max-w-5xl mx-auto">

      {/* Header */}
      <div className="mb-8 flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">
            Welcome back{biz.business_name ? `, ${biz.business_name}` : ''}
          </h1>
          <p className="text-slate-400 mt-1 text-sm">
            Here&apos;s how your listing is performing today
          </p>
        </div>
        <Badge className={`border ${planColor} text-xs font-semibold flex items-center gap-1`}>
          <Crown className="h-3 w-3" /> {planLabel}
        </Badge>
      </div>

      {/* Listing not connected yet */}
      {!listing && (
        <div className="bg-amber-500/10 border border-amber-500/20 rounded-2xl p-6 mb-6 text-center">
          <MapPin className="h-10 w-10 text-amber-400 mx-auto mb-3" />
          <h3 className="text-white font-semibold mb-1">No listing connected yet</h3>
          <p className="text-slate-400 text-sm mb-4">
            Your business hasn&apos;t been linked to a listing on VallartApp yet. Contact us to get set up.
          </p>
          <a
            href="mailto:hello@vallartapp.com?subject=Link my business listing"
            className="inline-flex items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white text-sm font-medium px-4 py-2 rounded-lg transition"
          >
            Contact us to link your listing
          </a>
        </div>
      )}

      {listing && (
        <>
          {/* Stats row */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <StatCard
              icon={<Star className="h-5 w-5 text-yellow-400" />}
              label="Average Rating"
              value={listing.rating ? `${Number(listing.rating).toFixed(1)} / 5` : '—'}
              bg="bg-yellow-500/10"
            />
            <StatCard
              icon={<MessageSquare className="h-5 w-5 text-blue-400" />}
              label="Total Reviews"
              value={String(listing.review_count ?? 0)}
              bg="bg-blue-500/10"
            />
            <StatCard
              icon={<ImageIcon className="h-5 w-5 text-purple-400" />}
              label="Photos"
              value={String((listing.photos as string[])?.length ?? 0)}
              bg="bg-purple-500/10"
            />
            <StatCard
              icon={<Eye className="h-5 w-5 text-green-400" />}
              label="Plan"
              value={planLabel}
              bg="bg-green-500/10"
            />
          </div>

          {/* Listing snapshot */}
          <div className="grid lg:grid-cols-3 gap-6 mb-6">
            {/* Info card */}
            <div className="lg:col-span-2 bg-white/5 border border-white/10 rounded-2xl p-5">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-white font-semibold">Listing Info</h2>
                <Link href="/business/my-listing">
                  <Button size="sm" className="bg-orange-500 hover:bg-orange-600 text-white text-xs h-8">
                    Edit <ChevronRight className="h-3 w-3 ml-1" />
                  </Button>
                </Link>
              </div>
              <h3 className="text-xl font-bold text-white mb-3">{listing.name as string}</h3>
              <div className="space-y-2 text-sm text-slate-300">
                {Boolean(listing.address) && (
                  <div className="flex items-center gap-2">
                    <MapPin className="h-4 w-4 text-slate-500 flex-shrink-0" />
                    <span>{listing.address as string}</span>
                  </div>
                )}
                {Boolean(listing.phone) && (
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-slate-500 flex-shrink-0" />
                    <span>{listing.phone as string}</span>
                  </div>
                )}
                {Boolean(listing.website) && (
                  <div className="flex items-center gap-2">
                    <Globe className="h-4 w-4 text-slate-500 flex-shrink-0" />
                    <a href={listing.website as string} target="_blank" rel="noopener noreferrer"
                      className="text-orange-400 hover:text-orange-300 truncate">
                      {listing.website as string}
                    </a>
                  </div>
                )}
                {Boolean(listing.instagram) && (
                  <div className="flex items-center gap-2">
                    <Instagram className="h-4 w-4 text-slate-500 flex-shrink-0" />
                    <a href={`https://instagram.com/${(listing.instagram as string).replace('@', '')}`}
                      target="_blank" rel="noopener noreferrer"
                      className="text-orange-400 hover:text-orange-300">
                      {listing.instagram as string}
                    </a>
                  </div>
                )}
                {Boolean(listing.open_hours) && (
                  <div className="flex items-center gap-2">
                    <Clock className="h-4 w-4 text-slate-500 flex-shrink-0" />
                    <span>{listing.open_hours as string}</span>
                  </div>
                )}
              </div>
              <div className="mt-4 pt-4 border-t border-white/10 flex flex-wrap gap-2">
                <Badge className="bg-orange-500/10 text-orange-300 border-orange-500/20 text-xs capitalize border">
                  {listing.category as string}
                </Badge>
                <Badge className="bg-slate-700 text-slate-300 border-slate-600 text-xs capitalize border">
                  {(listing.neighborhood as string)?.replace(/([A-Z])/g, ' $1') ?? ''}
                </Badge>
                {Boolean(listing.is_open) && (
                  <Badge className="bg-green-500/10 text-green-400 border-green-500/20 text-xs border">Open</Badge>
                )}
                {Boolean(listing.is_featured) && (
                  <Badge className="bg-yellow-500/10 text-yellow-400 border-yellow-500/20 text-xs border">Featured</Badge>
                )}
              </div>
            </div>

            {/* Photo preview */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-white font-semibold">Photos</h2>
                <Link href="/business/photos">
                  <Button size="sm" variant="ghost" className="text-slate-400 hover:text-white text-xs h-8">
                    Manage
                  </Button>
                </Link>
              </div>
              {(listing.photos as string[])?.length > 0 ? (
                <div className="grid grid-cols-2 gap-2">
                  {(listing.photos as string[]).slice(0, 4).map((url, i) => (
                    <div key={i} className="aspect-square rounded-lg overflow-hidden bg-slate-800">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={url} alt="" className="w-full h-full object-cover" />
                    </div>
                  ))}
                </div>
              ) : (
                <div className="aspect-square rounded-lg bg-slate-800 flex flex-col items-center justify-center text-slate-500 text-sm">
                  <ImageIcon className="h-8 w-8 mb-2" />
                  <span>No photos yet</span>
                </div>
              )}
              <Link href="/business/photos">
                <Button size="sm" className="w-full mt-3 bg-white/5 hover:bg-white/10 text-white border border-white/10 text-xs">
                  Add Photos
                </Button>
              </Link>
            </div>
          </div>

          {/* Recent Reviews */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 mb-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-white font-semibold">Recent Reviews</h2>
              <Link href="/business/reviews">
                <Button size="sm" variant="ghost" className="text-slate-400 hover:text-white text-xs h-8">
                  View all <ChevronRight className="h-3 w-3 ml-1" />
                </Button>
              </Link>
            </div>
            {reviews.length === 0 ? (
              <p className="text-slate-500 text-sm text-center py-4">No reviews yet</p>
            ) : (
              <div className="space-y-3">
                {reviews.map((r) => (
                  <div key={r.id} className="flex gap-3 p-3 bg-white/5 rounded-xl">
                    <div className="flex-shrink-0">
                      <div className="flex gap-0.5">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <Star
                            key={i}
                            className={`h-3.5 w-3.5 ${i < r.rating ? 'text-yellow-400 fill-yellow-400' : 'text-slate-600'}`}
                          />
                        ))}
                      </div>
                    </div>
                    <div className="min-w-0">
                      <p className="text-slate-300 text-sm line-clamp-2">{r.comment ?? 'No comment'}</p>
                      <p className="text-slate-500 text-xs mt-1">
                        {new Date(r.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Upgrade banner for free tier */}
          {!isPaid && (
            <div className="bg-gradient-to-r from-orange-500/10 to-yellow-500/10 border border-orange-500/20 rounded-2xl p-5">
              <div className="flex items-center gap-3 mb-2">
                <TrendingUp className="h-5 w-5 text-orange-400" />
                <h3 className="text-white font-semibold">Boost your visibility</h3>
              </div>
              <p className="text-slate-400 text-sm mb-4">
                Upgrade to Standard or Premium to appear at the top of search results, get a featured map pin, and reply to reviews.
              </p>
              <a
                href="mailto:hello@vallartapp.com?subject=Upgrade my VallartApp plan"
                className="inline-flex items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white text-sm font-medium px-4 py-2 rounded-lg transition"
              >
                <Crown className="h-4 w-4" /> Upgrade Plan
              </a>
            </div>
          )}
        </>
      )}
    </div>
  )
}

function StatCard({ icon, label, value, bg }: { icon: React.ReactNode; label: string; value: string; bg: string }) {
  return (
    <div className="bg-white/5 border border-white/10 rounded-2xl p-4">
      <div className={`w-9 h-9 ${bg} rounded-xl flex items-center justify-center mb-3`}>
        {icon}
      </div>
      <p className="text-slate-400 text-xs mb-1">{label}</p>
      <p className="text-white font-bold text-lg">{value}</p>
    </div>
  )
}
