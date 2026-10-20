import Link from 'next/link'
import { MapPin } from 'lucide-react'
import { site } from '@/lib/site'

export default function LegalLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-teal-50">
      <header className="border-b border-orange-100 bg-white/70 backdrop-blur">
        <div className="mx-auto flex max-w-3xl items-center gap-2 px-4 py-4">
          <MapPin className="h-5 w-5 text-orange-500" />
          <span className="font-semibold text-slate-800">{site.appName}</span>
          <nav className="ml-auto flex gap-4 text-sm text-slate-500">
            <Link href="/privacy" className="hover:text-orange-500">Privacy</Link>
            <Link href="/terms" className="hover:text-orange-500">Terms</Link>
            <Link href="/support" className="hover:text-orange-500">Support</Link>
          </nav>
        </div>
      </header>
      <main className="mx-auto max-w-3xl px-4 py-10 text-slate-700 [&_h1]:mb-2 [&_h1]:text-3xl [&_h1]:font-bold [&_h1]:text-slate-800 [&_h2]:mb-2 [&_h2]:mt-8 [&_h2]:text-xl [&_h2]:font-semibold [&_h2]:text-slate-800 [&_li]:ml-5 [&_li]:list-disc [&_p]:mb-3 [&_ul]:mb-3 [&_a]:text-orange-600 [&_a]:underline">
        {children}
      </main>
    </div>
  )
}
