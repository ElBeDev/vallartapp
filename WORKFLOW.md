# VallartApp — Development Workflow

**Version:** 2.8
**Last Updated:** March 22, 2026
**Platform:** iOS 17+
**Language:** Swift / SwiftUI
**Primary Language:** English | **Secondary Language:** Spanish (es-MX)

---

## App Overview

VallartApp is a tourism discovery platform for **Puerto Vallarta and surrounding areas**
(Riviera Nayarit, Sayulita, Punta Mita, Bucerías, La Cruz, San Pancho, Yelapa).

**Business Model:** Yelp / TripAdvisor style
- Free for users — browse everything, read reviews, save favorites
- Paid plans for business owners — featured placement, analytics, unlimited photos, booking integration
- User Premium (future) — ad-free, exclusive deals, early event access

---

## Tech Stack

| Layer             | Technology                                      |
|-------------------|-------------------------------------------------|
| iOS App           | Swift / SwiftUI — Xcode 26.3                    |
| Backend / DB      | Supabase (PostgreSQL + Storage + Auth)          |
| Web Admin Portal  | Next.js 14 (App Router) + TypeScript            |
| Hosting           | Vercel (web portal)                             |
| Auth              | Supabase Auth (Magic Link, Apple, Google)       |
| Maps              | MapKit (native iOS)                             |
| Images            | Supabase Storage (public bucket "listings")     |
| Version Control   | GitHub — github.com/ElBeDev/vallartapp          |

---

## Project Structure

```
VallartApp/
├── VallartApp/                   iOS Swift app
│   ├── AppTheme.swift
│   ├── AuthService.swift
│   ├── Components.swift
│   ├── ContentView.swift
│   ├── EventRepository.swift
│   ├── EventsView.swift
│   ├── ExploreView.swift
│   ├── ListingDetailView.swift
│   ├── ListingRepository.swift
│   ├── MainTabView.swift
│   ├── MapExploreView.swift
│   ├── Models.swift
│   ├── ProfileView.swift
│   ├── SearchView.swift
│   ├── SupabaseService.swift
│   └── VallartAppApp.swift
├── src/                          Next.js admin portal
│   ├── app/
│   │   ├── (admin)/              Protected admin routes
│   │   │   ├── dashboard/
│   │   │   ├── listings/
│   │   │   ├── events/
│   │   │   ├── business-owners/
│   │   │   └── notifications/
│   │   ├── login/
│   │   └── auth/callback/
│   └── components/
│       ├── Sidebar.tsx
│       ├── ListingForm.tsx
│       └── EventForm.tsx
├── supabase/
│   └── seed.sql                  Full schema + seed data (source of truth)
├── scripts/
│   ├── seed.mjs                  Node script to seed DB via API
│   ├── fix_coordinates.mjs       Coordinate corrections
│   └── upload_images.mjs         Image upload to Supabase Storage
└── WORKFLOW.md
```

---

## Design System — AppTheme

### Color Palette
| Name          | Hex       | Usage                          |
|---------------|-----------|--------------------------------|
| coral         | #FF6B6B   | Primary CTA, highlights        |
| teal          | #2EC4B6   | Secondary accent, map pins     |
| sand          | #F7F3E3   | Background, cards              |
| deepNavy      | #1A2F4E   | Headers, primary text          |
| goldenSun     | #FFB347   | Stars, premium badges          |
| palmGreen     | #4CAF50   | Active/open status             |
| nightPurple   | #6C5CE7   | Nightlife category             |
| oceanBlue     | #0077B6   | Water activities, yachts       |

### Typography
- Display: SF Pro Rounded Bold — hero titles
- Headline: SF Pro Display Semibold — section headers
- Body: SF Pro Text Regular — descriptions
- Caption: SF Pro Text — metadata, tags

### Spacing System
- xs:4  sm:8  md:16  lg:24  xl:32  xxl:48

---

## Navigation Structure

