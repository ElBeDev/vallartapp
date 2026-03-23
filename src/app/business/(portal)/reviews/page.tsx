import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { Star, MessageSquare } from 'lucide-react'

export default async function BizReviewsPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/business/login')

  const { data: biz } = await supabase
    .from('business_owners')
    .select('plan, listing_id, listings(id, name, rating, review_count)')
    .eq('user_id', user.id)
    .single()

  if (!biz) redirect('/business/login?reason=not_registered')
  const listing = biz.listings as unknown as Record<string, unknown> | null

  const reviews = listing ? (await supabase
    .from('reviews')
    .select('id, rating, comment, created_at')
    .eq('listing_id', listing.id as string)
    .order('created_at', { ascending: false })
  ).data ?? [] : []

  const canReply = biz.plan?.startsWith('biz_standard') || biz.plan?.startsWith('biz_premium')

  // Rating distribution
  const dist = [5, 4, 3, 2, 1].map(stars => ({
    stars,
    count: reviews.filter(r => r.rating === stars).length,
  }))
  const total = reviews.length

  return (
    <div className="p-6 max-w-3xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">Reviews</h1>
        <p className="text-slate-400 text-sm mt-1">{listing?.name as string}</p>
      </div>

      {/* Summary */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5 mb-6 flex gap-6 items-center">
        <div className="text-center flex-shrink-0">
          <p className="text-5xl font-bold text-white">{Number(listing?.rating ?? 0).toFixed(1)}</p>
          <div className="flex gap-0.5 justify-center my-1">
            {Array.from({ length: 5 }).map((_, i) => (
              <Star key={i} className={`h-4 w-4 ${i < Math.round(Number(listing?.rating ?? 0)) ? 'text-yellow-400 fill-yellow-400' : 'text-slate-600'}`} />
            ))}
          </div>
          <p className="text-slate-400 text-xs">{total} reviews</p>
        </div>
        <div className="flex-1 space-y-1.5">
          {dist.map(({ stars, count }) => (
            <div key={stars} className="flex items-center gap-2 text-xs">
              <span className="text-slate-400 w-4">{stars}</span>
              <Star className="h-3 w-3 text-yellow-400 fill-yellow-400 flex-shrink-0" />
              <div className="flex-1 bg-slate-700 rounded-full h-1.5 overflow-hidden">
                <div
                  className="h-full bg-yellow-400 rounded-full transition-all"
                  style={{ width: total > 0 ? `${(count / total) * 100}%` : '0%' }}
                />
              </div>
              <span className="text-slate-500 w-4 text-right">{count}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Review list */}
      {reviews.length === 0 ? (
        <div className="text-center py-16 bg-white/5 border border-white/10 rounded-2xl">
          <MessageSquare className="h-10 w-10 text-slate-600 mx-auto mb-3" />
          <p className="text-slate-400">No reviews yet</p>
          <p className="text-slate-500 text-sm mt-1">Reviews from the app will appear here</p>
        </div>
      ) : (
        <div className="space-y-3">
          {reviews.map((r) => (
            <div key={r.id} className="bg-white/5 border border-white/10 rounded-2xl p-4">
              <div className="flex items-center justify-between mb-2">
                <div className="flex gap-0.5">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} className={`h-3.5 w-3.5 ${i < r.rating ? 'text-yellow-400 fill-yellow-400' : 'text-slate-600'}`} />
                  ))}
                </div>
                <span className="text-slate-500 text-xs">
                  {new Date(r.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                </span>
              </div>
              <p className="text-slate-300 text-sm">{r.comment ?? <span className="text-slate-500 italic">No comment</span>}</p>
              {canReply && (
                <div className="mt-3 pt-3 border-t border-white/10">
                  <p className="text-xs text-slate-500 mb-1">Reply (Standard/Premium feature)</p>
                  <div className="flex gap-2">
                    <input
                      className="flex-1 bg-white/5 border border-white/10 rounded-lg px-3 py-1.5 text-sm text-white placeholder:text-slate-500 focus:outline-none focus:border-orange-500"
                      placeholder="Write a reply..."
                    />
                    <button className="bg-orange-500 hover:bg-orange-600 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">
                      Reply
                    </button>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {!canReply && reviews.length > 0 && (
        <p className="text-slate-500 text-xs text-center mt-4">
          <a href="mailto:hello@vallartapp.com?subject=Upgrade plan" className="text-orange-400 hover:text-orange-300">
            Upgrade to Standard
          </a>{' '}
          to reply to reviews.
        </p>
      )}
    </div>
  )
}
