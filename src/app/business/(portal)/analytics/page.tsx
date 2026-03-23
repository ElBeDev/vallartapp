import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { BarChart2, TrendingUp, Star, MessageSquare, ImageIcon, Crown } from 'lucide-react'

export default async function BizAnalyticsPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/business/login')

  const { data: biz } = await supabase
    .from('business_owners')
    .select('plan, listing_id, listings(id, name, rating, review_count, photos, is_featured, is_premium)')
    .eq('user_id', user.id)
    .single()

  if (!biz) redirect('/business/login?reason=not_registered')

  const listing  = biz.listings as unknown as Record<string, unknown> | null
  const plan     = biz.plan ?? 'free'
  const isPaid   = plan.startsWith('biz_standard') || plan.startsWith('biz_premium')
  const isPremium = plan.startsWith('biz_premium')

  const reviewCount = Number(listing?.review_count ?? 0)
  const photoCount  = (listing?.photos as string[])?.length ?? 0
  const rating      = Number(listing?.rating ?? 0)

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">Analytics</h1>
        <p className="text-slate-400 text-sm mt-1">{listing?.name as string}</p>
      </div>

      {!isPaid ? (
        // Upgrade gate
        <div className="bg-gradient-to-br from-orange-500/10 to-yellow-500/5 border border-orange-500/20 rounded-2xl p-8 text-center">
          <BarChart2 className="h-12 w-12 text-orange-400 mx-auto mb-4" />
          <h3 className="text-white text-xl font-bold mb-2">Analytics available on Standard+</h3>
          <p className="text-slate-400 text-sm mb-6 max-w-sm mx-auto">
            Track views, review trends, and performance insights. Available on Standard and Premium plans.
          </p>
          <a
            href="mailto:hello@vallartapp.com?subject=Upgrade to Standard"
            className="inline-flex items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white font-semibold px-5 py-2.5 rounded-xl transition"
          >
            <Crown className="h-4 w-4" /> Upgrade to Standard — $29/mo
          </a>
        </div>
      ) : (
        <>
          {/* Stats */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            {[
              { icon: <Star className="h-5 w-5 text-yellow-400" />, label: 'Avg Rating',     value: `${rating.toFixed(1)} / 5`, bg: 'bg-yellow-500/10' },
              { icon: <MessageSquare className="h-5 w-5 text-blue-400" />, label: 'Total Reviews', value: String(reviewCount),      bg: 'bg-blue-500/10' },
              { icon: <ImageIcon className="h-5 w-5 text-purple-400" />, label: 'Photos',         value: String(photoCount),        bg: 'bg-purple-500/10' },
              { icon: <TrendingUp className="h-5 w-5 text-green-400" />, label: 'Plan',            value: isPremium ? 'Premium' : 'Standard', bg: 'bg-green-500/10' },
            ].map((s, i) => (
              <div key={i} className="bg-white/5 border border-white/10 rounded-2xl p-4">
                <div className={`w-9 h-9 ${s.bg} rounded-xl flex items-center justify-center mb-3`}>{s.icon}</div>
                <p className="text-slate-400 text-xs mb-1">{s.label}</p>
                <p className="text-white font-bold text-lg">{s.value}</p>
              </div>
            ))}
          </div>

          {/* Listing health */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 mb-6">
            <h3 className="text-white font-semibold mb-4">Listing Health</h3>
            <div className="space-y-3">
              <HealthItem label="Photos" ok={photoCount >= 3}
                note={photoCount < 3 ? `Add ${3 - photoCount} more photos to improve visibility` : `${photoCount} photos — great!`} />
              <HealthItem label="Description" ok={Boolean(listing?.description)}
                note={listing?.description ? 'Description is set' : 'Add a description to attract more visitors'} />
              <HealthItem label="Phone number" ok={Boolean(listing?.phone)}
                note={listing?.phone ? 'Phone is set' : 'Add a phone number for direct contact'} />
              <HealthItem label="Website" ok={Boolean(listing?.website)}
                note={listing?.website ? 'Website is linked' : 'Add your website link'} />
              <HealthItem label="Instagram" ok={Boolean(listing?.instagram)}
                note={listing?.instagram ? 'Instagram is linked' : 'Add your Instagram handle'} />
              <HealthItem label="Hours" ok={Boolean(listing?.open_hours)}
                note={listing?.open_hours ? 'Hours are set' : 'Add your opening hours'} />
              {isPremium && (
                <HealthItem label="Featured placement" ok={Boolean(listing?.is_featured)}
                  note={listing?.is_featured ? 'You appear in featured results' : 'Contact us to activate featured placement'} />
              )}
            </div>
          </div>

          {/* Coming soon */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 text-center">
            <BarChart2 className="h-8 w-8 text-slate-600 mx-auto mb-2" />
            <p className="text-slate-400 text-sm font-medium">Detailed view & click analytics</p>
            <p className="text-slate-500 text-xs mt-1">Coming in the next update</p>
          </div>
        </>
      )}
    </div>
  )
}

function HealthItem({ label, ok, note }: { label: string; ok: boolean; note: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 ${ok ? 'bg-green-500/20' : 'bg-amber-500/20'}`}>
        <div className={`w-2 h-2 rounded-full ${ok ? 'bg-green-400' : 'bg-amber-400'}`} />
      </div>
      <div className="flex-1 min-w-0">
        <span className="text-white text-sm font-medium">{label}</span>
        <span className="text-slate-400 text-xs ml-2">{note}</span>
      </div>
    </div>
  )
}
