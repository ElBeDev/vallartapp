// Supabase Edge Function: send-push-notification
// Sends APNs push notifications to iOS devices via HTTP/2 JWT auth.
// Called by: admin portal (broadcast) or server-side triggers.
//
// Required Supabase secrets:
//   APNS_KEY_ID       — 10-char key ID from Apple Developer
//   APNS_TEAM_ID      — 10-char Apple Team ID
//   APNS_PRIVATE_KEY  — contents of .p8 file (the private key, PEM format)
//   APNS_BUNDLE_ID    — e.g. com.yourname.VallartApp

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const APNS_KEY_ID    = Deno.env.get("APNS_KEY_ID")    ?? ""
const APNS_TEAM_ID   = Deno.env.get("APNS_TEAM_ID")   ?? ""
const APNS_PRIVATE_KEY = Deno.env.get("APNS_PRIVATE_KEY") ?? ""
const APNS_BUNDLE_ID = Deno.env.get("APNS_BUNDLE_ID") ?? "com.vallartapp.VallartApp"
const SUPABASE_URL   = Deno.env.get("SUPABASE_URL")    ?? ""
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""

// APNs endpoints
const APNS_HOST_PROD = "https://api.push.apple.com"
const APNS_HOST_DEV  = "https://api.sandbox.push.apple.com"

interface PushPayload {
  title: string
  body: string
  type?: string                  // "new_event" | "promo" | "review" | "broadcast"
  userIds?: string[]             // specific users; omit = broadcast to all
  listingId?: string
  eventId?: string
  sandbox?: boolean              // true = use APNs sandbox (development builds)
  saveToInbox?: boolean          // true (default) = save to notifications table
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    })
  }

  // Verify caller is authenticated (admin only via service key header)
  const authHeader = req.headers.get("Authorization") ?? ""
  if (!authHeader.includes(SUPABASE_SERVICE_KEY) && !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 })
  }

  try {
    const payload: PushPayload = await req.json()
    const { title, body, type = "broadcast", userIds, listingId, eventId, sandbox = false, saveToInbox = true } = payload

    if (!title || !body) {
      return new Response(JSON.stringify({ error: "title and body required" }), { status: 400 })
    }

    const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

    // 1. Fetch target device tokens
    let tokenQuery = sb.from("device_tokens").select("user_id, token")
    if (userIds && userIds.length > 0) {
      tokenQuery = tokenQuery.in("user_id", userIds)
    }
    const { data: tokens, error: tokenErr } = await tokenQuery
    if (tokenErr) throw tokenErr

    if (!tokens || tokens.length === 0) {
      return new Response(JSON.stringify({ sent: 0, message: "No tokens found" }), { status: 200 })
    }

    // 2. Generate APNs JWT
    const jwtToken = await generateApnsJwt()

    // 3. Send push to each token
    const apnsHost = sandbox ? APNS_HOST_DEV : APNS_HOST_PROD
    let sent = 0
    let failed = 0

    for (const { token } of tokens) {
      const success = await sendApnsPush(apnsHost, token, jwtToken, {
        aps: {
          alert: { title, body },
          badge: 1,
          sound: "default",
        },
        listing_id: listingId,
        event_id:   eventId,
        type,
      })
      if (success) sent++ ; else failed++
    }

    // 4. Save notification to inbox table (if requested)
    if (saveToInbox) {
      if (userIds && userIds.length > 0) {
        // Individual notifications
        const rows = userIds.map(uid => ({
          user_id:    uid,
          title,
          body,
          type,
          listing_id: listingId ?? null,
          event_id:   eventId   ?? null,
          is_read:    false,
        }))
        await sb.from("notifications").insert(rows)
      } else {
        // Broadcast (user_id NULL = everyone sees it)
        await sb.from("notifications").insert({
          user_id:    null,
          title,
          body,
          type,
          listing_id: listingId ?? null,
          event_id:   eventId   ?? null,
          is_read:    false,
        })
      }
    }

    return new Response(JSON.stringify({ sent, failed, tokens: tokens.length }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })
  } catch (err) {
    console.error("send-push-notification error:", err)
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})

// ── APNs JWT generation ──────────────────────────────────────
async function generateApnsJwt(): Promise<string> {
  const header  = base64url(JSON.stringify({ alg: "ES256", kid: APNS_KEY_ID }))
  const now     = Math.floor(Date.now() / 1000)
  const claims  = base64url(JSON.stringify({ iss: APNS_TEAM_ID, iat: now }))
  const message = `${header}.${claims}`

  // Import the ES256 private key (.p8 PEM format)
  const pemBody = APNS_PRIVATE_KEY
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "")
  const keyData = Uint8Array.from(atob(pemBody), c => c.charCodeAt(0))

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData.buffer,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"]
  )

  const encoder  = new TextEncoder()
  const sigBuffer = await crypto.subtle.sign(
    { name: "ECDSA", hash: { name: "SHA-256" } },
    cryptoKey,
    encoder.encode(message)
  )

  const sig = base64url(sigBuffer)
  return `${message}.${sig}`
}

function base64url(input: string | ArrayBuffer): string {
  const bytes = typeof input === "string"
    ? new TextEncoder().encode(input)
    : new Uint8Array(input)
  let str = ""
  for (const byte of bytes) str += String.fromCharCode(byte)
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "")
}

// ── Send single APNs push ─────────────────────────────────────
async function sendApnsPush(
  host: string,
  deviceToken: string,
  jwt: string,
  payload: Record<string, unknown>
): Promise<boolean> {
  try {
    const res = await fetch(`${host}/3/device/${deviceToken}`, {
      method: "POST",
      headers: {
        "authorization":  `bearer ${jwt}`,
        "apns-push-type": "alert",
        "apns-topic":     APNS_BUNDLE_ID,
        "apns-priority":  "10",
        "content-type":   "application/json",
      },
      body: JSON.stringify(payload),
    })
    if (!res.ok) {
      const err = await res.json().catch(() => ({}))
      console.warn("APNs error for token", deviceToken.slice(0, 8), ":", err)
    }
    return res.ok
  } catch (e) {
    console.error("APNs fetch error:", e)
    return false
  }
}