```
MainTabView
├── Tab 1: Explore    — Home feed, featured carousel, categories grid, popular now
├── Tab 2: Map        — MapKit map with category pins, filter chips, preview cards
├── Tab 3: Events     — Public + private events, featured, calendar
├── Tab 4: Search     — Full-text search + filter sheet (category, neighborhood, price)
└── Tab 5: Profile    — User profile, saved listings, auth
```

---

## Supabase Schema

### Tables

**listings**
- id, name, category, neighborhood, address, latitude, longitude
- description, photos (text[]), rating, review_count, price_range (0-4)
- phone, website, instagram, tags (text[])
- is_premium, is_featured, is_open, open_hours, is_lgbt_friendly
- created_at

**events**
- id, title, description, neighborhood, address, latitude, longitude
- start_date, end_date, is_public, is_free, ticket_price, ticket_url
- photos, tags, organizer, instagram
- is_premium, is_featured, is_lgbt_friendly, is_recurring, recurrence_label
- created_at

**profiles** — linked to auth.users
**reviews** — linked to listings + users
**business_owners** — plan: free | standard | premium

### Row Level Security
- listings, events: public read (anon)
- reviews: public read, authenticated insert
- profiles: user can read/write own row only
- business_owners: user can read own row only

---

## Live Data in Supabase

### 56 Listings (real Puerto Vallarta businesses) — all with photos

| Category          | Count | Listings                                                                 |
|-------------------|-------|--------------------------------------------------------------------------|
| Restaurants       | 8     | Café des Artistes, Tuna Azul, La Palapa, Mar Y Vino, Barcelona Tapas, El Dorado, Café San Angel, Noroc |
| Bars & Nightlife  | 7     | Los Muertos Brewing, La Noche Bar, Mandala Nightclub, The Top Sky Bar, iK Mixology, Blue Chairs, Andale's |
| Hotels            | 7     | Garza Blanca, Casa Kimberly, W Punta de Mita, Hotel Mousai, Hacienda San Angel, Hilton Vallarta, Hotel Encanto |
| Activities        | 8     | Marietas Islands, Canopy River, Whale Watching, Sayulita Surf, Bioluminescence Tour, Horseback Riding, Los Arcos Snorkel, Butterfly Sanctuary |
| Yacht Rentals     | 5     | Sunset Sailing, Private Charter Marietas, Luxury Catamaran, Sport Fishing, Pirate Ship Marigalante |
| Car & Moto Rental | 5     | Vallarta Car Rental, Moto Rent PV, Budget, PV Golf Carts, Cycling PV    |
| Beaches           | 6     | Playa Los Muertos, Sayulita, Conchas Chinas, Mismaloya, Punta Mita, Bucerías |
| Shopping          | 5     | Mercado de Artesanías, Galería Dante, La Comer, Mundo de Cristal, Flea Market |
| Spas & Wellness   | 5     | Garza Blanca Spa, Spa Xinalani, Boca Spa, Temazcal Ritual, Casa de los Sueños |

### 6 Events (real / recurring)
- Vallarta Pride 2026 (Annual, LGBT+, Zona Romántica)
- Moonlight Jazz at the Marina (Monthly, private, ticketed)
- Sayulita Surf Competition (Annual, free)
- Gourmet Food & Wine Festival (Annual, November)
- Thursday Night Art Walk (Weekly, Centro)
- Sunset Beach Party — Blue Chairs (Daily, LGBT+)

### Images
- All 56 listings have real photos stored in Supabase Storage
- Bucket: `listings` (public)
- Photos sourced from: official business websites + Wikimedia Commons (CC licensed)
- iOS app uses AsyncImage with loading spinner + color category fallback
- Script: `node scripts/upload_images.mjs` — skips listings that already have Supabase photos

---

## iOS App — Current Status

