import { createClient } from '@/lib/supabase/server'
import { Badge } from '@/components/ui/badge'
import { Building2 } from 'lucide-react'

export default async function BusinessOwnersPage() {
  const supabase = await createClient()
  const { data: owners } = await supabase
    .from('business_owners')
    .select('*, profiles(name, avatar_url)')
    .order('verified_at', { ascending: false })

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-slate-800">Business Owners</h1>
        <p className="text-slate-500 mt-1">{owners?.length ?? 0} registered business owners</p>
      </div>

      {!owners || owners.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-xl border">
          <Building2 className="h-16 w-16 text-slate-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-slate-700 mb-2">No business owners yet</h3>
          <p className="text-slate-400">Business owners will appear here once they sign up through the iOS app.</p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border shadow-sm overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-slate-50 border-b">
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Owner</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Subscription</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Listings</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Status</th>
                <th className="text-left px-4 py-3 font-semibold text-slate-600">Verified</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {owners.map((o: Record<string, unknown>) => (
                <tr key={o.id as string} className="hover:bg-slate-50">
                  <td className="px-4 py-3">
                    <p className="font-medium text-slate-800">{(o.profiles as Record<string,unknown>)?.name as string ?? 'Unknown'}</p>
                  </td>
                  <td className="px-4 py-3">
                    <Badge className={
                      o.subscription_tier === 'premium' ? 'bg-yellow-100 text-yellow-700 border-0' :
                      o.subscription_tier === 'standard' ? 'bg-blue-100 text-blue-700 border-0' :
                      'bg-slate-100 text-slate-600 border-0'
                    }>
                      {o.subscription_tier as string}
                    </Badge>
                  </td>
                  <td className="px-4 py-3 text-slate-600">
                    {((o.listing_ids as string[])?.length ?? 0)} listings
                  </td>
                  <td className="px-4 py-3">
                    <Badge className={o.subscription_status === 'active' ? 'bg-green-100 text-green-700 border-0' : 'bg-red-100 text-red-700 border-0'}>
                      {o.subscription_status as string}
                    </Badge>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    {o.verified_at ? new Date(o.verified_at as string).toLocaleDateString() : '—'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
