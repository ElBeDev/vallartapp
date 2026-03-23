'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  LayoutDashboard, MapPin, ImageIcon, Star,
  BarChart2, LogOut, Menu, X, Building2, Crown
} from 'lucide-react'
import { useState } from 'react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { toast } from 'sonner'

const navItems = [
  { href: '/business/dashboard',  label: 'Dashboard',     icon: LayoutDashboard },
  { href: '/business/my-listing', label: 'My Listing',    icon: MapPin },
  { href: '/business/photos',     label: 'Photos',        icon: ImageIcon },
  { href: '/business/reviews',    label: 'Reviews',       icon: Star },
  { href: '/business/analytics',  label: 'Analytics',     icon: BarChart2 },
]

interface BizSidebarProps {
  businessName?: string
  plan?: string
}

export default function BizSidebar({ businessName, plan }: BizSidebarProps) {
  const pathname = usePathname()
  const router   = useRouter()
  const [open, setOpen] = useState(false)
  const supabase = createClient()

  const planLabel = plan?.startsWith('biz_premium') ? 'Premium' :
                    plan?.startsWith('biz_standard') ? 'Standard' : 'Free'
  const planColor = plan?.startsWith('biz_premium') ? 'text-yellow-400' :
                    plan?.startsWith('biz_standard') ? 'text-blue-400' : 'text-slate-400'

  const signOut = async () => {
    await supabase.auth.signOut()
    toast.success('Signed out')
    router.push('/business/login')
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
            pathname === href || pathname.startsWith(href + '/')
              ? 'bg-orange-500 text-white shadow-sm'
              : 'text-slate-300 hover:bg-white/5 hover:text-white'
          )}
        >
          <Icon className="h-4 w-4 flex-shrink-0" />
          {label}
        </Link>
      ))}
    </nav>
  )

  const SidebarContent = () => (
    <div className="flex flex-col h-full bg-slate-900 border-r border-white/10">
      {/* Logo */}
      <div className="flex items-center gap-3 px-4 py-5 border-b border-white/10">
        <div className="bg-orange-500 rounded-lg p-1.5 flex-shrink-0">
          <MapPin className="h-5 w-5 text-white" />
        </div>
        <div className="min-w-0">
          <p className="font-bold text-white text-sm truncate">VallartApp</p>
          <p className="text-slate-500 text-xs">Business Portal</p>
        </div>
      </div>

      {/* Business info */}
      <div className="px-4 py-3 border-b border-white/10">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-orange-500/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <Building2 className="h-4 w-4 text-orange-400" />
          </div>
          <div className="min-w-0">
            <p className="text-white text-sm font-medium truncate">{businessName ?? 'My Business'}</p>
            <div className={cn('flex items-center gap-1 text-xs', planColor)}>
              <Crown className="h-3 w-3" />
              {planLabel} Plan
            </div>
          </div>
        </div>
      </div>

      <NavLinks />

      {/* Sign out */}
      <div className="px-3 pb-4">
        <button
          onClick={signOut}
          className="flex items-center gap-3 w-full rounded-lg px-3 py-2.5 text-sm font-medium text-slate-400 hover:bg-white/5 hover:text-white transition-all"
        >
          <LogOut className="h-4 w-4" />
          Sign Out
        </button>
      </div>
    </div>
  )

  return (
    <>
      {/* Desktop */}
      <div className="hidden lg:flex w-64 flex-shrink-0 h-screen sticky top-0">
        <SidebarContent />
      </div>

      {/* Mobile top bar */}
      <div className="lg:hidden flex items-center justify-between px-4 py-3 bg-slate-900 border-b border-white/10 sticky top-0 z-40">
        <div className="flex items-center gap-2">
          <div className="bg-orange-500 rounded-lg p-1.5">
            <MapPin className="h-5 w-5 text-white" />
          </div>
          <span className="font-bold text-white">Business Portal</span>
        </div>
        <Button variant="ghost" size="icon" onClick={() => setOpen(!open)} className="text-white">
          {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </Button>
      </div>

      {/* Mobile drawer */}
      {open && (
        <div className="lg:hidden fixed inset-0 z-30 bg-black/60" onClick={() => setOpen(false)}>
          <div className="w-64 h-full flex flex-col" onClick={e => e.stopPropagation()}>
            <SidebarContent />
          </div>
        </div>
      )}
    </>
  )
}
