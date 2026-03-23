import { createClient } from '@/lib/supabase/server'
import BizSidebar from '@/components/business/BizSidebar'
import { redirect } from 'next/navigation'

export default async function BusinessPortalLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/business/login')

  // Get business owner record + their linked listing name
  const { data: biz } = await supabase
    .from('business_owners')
    .select('plan, business_name, listing_id, listings(name)')
    .eq('user_id', user.id)
    .single()

  const businessName = biz?.business_name
    ?? (biz?.listings as unknown as Record<string, string> | null)?.name
    ?? 'My Business'

  return (
    <div className="flex min-h-screen bg-slate-950">
      <BizSidebar businessName={businessName} plan={biz?.plan ?? 'free'} />
      <main className="flex-1 overflow-auto">
        {children}
      </main>
    </div>
  )
}
