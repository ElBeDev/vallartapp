// Supabase Edge Function: create-payment-intent
// Called by the iOS app to create a Stripe PaymentIntent server-side.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY") ?? ""

// All tier prices in cents (USD)
// Business Owner tiers
// User Explorer tiers
const TIER_PRICES: Record<string, number> = {
  // Business owner plans
  biz_standard:        2900,   // $29/mo
  biz_premium:         7900,   // $79/mo
  biz_standard_yearly: 24900,  // $249/yr (save 30%)
  biz_premium_yearly:  69900,  // $699/yr (save 30%)
  // User explorer plans
  user_explorer:        499,   // $4.99/mo
  user_explorer_yearly: 3999,  // $39.99/yr (save 33%)
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

  try {
    const { tier, userID } = await req.json() as { tier: string; userID: string }

    const amount = TIER_PRICES[tier]
    if (!amount) {
      return new Response(JSON.stringify({ error: "Invalid tier: " + tier }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      })
    }

    const body = new URLSearchParams({
      amount: String(amount),
      currency: "usd",
      "automatic_payment_methods[enabled]": "true",
      "metadata[user_id]": userID,
      "metadata[tier]": tier,
    })

    const stripeRes = await fetch("https://api.stripe.com/v1/payment_intents", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body.toString(),
    })

    const intent = await stripeRes.json()

    if (!stripeRes.ok) {
      return new Response(JSON.stringify({ error: intent.error?.message ?? "Stripe error" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      })
    }

    return new Response(
      JSON.stringify({
        clientSecret:    intent.client_secret,
        paymentIntentID: intent.id,
        amount,
        currency: "usd",
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
})
