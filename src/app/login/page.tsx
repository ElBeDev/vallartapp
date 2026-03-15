'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { toast } from 'sonner'
import { MapPin, Loader2, Eye, EyeOff } from 'lucide-react'
import { useRouter } from 'next/navigation'

type Mode = 'password' | 'magic'

export default function LoginPage() {
  const router = useRouter()
  const supabase = createClient()

  const [mode, setMode]           = useState<Mode>('password')
  const [email, setEmail]         = useState('')
  const [password, setPassword]   = useState('')
  const [showPw, setShowPw]       = useState(false)
  const [loading, setLoading]     = useState(false)
  const [magicSent, setMagicSent] = useState(false)
  const [cooldown, setCooldown]   = useState(0)   // seconds remaining

  // Countdown timer for magic link rate-limit cooldown
  useEffect(() => {
    if (cooldown <= 0) return
    const t = setInterval(() => setCooldown(c => c - 1), 1000)
    return () => clearInterval(t)
  }, [cooldown])

  // Email + Password sign in
  const handlePassword = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email || !password) { toast.error('Enter your email and password'); return }
    setLoading(true)
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      toast.error(error.message)
    } else {
      toast.success('Signed in!')
      router.push('/dashboard')
      router.refresh()
    }
    setLoading(false)
  }

  // Magic Link (OTP) — with cooldown to avoid 429
  const handleMagicLink = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email) { toast.error('Enter your email first'); return }
    if (cooldown > 0) { toast.error(`Wait ${cooldown}s before requesting another link`); return }

    setLoading(true)
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: `${location.origin}/auth/callback` },
    })
    if (error) {
      if (error.message.includes('429') || error.status === 429) {
        toast.error('Too many requests — wait a minute and try again')
        setCooldown(60)
      } else {
        toast.error(error.message)
      }
    } else {
      setMagicSent(true)
      setCooldown(60)
    }
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-teal-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="text-center pb-2">
          <div className="flex justify-center mb-4">
            <div className="bg-orange-500 rounded-2xl p-4">
              <MapPin className="h-10 w-10 text-white" />
            </div>
          </div>
          <CardTitle className="text-2xl font-bold text-slate-800">VallartApp Admin</CardTitle>
          <CardDescription className="text-slate-500">
            Puerto Vallarta content management portal
          </CardDescription>
        </CardHeader>

        <CardContent className="pt-2">
          {/* Mode tabs */}
          <div className="flex rounded-lg bg-slate-100 p-1 mb-6">
            {(['password', 'magic'] as Mode[]).map(m => (
              <button
                key={m}
                onClick={() => { setMode(m); setMagicSent(false) }}
                className={`flex-1 py-2 text-sm font-medium rounded-md transition-all ${
                  mode === m
                    ? 'bg-white text-slate-800 shadow-sm'
                    : 'text-slate-500 hover:text-slate-700'
                }`}
              >
                {m === 'password' ? '🔑 Password' : '✨ Magic Link'}
              </button>
            ))}
          </div>

          {/* Password form */}
          {mode === 'password' && (
            <form onSubmit={handlePassword} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  required
                  autoFocus
                  className="h-11"
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="password">Password</Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPw ? 'text' : 'password'}
                    placeholder="••••••••"
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    required
                    className="h-11 pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPw(v => !v)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                  >
                    {showPw ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>
              <Button
                type="submit"
                className="w-full h-11 bg-orange-500 hover:bg-orange-600 text-white font-semibold"
                disabled={loading}
              >
                {loading ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Signing in...</> : 'Sign In'}
              </Button>
              <p className="text-xs text-center text-slate-400">
                First time? Use Magic Link tab to set up your account, then set a password in Supabase Auth.
              </p>
            </form>
          )}

          {/* Magic link form */}
          {mode === 'magic' && (
            <>
              {magicSent ? (
                <div className="text-center py-6">
                  <div className="text-5xl mb-4">📬</div>
                  <h3 className="text-lg font-semibold text-slate-800 mb-2">Check your email!</h3>
                  <p className="text-slate-500 text-sm mb-4">
                    Magic link sent to <strong>{email}</strong>.<br />
                    Click it to sign in — no password needed.
                  </p>
                  {cooldown > 0 && (
                    <p className="text-xs text-slate-400 mb-4">
                      Can resend in {cooldown}s
                    </p>
                  )}
                  <Button
                    variant="ghost"
                    className="text-slate-500"
                    disabled={cooldown > 0}
                    onClick={() => setMagicSent(false)}
                  >
                    {cooldown > 0 ? `Resend in ${cooldown}s` : 'Send another link'}
                  </Button>
                </div>
              ) : (
                <form onSubmit={handleMagicLink} className="space-y-4">
                  <div className="space-y-1.5">
                    <Label htmlFor="email-magic">Email</Label>
                    <Input
                      id="email-magic"
                      type="email"
                      placeholder="you@example.com"
                      value={email}
                      onChange={e => setEmail(e.target.value)}
                      required
                      autoFocus
                      className="h-11"
                    />
                  </div>
                  <Button
                    type="submit"
                    className="w-full h-11 bg-orange-500 hover:bg-orange-600 text-white font-semibold"
                    disabled={loading || cooldown > 0}
                  >
                    {loading
                      ? <><Loader2 className="h-4 w-4 animate-spin mr-2" />Sending...</>
                      : cooldown > 0
                        ? `Wait ${cooldown}s`
                        : '✨ Send Magic Link'}
                  </Button>
                  <p className="text-xs text-center text-slate-400">
                    Supabase limits to ~3 emails/hour on free tier.
                  </p>
                </form>
              )}
            </>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
