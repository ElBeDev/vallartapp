e# VallartApp — Development Workflow

**Version:** 3.5
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

### 275 Listings + 35 Events — ALL CATEGORIES COMPLETE

| Category          | Count | Notes                                                                 |
|-------------------|-------|-----------------------------------------------------------------------|
| Activities        | 52    | Water, land, air, culture, golf, wellness, ecotourism — all zones    |
| Restaurants       | 50    | Centro, Zona Romántica, Marina, Hotel Zone, NV, Bucerías, Punta Mita |
| Bars & Nightlife  | 33    | LGBT+, rooftop, beachfront, craft beer, clubs — all zones            |
| Hotels            | 31    | Budget hostels → 5-star resorts, all zones incl. Punta Mita          |
| Beaches           | 24    | PV city + southern coves + Nayarit — incl. boat-only & secret beaches|
| Shopping          | 24    | Art galleries, artisan markets, jewelry, tequila, malls, boutiques   |
| Spas & Wellness   | 22    | Resort spas, day spas, yoga, temazcal, float tanks, ayurveda         |
| Yacht Rentals     | 20    | Private charters, catamarans, sport fishing, party boats, pangas     |
| Car & Moto Rental | 19    | Cars, Jeeps, motos, scooters, ATVs, e-bikes, golf carts, vans        |
| **TOTAL**         | **275** | Zero mock data — all real Puerto Vallarta & Riviera Nayarit          |

### 35 Events — Full Calendar Coverage
| Type                  | Count | Examples                                                        |
|-----------------------|-------|-----------------------------------------------------------------|
| Weekly recurring      | 5     | Art Walk (Wed), Organic Market (Sat), Jazz (Fri), Drum Circle (Sun), Trivia (Tue) |
| LGBT+                 | 4     | Vallarta Pride Parade (May), Pride Opening, Blue Chairs Drag Brunch (Sun), La Noche (nightly) |
| Annual festivals      | 8     | Gourmet Festival (Nov), Beer Festival (Jun), Film Festival (Nov), Tequila Festival (Oct), Virgen de Guadalupe (Dec), Día de Muertos, Punta Mita Festival, Sayulita Día de Muertos |
| Sport events          | 4     | Marathon (Jan), Regatta (Jul), Surf Classic Sayulita (Nov), Fishing Grand Slam (Jan) |
| Nightlife / Shows     | 4     | Rhythms of the Night, Palm Cabaret, Incanto Jazz, Mandala EDM  |
| Nature / Seasonal     | 3     | Whale Season Opening (Dec), Sea Turtles (Jul), Full Moon Party (monthly) |
| Wellness              | 1     | Garza Blanca 3-day Retreat                                      |
| Holiday               | 2     | Mandala NYE 2027, Summer Solstice Sailing                       |
| Food                  | 2     | Gourmet Night Market, Chefs Table Café des Artistes             |
| **TOTAL**             | **35** | 29 of 35 are recurring (weekly/monthly/annual)                 |

### Category ↔ DB Value Mapping (must match Swift enum exactly)
| Display Name      | DB `category` value   | Swift enum case  |
|-------------------|-----------------------|------------------|
| Restaurants       | `Restaurants`         | `.restaurants`   |
| Bars & Nightlife  | `Bars & Nightlife`    | `.bars`          |
| Hotels            | `Hotels`              | `.hotels`        |
| Activities        | `Activities`          | `.activities`    |
| Yacht Rentals     | `Yacht Rentals`       | `.yachts`        |
| Car & Moto Rental | `Car & Moto Rental`   | `.rentals`       |
| Beaches           | `Beaches`             | `.beaches`       |
| Shopping          | `Shopping`            | `.shopping`      |
| Spas & Wellness   | `Spas & Wellness`     | `.spas`          |

