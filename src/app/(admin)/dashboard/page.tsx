import { createClient } from '@/lib/supabase/server'
import { MapPin, Calendar, Users, Star, TrendingUp, Eye, PlusCircle } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import Link from 'next/link'

async function getStats() {
  const supabase = await createClient()
  const [listings, events, reviews] = await Promise.all([
    supabase.from('listings').select('id, is_featured, is_premium, rating, category', { count: 'exact' }),
    supabase.from('events').select('id', { count: 'exact' }),
    supabase.from('reviews').select('id', { count: 'exact' }),
  ])

  // Build category breakdown
  const categoryMap: Record<string, number> = {}
  for (const l of listings.data ?? []) {
    categoryMap[l.category] = (categoryMap[l.category] ?? 0) + 1
  }
  const categoryBreakdown = Object.entries(categoryMap)
    .sort((a, b) => b[1] - a[1])
    .map(([cat, count]) => ({ cat, count }))

  return {
    totalListings:    listings.count ?? 0,
    totalEvents:      events.count ?? 0,
    totalReviews:     reviews.count ?? 0,
    featuredListings: listings.data?.filter(l => l.is_featured).length ?? 0,
    premiumListings:  listings.data?.filter(l => l.is_premium).length ?? 0,
    avgRating: listings.data && listings.data.length > 0
      ? (listings.data.reduce((a, l) => a + (l.rating ?? 0), 0) / listings.data.length).toFixed(1)
      : '0.0',
    categoryBreakdown,
  }
}

export default async function DashboardPage() {
  let stats
  try {
    stats = await getStats()
  } catch {
    stats = { totalListings: 0, totalEvents: 0, totalReviews: 0, featuredListings: 0, premiumListings: 0, avgRating: '0.0', categoryBreakdown: [] }
  }

  const cards = [
    { title: 'Total Listings',  value: stats.totalListings,    icon: MapPin,    color: 'text-orange-500', bg: 'bg-orange-50',  href: '/listings' },
    { title: 'Total Events',    value: stats.totalEvents,      icon: Calendar,  color: 'text-teal-500',   bg: 'bg-teal-50',    href: '/events' },
    { title: 'Reviews',         value: stats.totalReviews,     icon: Star,      color: 'text-yellow-500', bg: 'bg-yellow-50',  href: '/listings' },
    { title: 'Featured',        value: stats.featuredListings, icon: TrendingUp, color: 'text-purple-500', bg: 'bg-purple-50', href: '/listings' },
    { title: 'Premium',         value: stats.premiumListings,  icon: Eye,       color: 'text-blue-500',   bg: 'bg-blue-50',   href: '/listings' },
    { title: 'Avg Rating',      value: `${stats.avgRating} / 5`, icon: Star,   color: 'text-green-500',  bg: 'bg-green-50',  href: '/listings' },
  ]

  const CATEGORY_ICONS: Record<string, string> = {
    'Restaurants':      '🍽️',
    'Bars & Nightlife': '🍹',
    'Hotels':           '🏨',
    'Activities':       '🏄',
    'Yacht Rentals':    '⛵',
    'Car & Moto Rental':'🏍️',
    'Beaches':          '🏖️',
    'Shopping':         '🛍️',
    'Spas & Wellness':  '💆',
  }

  return (
    <div className="p-6 max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-800">Dashboard</h1>
        <p className="text-slate-500 mt-1">Welcome back! Here&apos;s what&apos;s happening with VallartApp.</p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
        {cards.map(({ title, value, icon: Icon, color, bg, href }) => (
          <Link key={title} href={href}>
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-slate-500 font-medium">{title}</p>
                    <p className="text-3xl font-bold text-slate-800 mt-1">{value}</p>
                  </div>
                  <div className={`${bg} rounded-xl p-3`}>
                    <Icon className={`h-6 w-6 ${color}`} />
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      {/* Category Breakdown + Quick Actions */}
      <div className="grid md:grid-cols-2 gap-6 mb-6">
        {/* Category breakdown table */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base text-slate-700">Listings by Category</CardTitle>
          </CardHeader>
          <CardContent>
            {stats.categoryBreakdown.length === 0 ? (
              <p className="text-sm text-slate-400">No listings yet.</p>
            ) : (
              <table className="w-full text-sm">
                <tbody>
                  {stats.categoryBreakdown.map(({ cat, count }) => (
                    <tr key={cat} className="border-b last:border-0">
                      <td className="py-2 text-slate-600 flex items-center gap-2">
                        <span>{CATEGORY_ICONS[cat] ?? '📍'}</span>
                        <span>{cat}</span>
                      </td>
                      <td className="py-2 text-right">
                        <span className="font-semibold text-slate-800">{count}</span>
                      </td>
                      <td className="py-2 pl-3 w-24">
                        <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-orange-400 rounded-full"
                            style={{ width: `${Math.round((count / stats.totalListings) * 100)}%` }}
                          />
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </CardContent>
        </Card>

        {/* Quick actions */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-base text-slate-700">Quick Actions</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              {[
                { href: '/listings/new', label: 'Add new listing',  color: 'bg-orange-500 hover:bg-orange-600' },
                { href: '/events/new',   label: 'Add new event',    color: 'bg-teal-500 hover:bg-teal-600' },
              ].map(({ href, label, color }) => (
                <Link key={href} href={href}>
                  <button className={`w-full flex items-center gap-2 px-4 py-3 rounded-lg text-white text-sm font-medium ${color} transition-colors`}>
                    <PlusCircle className="h-4 w-4" />
                    {label}
                  </button>
                </Link>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-base text-slate-700">Next Steps</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-slate-600">
                <li className="flex gap-2">
                  <span className="text-teal-500 font-bold">→</span>
                  <span>Enable Auth providers in Supabase dashboard (Apple, Google)</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-purple-500 font-bold">→</span>
                  <span>Upload individual photos per listing via the edit form</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-blue-500 font-bold">→</span>
                  <span>Set up business owner accounts and subscription tiers</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-orange-500 font-bold">→</span>
                  <span>Configure RevenueCat for premium user subscriptions</span>
                </li>
              </ul>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