### Completed
- MainTabView (5 tabs: Explore, Map, Events, Search, Profile)
- ExploreView — featured carousel (AsyncImage), category chips, popular grid
- MapExploreView — MapKit pins by category, filter chips, preview card with photo
- EventsView — featured + all events cards
- ListingDetailView — full photo hero, info, tags, map, directions (Apple Maps + Google Maps)
- SearchView — real-time search + filter sheet
- ProfileView — saved listings, auth state
- All data from Supabase (zero mock data)
- SupabaseService, ListingRepository, EventRepository
- AuthService — Magic Link + Apple Sign In
- No emojis anywhere — all icons use SF Symbols SVG
- Dark backgrounds with white text verified legible
- Coordinates verified against Google Maps for all listings
- Real photos from official business websites

### Known Issues / Next Up
- [ ] Images for most listings are category-level, not individual per business
- [ ] Reviews write flow needs end-to-end testing with a real auth session
- [ ] Dark mode not yet tested thoroughly

---

## Web Admin Portal — Current Status

### Completed
- Next.js 14 app with App Router
- Login page with Supabase Auth (Magic Link)
- Protected admin routes via middleware
- Dashboard — overview stats
- Listings section — list, view, new, edit (with form)
- Events section — list, view, new, edit (with form)
- Business Owners section
- Notifications section
- Sidebar navigation
- Deployed on Vercel — connected to GitHub (auto-deploy on push)

### Known Issues / Next Up
- [ ] Dashboard stats need real queries (currently static)
- [ ] Image upload UI in listing form (currently URL input only)
- [ ] Role-based access — distinguish super admin vs business owner

---

## Business Owner Subscription Tiers

| Tier             | Price       | Features                                                            |
|------------------|-------------|---------------------------------------------------------------------|
| Free             | $0/mo       | Basic listing, 3 photos, reviews visible                            |
| Standard         | $29/mo      | Unlimited photos, reply to reviews, contact button, analytics, verified badge |
| Premium          | $79/mo      | Everything Standard + featured placement, golden map pin, Editor's Picks, booking widget |
| Standard Yearly  | $249/yr     | Same as Standard — save 30%                                        |
| Premium Yearly   | $699/yr     | Same as Premium — save 30%                                         |

## User Explorer Subscription

| Tier             | Price       | Features                                                            |
|------------------|-------------|---------------------------------------------------------------------|
| Explorer         | $4.99/mo    | Ad-free, early event access, partner discounts, advanced filters, offline maps |
| Explorer Yearly  | $39.99/yr   | Same — save 33%                                                     |

---

## Development Roadmap

### Done
- iOS app core — all 5 tabs functional
- Supabase backend — schema, RLS, real data
- Admin web portal (Next.js + Vercel)
- 56 real business listings + 6 events, 5+ per category ✅
- Individual real photos for all 56 listings + 6 events (Supabase Storage, each UUID-named) ✅
- Map with verified coordinates
- Directions (Apple Maps + Google Maps + Waze)
- Zero mock data — 100% live Supabase
- No emojis — SF Symbols only
- Contrast/legibility fixes on all badges
- Saved listings wired to Supabase — persists between sessions ✅
- Write a Review flow in ListingDetailView ✅
- User profile — avatar upload + edit name ✅
- Spanish localization (en.lproj + es.lproj Localizable.strings) ✅
- Dynamic time-based greeting (morning/afternoon/evening) ✅
- EventDetailView hero — real photo from Supabase Storage ✅
- Admin dashboard — category breakdown table with progress bars ✅
- My Reviews — full list from Supabase, real count in stats, swipe-to-delete ✅
- Stripe integration: PremiumView paywall, StripeService, native PaymentSheet ✅
- Stripe SPM resolved (stripe-ios 24.25.0) ✅
- Supabase profiles: is_premium, premium_tier, premium_started_at columns added ✅
- Edge Function `create-payment-intent` deployed & verified live ✅ (returns real Stripe clientSecret)
- STRIPE_SECRET_KEY set in Supabase project secrets ✅
- Dual paywall: UserPaywallView (Explorer $4.99) + BusinessPaywallView (Standard $29 / Premium $79) ✅
- BusinessTier + UserTier enums replacing PremiumTier ✅
- business_owners table updated with plan/is_active/plan_started_at columns + RLS policies ✅
- ProfileView: Explorer teal badge, "Upgrade to Explorer" prompt, My Business → business paywall ✅
- Edge Function updated with all 6 tier prices ✅

