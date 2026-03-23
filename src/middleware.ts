import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()
  const pathname = request.nextUrl.pathname

  // ── Public routes ──────────────────────────────────────────
  const publicPaths = ['/login', '/business/login', '/auth/callback', '/unauthorized']
  const isPublic = publicPaths.some(p => pathname.startsWith(p))
  if (!user && !isPublic) {
    const url = request.nextUrl.clone()
    url.pathname = pathname.startsWith('/business') ? '/business/login' : '/login'
    return NextResponse.redirect(url)
  }

  if (!user) return supabaseResponse

  // ── Business Owner routes /business/* ─────────────────────
  if (pathname.startsWith('/business') && !pathname.startsWith('/business/login')) {
    // Check they have a row in business_owners with is_active = true
    const { data: biz } = await supabase
      .from('business_owners')
      .select('id, is_active, plan')
      .eq('user_id', user.id)
      .single()

    if (!biz) {
      // Not registered — send to upgrade page
      const url = request.nextUrl.clone()
      url.pathname = '/business/login'
      url.searchParams.set('reason', 'not_registered')
      return NextResponse.redirect(url)
    }
    return supabaseResponse
  }

  // ── Admin routes (everything else) ────────────────────────
  const raw = (process.env.ADMIN_EMAILS ?? '').trim()
  if (raw !== '') {
    const adminEmails = raw.split(',').map(e => e.trim()).filter(Boolean)
    if (adminEmails.length > 0 && !adminEmails.includes(user.email ?? '')) {
      const url = request.nextUrl.clone()
      url.pathname = '/unauthorized'
      return NextResponse.redirect(url)
    }
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