### Neighborhood ↔ DB Value Mapping (must match Swift enum rawValue exactly)
| Display Name    | DB `neighborhood` value | Swift enum case    |
|-----------------|-------------------------|--------------------|
| Centro          | `centro`                | `.centro`          |
| Zona Romántica  | `zonaRomantica`         | `.zonaRomantica`   |
| Marina Vallarta | `marina`                | `.marina`          |
| Hotel Zone      | `hotelZone`             | `.hotelZone`       |
| Nuevo Vallarta  | `nuevaVallarta`         | `.nuevaVallarta`   |
| Bucerías        | `bucerías`              | `.bucerías`        |
| Punta Mita      | `puntaMita`             | `.puntaMita`       |
| Sayulita        | `sayulita`              | `.sayulita`        |
| Mismaloya       | `mismaloya`             | `.mismaloya`       |
| La Cruz         | `laCruz`                | `.laCruz`          |
| San Pancho      | `sanPancho`             | `.sanPancho`       |
| Yelapa          | `yelapa`                | `.yelapa`          |

> NOTE: Neighborhood enum rawValues are camelCase (matching DB). `displayName` computed property
> returns human-readable strings. All views use `.displayName` not `.rawValue` for display.

### Seed Scripts (reference — data already live in DB)
| Script                        | What it seeds                              |
|-------------------------------|--------------------------------------------|
| `scripts/seed_restaurants.mjs`| 50 restaurants                             |
| `scripts/seed_bars.mjs`       | 33 bars & nightlife                        |
| `scripts/seed_hotels.mjs`     | 31 hotels                                  |
| `scripts/seed_activities.mjs` | 52 activities                              |
| `scripts/seed_yachts.mjs`     | 20 yacht rentals                           |
| `scripts/seed_vehicles.mjs`   | 19 car & moto rentals                      |
| `scripts/seed_beaches.mjs`    | 24 beaches                                 |
| `scripts/seed_shopping.mjs`   | 24 shopping                                |
| `scripts/seed_spas.mjs`       | 22 spas & wellness                         |
| `scripts/seed_events.mjs`     | 35 events                                  |

### Images
- Every listing and event has Unsplash photos matched to specific venue/type
- Photo types are specific per venue: e.g. rooftop bar ≠ beach bar ≠ craft beer bar
- No placeholder or generic category images — each listing has its own photo(s)
- iOS app uses AsyncImage with loading spinner + color category fallback

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
- No emojis anywhere — all icons use SF Symbols
- Dark backgrounds with white text verified legible
- Coordinates verified against Google Maps for all listings
- Real photos specific to each venue type (Unsplash, matched per listing)
- Neighborhood enum: rawValues = camelCase matching DB exactly
- `displayName` computed property on Neighborhood for human-readable UI strings
- All views use `.displayName` instead of `.rawValue` for neighborhood display
- `mismaloya` added as a Neighborhood case

### Known Issues / Next Up
- [ ] Reviews write flow — end-to-end testing with real auth session
- [ ] Dark mode thoroughness pass
- [ ] Offline cache (SwiftData)
- [ ] App Store submission prep (icons, screenshots, metadata)

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
- Edge Function `create-payment-intent` deployed & verified live ✅
- STRIPE_SECRET_KEY set in Supabase project secrets ✅
- Dual paywall: UserPaywallView (Explorer $4.99) + BusinessPaywallView (Standard $29 / Premium $79) ✅
- BusinessTier + UserTier enums replacing PremiumTier ✅
- business_owners table + RLS policies ✅
- ProfileView: Explorer teal badge, "Upgrade to Explorer" prompt ✅
- Edge Function updated with all 6 tier prices ✅
- Business Owner self-serve portal ✅ (`/business/*` routes)
- Push Notifications fully wired ✅ (APNs, Edge Function, NotificationsView, device_tokens table)
- Admin portal Notifications compose UI ✅

- **FULL DB CONTENT COMPLETE (March 22, 2026)** ✅
  - 275 real listings across all 9 categories — zero mock data
  - 35 real events with full calendar coverage (Apr 2026 → Jan 2027)
  - Every listing has venue-specific photos (not generic category images)
  - All categories fully populated:
    - Restaurants: 50 (was 8)
    - Bars & Nightlife: 33 (was 7)
    - Hotels: 31 (was 7)
    - Activities: 52 (was 8) — 30 activity types, all zones
    - Yacht Rentals: 20 (was 5) — motor yachts, catamarans, fishing, party boats
    - Car & Moto Rental: 19 (was 5) — cars, motos, ATVs, e-bikes, vans
    - Beaches: 24 (was 6) — incl. boat-only, surf, snorkel, hidden gems
    - Shopping: 24 (was 5) — art galleries, markets, jewelry, tequila, malls
    - Spas & Wellness: 22 (was 5) — resort spas, yoga, temazcal, float tanks
    - Events: 35 (was 6) — weekly, monthly, annual, sports, nightlife, cultural