### Stripe — FULLY OPERATIONAL (test mode)
- Edge Function: https://nvubaobivraevlnlpsjr.supabase.co/functions/v1/create-payment-intent
- Test card: 4242 4242 4242 4242 / any future date / any CVC
- Swap pk_test_ → pk_live_ and sk_test_ → sk_live_ before App Store

- Business Owner self-serve portal — fully functional ✅
  - `/business/login` — dark themed login page (magic link)
  - `/business/dashboard` — listing stats, photo preview, recent reviews, upgrade banner
  - `/business/my-listing` — edit description, phone, website, Instagram, hours, address
  - `/business/photos` — drag-to-reorder, upload new photos (3/20/50 limit by plan), delete
  - `/business/reviews` — star distribution chart, full review list, reply (Standard+)
  - `/business/analytics` — listing health checklist, plan-gated detailed analytics
  - Middleware: `/business/*` routes separated from admin, checks `business_owners` table
  - Plan limits enforced: Free=3 photos, Standard=20, Premium=50

### Next Sprint — Priority
- [ ] Link business_owners.listing_id in DB for existing owners (admin tool or SQL)
- [ ] Push notifications (Supabase Edge Functions + APNs)
- [ ] Offline cache (SwiftData)
- [ ] App Store submission prep (icons, screenshots, metadata)
- [ ] Deep links (Universal Links)
- [ ] USD / MXN price toggle in listings

---

## Environments & Keys

All secrets stored as environment variables — never hardcoded in source.

| Variable              | Used In                        |
|-----------------------|--------------------------------|
| SUPABASE_URL          | iOS app, scripts, Next.js      |
| SUPABASE_SERVICE_KEY  | Scripts only (server-side)     |
| NEXT_PUBLIC_SUPABASE_URL | Next.js portal              |
| NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY | Next.js portal |

iOS uses: `SupabaseService.swift` — keys set in `Info.plist` or inline constants.

---

## Scripts

Run from project root. Require env vars set first:
```bash
export SUPABASE_URL=https://nvubaobivraevlnlpsjr.supabase.co
export SUPABASE_SERVICE_KEY=your_service_key_here
```

| Script                        | What it does                                  |
|-------------------------------|-----------------------------------------------|
| `node scripts/seed.mjs`       | Clears and re-seeds all listings + events     |
| `node scripts/fix_coordinates.mjs` | Corrects coordinates for specific listings |
| `node scripts/upload_images.mjs`   | Downloads + uploads real photos to Storage |

---

## Geographic Coverage

| Area                  | Neighborhoods in DB                        |
|-----------------------|--------------------------------------------|
| Puerto Vallarta       | Centro, Zona Romántica, Marina, Hotel Zone |
| Riviera Nayarit       | Nuevo Vallarta, Bucerías, La Cruz          |
| North Nayarit         | Punta Mita, Sayulita, San Pancho           |
| Remote                | Yelapa                                     |

Map default center: lat 20.6534, lng -105.2253

---

## Notes

- Puerto Vallarta is LGBT+ friendly — Zona Romántica nightlife has dedicated LGBT+ badge/filter
- Whale watching is seasonal (November–March) — listings support seasonal availability
- Sayulita has strong surf culture — tagged within Activities
- All prices displayed in MXN by default (USD toggle planned)
- No emojis in the app — SF Symbols only
- Category filter values in DB must EXACTLY match Swift enum rawValues (case sensitive)
