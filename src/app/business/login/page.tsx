'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { toast } from 'sonner'
import { MapPin, Loader2, Building2, Mail, ArrowRight } from 'lucide-react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Suspense } from 'react'

function BusinessLoginForm() {
  const router       = useRouter()
  const searchParams = useSearchParams()
  const supabase     = createClient()

  const [email, setEmail]         = useState('')
  const [loading, setLoading]     = useState(false)
  const [magicSent, setMagicSent] = useState(false)
  const [cooldown, setCooldown]   = useState(0)

  const reason = searchParams.get('reason')

  useEffect(() => {
    if (cooldown <= 0) return
    const t = setInterval(() => setCooldown(c => c - 1), 1000)
    return () => clearInterval(t)
  }, [cooldown])

  // Check if already logged in
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) router.replace('/business/dashboard')
    })
  }, []) // eslint-disable-line

  const handleMagicLink = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email) { toast.error('Enter your email'); return }
    if (cooldown > 0) { toast.error(`Wait ${cooldown}s before trying again`); return }
    setLoading(true)
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: `${window.location.origin}/auth/callback?next=/business/dashboard` }
    })
    if (error) {
      if (error.status === 429) {
        setCooldown(60)
        toast.error('Too many requests — wait 60 seconds')
      } else {
        toast.error(error.message)
      }
    } else {
      setMagicSent(true)
      setCooldown(60)
      toast.success('Magic link sent! Check your email.')
    }
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-950 to-slate-900 flex items-center justify-center p-4">
      <div className="w-full max-w-md">

        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-orange-500 rounded-2xl mb-4 shadow-lg">
            <MapPin className="h-8 w-8 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white">VallartApp</h1>
          <p className="text-slate-400 mt-1">Business Portal</p>
        </div>

        {/* Reason banner */}
        {reason === 'not_registered' && (
          <div className="mb-4 p-3 bg-amber-500/10 border border-amber-500/30 rounded-xl text-amber-300 text-sm text-center">
            Your account isn&apos;t linked to a business yet. Sign in and contact us to get started.
          </div>
        )}

        {/* Card */}
        <div className="bg-white/5 backdrop-blur border border-white/10 rounded-2xl p-8 shadow-2xl">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-2 bg-orange-500/10 rounded-lg">
              <Building2 className="h-5 w-5 text-orange-400" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-white">Business Owner Login</h2>
              <p className="text-slate-400 text-sm">Manage your listing on VallartApp</p>
            </div>
          </div>

          {magicSent ? (
            <div className="text-center py-6">
              <div className="w-16 h-16 bg-green-500/10 rounded-full flex items-center justify-center mx-auto mb-4">
                <Mail className="h-8 w-8 text-green-400" />
              </div>
              <h3 className="text-white font-semibold text-lg mb-2">Check your email</h3>
              <p className="text-slate-400 text-sm mb-4">
                We sent a magic link to <span className="text-white font-medium">{email}</span>
              </p>
              <Button
                variant="ghost"
                className="text-slate-400 hover:text-white"
                disabled={cooldown > 0}
                onClick={() => setMagicSent(false)}
              >
                {cooldown > 0 ? `Resend in ${cooldown}s` : 'Send again'}
              </Button>
            </div>
          ) : (
            <form onSubmit={handleMagicLink} className="space-y-4">
              <div className="space-y-2">
                <Label className="text-slate-300 text-sm">Email address</Label>
                <Input
                  type="email"
                  placeholder="you@yourbusiness.com"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  className="bg-white/5 border-white/10 text-white placeholder:text-slate-500 focus:border-orange-500 focus:ring-orange-500"
                  required
                />
              </div>
              <Button
                type="submit"
                className="w-full bg-orange-500 hover:bg-orange-600 text-white font-semibold h-11"
                disabled={loading || cooldown > 0}
              >
                {loading ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <span className="flex items-center gap-2">
                    Send magic link <ArrowRight className="h-4 w-4" />
                  </span>
                )}
              </Button>
            </form>
          )}
        </div>

        {/* Footer note */}
        <p className="text-center text-slate-500 text-xs mt-6">
          Not registered yet?{' '}
          <a href="mailto:hello@vallartapp.com" className="text-orange-400 hover:text-orange-300">
            Contact us to list your business
          </a>
        </p>
      </div>
    </div>
  )
}

export default function BusinessLoginPage() {
  return (
    <Suspense>
      <BusinessLoginForm />
    </Suspense>
  )
}
