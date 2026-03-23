import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import BizListingForm from '@/components/business/BizListingForm'

export default async function MyListingPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/business/login')

  const { data: biz } = await supabase
    .from('business_owners')
    .select('plan, listing_id, listings(*)')
    .eq('user_id', user.id)
    .single()

  if (!biz) redirect('/business/login?reason=not_registered')

  const listing = biz.listings as unknown as Record<string, unknown> | null

  return (
    <div className="p-6 max-w-3xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">Edit My Listing</h1>
        <p className="text-slate-400 text-sm mt-1">
          Changes are saved immediately and appear on the app within minutes.
        </p>
      </div>
      {listing ? (
        <BizListingForm listing={listing} plan={biz.plan ?? 'free'} />
      ) : (
        <div className="bg-amber-500/10 border border-amber-500/20 rounded-2xl p-6 text-center">
          <p className="text-amber-300 text-sm">
            No listing is connected to your account yet. Contact us to link your business.
          </p>
        </div>
      )}
    </div>
  )
}
