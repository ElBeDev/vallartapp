import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import BizPhotosManager from '@/components/business/BizPhotosManager'

export default async function BizPhotosPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/business/login')

  const { data: biz } = await supabase
    .from('business_owners')
    .select('plan, listing_id, listings(id, name, photos)')
    .eq('user_id', user.id)
    .single()

  if (!biz) redirect('/business/login?reason=not_registered')
  const listing = biz.listings as unknown as Record<string, unknown> | null

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">Photos</h1>
        <p className="text-slate-400 text-sm mt-1">
          Drag to reorder — the first photo is your cover image on the app.
        </p>
      </div>
      {listing
        ? <BizPhotosManager listing={listing} plan={biz.plan ?? 'free'} />
        : <p className="text-slate-500">No listing connected yet.</p>
      }
    </div>
  )
}
