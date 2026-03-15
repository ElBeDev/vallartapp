'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import {
  LayoutDashboard, MapPin, Calendar, Users,
  Bell, LogOut, Menu, X, Building2
} from 'lucide-react'
import { useState } from 'react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { toast } from 'sonner'

const navItems = [
  { href: '/',                  label: 'Dashboard',       icon: LayoutDashboard },
  { href: '/listings',          label: 'Listings',        icon: MapPin },
  { href: '/events',            label: 'Events',          icon: Calendar },
  { href: '/business-owners',  label: 'Business Owners', icon: Building2 },
  { href: '/notifications',    label: 'Notifications',   icon: Bell },
]

export default function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const [open, setOpen] = useState(false)
  const supabase = createClient()

  const signOut = async () => {
    await supabase.auth.signOut()
    toast.success('Signed out')
    router.push('/login')
    router.refresh()
  }

  const NavLinks = () => (
    <nav className="flex-1 space-y-1 px-3 py-4">
      {navItems.map(({ href, label, icon: Icon }) => (
        <Link
          key={href}
          href={href}
          onClick={() => setOpen(false)}
          className={cn(
            'flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all',
            (href === '/dashboard' ? pathname === href || pathname === '/' : pathname.startsWith(href))
              ? 'bg-orange-500 text-white shadow-sm'
              : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'
          )}
        >
          <Icon className="h-4 w-4 flex-shrink-0" />
          {label}
        </Link>
      ))}
    </nav>
  )

  return (
    <>
      {/* Mobile top bar */}
      <div className="lg:hidden flex items-center justify-between px-4 py-3 bg-white border-b sticky top-0 z-40">
        <div className="flex items-center gap-2">
          <div className="bg-orange-500 rounded-lg p-1.5">
            <MapPin className="h-5 w-5 text-white" />
          </div>
          <span className="font-bold text-slate-800">VallartApp Admin</span>
        </div>
        <Button variant="ghost" size="icon" onClick={() => setOpen(!open)}>
          {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </Button>
      </div>

      {/* Mobile drawer */}
      {open && (
        <div className="lg:hidden fixed inset-0 z-30 bg-black/40" onClick={() => setOpen(false)}>
          <div className="w-64 h-full bg-white flex flex-col" onClick={e => e.stopPropagation()}>
            <div className="flex items-center gap-2 px-4 py-4 border-b">
              <div className="bg-orange-500 rounded-lg p-1.5">
                <MapPin className="h-5 w-5 text-white" />
              </div>
              <span className="font-bold text-slate-800">VallartApp Admin</span>
            </div>
            <NavLinks />
            <div className="p-3 border-t">
              <Button variant="ghost" className="w-full justify-start gap-3 text-slate-600 hover:text-red-600" onClick={signOut}>
                <LogOut className="h-4 w-4" /> Sign Out
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Desktop sidebar */}
      <aside className="hidden lg:flex flex-col w-64 bg-white border-r h-screen sticky top-0">
        <div className="flex items-center gap-3 px-5 py-5 border-b">
          <div className="bg-orange-500 rounded-xl p-2">
            <MapPin className="h-6 w-6 text-white" />
          </div>
          <div>
            <p className="font-bold text-slate-800 text-sm">VallartApp</p>
            <p className="text-xs text-slate-400">Admin Portal</p>
          </div>
        </div>
        <NavLinks />
        <div className="p-3 border-t">
          <Button variant="ghost" className="w-full justify-start gap-3 text-slate-500 hover:text-red-600 hover:bg-red-50" onClick={signOut}>
            <LogOut className="h-4 w-4" /> Sign Out
          </Button>
        </div>
      </aside>
    </>
  )
}
