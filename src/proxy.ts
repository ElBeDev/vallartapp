import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function proxy(request: NextRequest) {
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
  const publicPaths = ['/login', '/business/login', '/auth/callback', '/unauthorized', '/privacy', '/terms', '/support']
  const isPublic = publicPaths.some(p => pathname.startsWith(p))
  if (!user && !isPublic) {
    const url = request.nextUrl.clone()
    url.pathname = pathname.startsWith('/business') ? '/business/login' : '/login'
    return NextResponse.redirect(url)
  }

  if (!user || isPublic) return supabaseResponse

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
  // Fail closed: app users share this Supabase project, so an empty
  // ADMIN_EMAILS must not mean "every signed-in user is an admin".
  const adminEmails = (process.env.ADMIN_EMAILS ?? '')
    .split(',').map(e => e.trim().toLowerCase()).filter(Boolean)
  if (!adminEmails.includes((user.email ?? '').toLowerCase())) {
    const url = request.nextUrl.clone()
    url.pathname = '/unauthorized'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