- **DB DATA INTEGRITY FIX (March 22, 2026)** ✅
  - Fixed `restaurants` → `Restaurants` category (42 rows were lowercase, only 8 showing in app)
  - Normalized ALL neighborhood values to camelCase matching Swift enum rawValues
    - `Centro` → `centro`, `Zona Romántica` → `zonaRomantica`, `Marina` → `marina`, etc.
    - Applied to both `listings` and `events` tables
  - Swift `Neighborhood` enum: rawValues changed to camelCase to match DB
  - Added `mismaloya` case to `Neighborhood` enum
  - Added `displayName` computed property to `Neighborhood` for human-readable UI
  - All views updated: `neighborhood.rawValue` → `neighborhood.displayName`
    (Components.swift, MapExploreView, ListingDetailView, EventsView, SearchView)
  - Build: clean, 0 errors, 2 warnings (both pre-existing, non-blocking)

### Stripe — FULLY OPERATIONAL (test mode)
- Edge Function: `https://nvubaobivraevlnlpsjr.supabase.co/functions/v1/create-payment-intent`
- Test card: 4242 4242 4242 4242 / any future date / any CVC
- Swap `pk_test_` → `pk_live_` and `sk_test_` → `sk_live_` before App Store submission

### Business Owner Self-Serve Portal — fully functional ✅
- `/business/login` — dark themed login page (magic link)
- `/business/dashboard` — listing stats, photo preview, recent reviews, upgrade banner
- `/business/my-listing` — edit description, phone, website, Instagram, hours, address
- `/business/photos` — drag-to-reorder, upload new photos (3/20/50 limit by plan), delete
- `/business/reviews` — star distribution chart, full review list, reply (Standard+)
- `/business/analytics` — listing health checklist, plan-gated detailed analytics
- Middleware: `/business/*` routes separated from admin, checks `business_owners` table
- Plan limits enforced: Free=3 photos, Standard=20, Premium=50

### Push Notifications — fully wired ✅
- `PushNotificationService.swift` — permission request, APNs token save to Supabase, inbox load, mark read
- `AppDelegate` in `VallartAppApp.swift` — `didRegisterForRemoteNotifications` → saves token
- `NotificationsView` — Tab 3 (bell icon), unread badge count, permission banner, mark all read, pull to refresh
- DB: `device_tokens` table + `notifications` table (RLS, indexes) in Supabase ✅
- Edge Function `send-push-notification` deployed ✅ — APNs JWT auth, broadcast + targeted, saves to inbox
- Admin portal Notifications page — compose UI, type selector, preview, sandbox toggle, send history

### APNs — Secrets Needed to Send Real Pushes
Add in Supabase Dashboard → Edge Functions → Secrets:
- `APNS_KEY_ID` — 10-char key ID from Apple Developer portal
- `APNS_TEAM_ID` — 10-char Team ID
- `APNS_PRIVATE_KEY` — contents of the .p8 auth key file
- `APNS_BUNDLE_ID` — your app bundle ID (e.g. `com.yourname.VallartApp`)
- `SUPABASE_SERVICE_ROLE_KEY` — service role key (already available as Supabase built-in)

### Next Sprint — Priority
- [ ] APNs keys setup (Apple Developer portal → Keys → APNs)
- [ ] Link `business_owners.listing_id` in DB for existing owners (admin tool)
- [ ] Offline cache (SwiftData)
- [ ] App Store submission prep (icons, screenshots, metadata)
- [ ] Deep links (Universal Links)
- [ ] Dashboard stats — wire to real Supabase queries (currently static)
- [ ] Image upload UI in listing/event forms (currently URL input only)
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
m
