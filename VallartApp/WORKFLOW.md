# VallartApp — Development Workflow

**Version:** 1.8  
**Last Updated:** March 14, 2026  
**Platform:** iOS 17+ / macOS (builds clean on both)  
**Language:** Swift / SwiftUI  
**Primary Language:** English | **Secondary:** Spanish (es-MX)  
**Bundle ID:** t4e.VallartApp

---

## 🧭 App Concept

Tourism discovery platform for **Puerto Vallarta & Riviera Nayarit**, Mexico.  
Think Yelp + TripAdvisor but laser-focused on PV and surrounding areas.

**Business Model:**
- ✅ **Free for users** — browse, search, save, review everything
- 💼 **Paid plans for business owners** — featured placement, analytics, unlimited photos, booking CTA
- 🌟 **User Premium (future)** — ad-free experience, exclusive deals, early event access

---

## 📁 iOS Project File Structure

```
VallartApp/
├── VallartApp/
│   ├── WORKFLOW.md                    ✅ This file
│   ├── VallartAppApp.swift            ✅ App entry point + .onOpenURL deep link handler
│   ├── ContentView.swift              ✅ Loads MainTabView
│   ├── AppTheme.swift                 ✅ Colors, fonts, spacing, radius + cross-platform View shims
│   ├── Models.swift                   ✅ Listing, Event, Review, AppUser, enums (with default values)
│   ├── MockDataService.swift          ✅ All sample PV data (20+ listings, 6 events) — fallback
│   ├── MainTabView.swift              ✅ 5-tab navigation shell
│   ├── ExploreView.swift              ✅ Home feed + ExploreViewModel (Supabase-backed)
│   ├── EventsView.swift               ✅ Events list + EventDetailView + EventsViewModel
│   ├── MapExploreView.swift           ✅ MapKit map + pins + MapViewModel
│   ├── SearchView.swift               ✅ Search + filters + FilterSheetView + SearchViewModel (debounced)
│   ├── ListingDetailView.swift        ✅ Detail view + CategoryListView + real reviews
│   ├── ProfileView.swift              ✅ Profile + LoginView (wired to AuthService)
│   ├── Components.swift               ✅ All reusable UI components
│   ├── SupabaseService.swift          ✅ Supabase client singleton (publishable key)
│   ├── AuthService.swift              ✅ Apple / Google / Email / Magic Link — full auth flow
│   ├── ListingRepository.swift        ✅ Protocol + SupabaseListingRepository + MockFallback
│   └── EventRepository.swift         ✅ Protocol + SupabaseEventRepository + MockFallback
└── VallartApp.xcodeproj/
    └── project.xcworkspace/xcshareddata/swiftpm/
        └── Package.resolved           ✅ supabase-swift v2.41.1 pinned
```

**Total: 17 Swift files — all registered in project.pbxproj ✅**

---

## 📁 Admin Portal File Structure

```
/Users/bener/IOSApps/vallartapp-admin/         ← separate project, NOT inside Xcode
├── .env.local                                  ✅ Supabase keys (never commit)
├── .env.example                                ✅ Template for other devs
├── src/
│   ├── middleware.ts                           ✅ Auth guard — redirects to /login if not signed in
│   ├── app/
│   │   ├── layout.tsx                          ✅ Root layout + Toaster
│   │   ├── page.tsx                            ✅ Redirects / → /dashboard
│   │   ├── login/page.tsx                      ✅ Password + Magic Link login (60s cooldown)
│   │   ├── unauthorized/page.tsx               ✅ Access denied page (no more redirect loops)
│   │   ├── auth/callback/route.ts              ✅ Supabase OAuth + magic link callback
│   │   └── (admin)/                            ← Protected admin route group
│   │       ├── layout.tsx                      ✅ Admin shell with sidebar
│   │       ├── dashboard/page.tsx              ✅ Stats: listings, events, reviews, featured
│   │       ├── listings/page.tsx               ✅ All listings table with status badges
│   │       ├── listings/new/page.tsx           ✅ Add listing form
│   │       ├── listings/[id]/page.tsx          ✅ Edit listing form
│   │       ├── events/page.tsx                 ✅ All events table
│   │       ├── events/new/page.tsx             ✅ Add event form
│   │       ├── events/[id]/page.tsx            ✅ Edit event form
│   │       ├── business-owners/page.tsx        ✅ Business owners table
│   │       └── notifications/page.tsx          ✅ Placeholder — Phase 3
│   ├── components/
│   │   ├── Sidebar.tsx                         ✅ Responsive sidebar (mobile drawer + desktop)
│   │   ├── ListingForm.tsx                     ✅ Full form: photos, coords, tags, flags, toggles
│   │   └── EventForm.tsx                       ✅ Full form: dates, tickets, recurrence, flags
│   └── lib/supabase/
│       ├── client.ts                           ✅ Browser Supabase client
│       └── server.ts                           ✅ Server + service-role admin client
└── package.json                                ✅ Next.js 14, shadcn/ui, Tailwind, react-dropzone
```

### Running locally
```bash
cd /Users/bener/IOSApps/vallartapp-admin
npm run dev        # → http://localhost:3000
```

### Deploying to Vercel
```bash
cd /Users/bener/IOSApps/vallartapp-admin
npx vercel
# Add these env vars in the Vercel dashboard:
# NEXT_PUBLIC_SUPABASE_URL
# NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
# SUPABASE_SERVICE_ROLE_KEY
# ADMIN_EMAILS  (leave empty = any logged-in user; or set to your@email.com)
```

---

## 🎨 Design System

### Color Palette
| Token           | Hex       | Usage                            |
|-----------------|-----------|----------------------------------|
| `coral`         | #FF6B6B   | Primary CTA, restaurants, events |
| `teal`          | #2EC4B6   | Secondary accent, activities     |
| `sand`          | #F7F3E3   | App background                   |
| `deepNavy`      | #1A2F4E   | Headers, primary text            |
| `goldenSun`     | #FFB347   | Stars, premium badges            |
| `palmGreen`     | #4CAF50   | Open status, spas                |
| `nightPurple`   | #6C5CE7   | Nightlife / bars                 |
| `oceanBlue`     | #0077B6   | Yachts, water activities         |
| `lightGray`     | #F2F2F7   | Subtle backgrounds               |
| `mediumGray`    | #8E8E93   | Secondary text, placeholders     |
| `white`         | #FFFFFF   | Cards, button backgrounds        |

### Spacing Scale
`xs=4 · sm=8 · md=16 · lg=24 · xl=32 · xxl=48`

### Corner Radius
`sm=8 · md=12 · lg=16 · xl=24 · full=999`

### Cross-platform Shims (AppTheme.swift)
iOS-only APIs wrapped so both iOS + macOS build clean:
- `.navTitleMode(.large / .inline)` → wraps `.navigationBarTitleDisplayMode`
- `.inputAutocap(.words / .never)` → wraps `.textInputAutocapitalization`
- `.iOSKeyboard(.emailAddress)` → wraps `.keyboardType`
- `.navBarHidden(bool)` → wraps `.navigationBarHidden`

---

## 📦 Categories (10 total)

| #  | Name              | SF Symbol          | Color        |
|----|-------------------|--------------------|--------------|
| 1  | Restaurants       | fork.knife         | coral        |
| 2  | Bars & Nightlife  | music.note         | nightPurple  |
| 3  | Hotels            | bed.double.fill    | deepNavy     |
| 4  | Activities        | figure.surfing     | teal         |
| 5  | Yacht Rentals     | sailboat.fill      | oceanBlue    |
| 6  | Car & Moto Rental | car.fill           | goldenSun    |
| 7  | Events            | calendar           | coral        |
| 8  | Beaches           | sun.max.fill       | teal         |
| 9  | Shopping          | bag.fill           | deepNavy     |
| 10 | Spas & Wellness   | leaf.fill          | palmGreen    |

---

## 🗺️ Geographic Coverage

- Puerto Vallarta (Centro, Zona Romántica, Marina, Hotel Zone)
- Nuevo Vallarta / Riviera Nayarit
- Bucerías · La Cruz de Huanacaxtle · Punta Mita
- Sayulita ⭐ · San Pancho · Yelapa

**Map center:** `lat: 20.6534, lng: -105.2253`

---

## 📱 Navigation

```
MainTabView
├── Tab 1 — Explore      (safari.fill)       Featured carousel, category chips, popular list
├── Tab 2 — Map          (map.fill)           MapKit pins by category, bottom preview card
├── Tab 3 — Events       (calendar)           Filter: All / Free / This Week / Public / LGBT+
├── Tab 4 — Search       (magnifyingglass)    Full-text + filter sheet (category, hood, open, lgbt)
└── Tab 5 — Profile      (person.fill)        Guest CTA / logged-in dashboard
```

---

## 🏗️ Architecture

- **Pattern:** MVVM
- **State:** `@StateObject` / `@ObservableObject` / `@Published`
- **Navigation:** `NavigationStack` + `TabView`
- **Data:** Repository pattern — `ListingRepositoryProtocol` / `EventRepositoryProtocol`
  - Supabase implementation used by default
  - Mock implementation auto-fallback if Supabase unreachable
- **Auth:** `AuthService.shared` — singleton `@MainActor ObservableObject`
- **Maps:** MapKit (native)
- **Images:** `AsyncImage` with Supabase Storage URLs
- **Search:** Debounced 350ms → PostgreSQL full-text search
- **Payments:** RevenueCat + StoreKit 2 (Phase 3)
- **Push Notifications:** Supabase Edge Functions + APNs (Phase 3)

---

## 🗄️ Supabase Database Schema

Run this in **supabase.com → your project → SQL Editor**:

```sql
create table listings (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  category         text not null,
  neighborhood     text not null,
  address          text,
  latitude         float8,
  longitude        float8,
  description      text,
  photos           text[],
  rating           float4 default 0,
  review_count     int default 0,
  price_range      int default 2,
  phone            text,
  website          text,
  instagram        text,
  tags             text[],
  is_premium       boolean default false,
  is_featured      boolean default false,
  is_open          boolean default true,
  open_hours       text,
  is_lgbt_friendly boolean default false,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create table events (
  id               uuid primary key default gen_random_uuid(),
  title            text not null,
  description      text,
  neighborhood     text,
  address          text,
  latitude         float8,
  longitude        float8,
  start_date       timestamptz,
  end_date         timestamptz,
  is_public        boolean default true,
  is_free          boolean default true,
  ticket_price     float4,
  ticket_url       text,
  photos           text[],
  tags             text[],
  organizer        text,
  phone            text,
  instagram        text,
  is_premium       boolean default false,
  is_featured      boolean default false,
  is_lgbt_friendly boolean default false,
  is_recurring     boolean default false,
  recurrence_label text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create table reviews (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid references listings(id) on delete cascade,
  user_id     uuid references auth.users(id),
  author_name text,
  rating      float4,
  text        text,
  photos      text[],
  created_at  timestamptz default now()
);

create table profiles (
  id                uuid primary key references auth.users(id),
  name              text,
  avatar_url        text,
  is_business_owner boolean default false,
  saved_listing_ids uuid[],
  joined_at         timestamptz default now()
);

create table business_owners (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid references auth.users(id),
  listing_ids         uuid[],
  subscription_tier   text default 'free',
  subscription_status text default 'active',
  verified_at         timestamptz
);
```

**Storage:** Create a bucket called `photos` in Supabase → Storage, set to **public**.

### Row Level Security
- **Anyone** — read all listings, events
- **Logged-in users** — write reviews, manage saved list
- **Business owners** — read/write only their own listings
- **Admin portal** — `service_role` key server-side only (never in iOS app)

---

## 💼 Business Owner Subscription Tiers (Phase 3)

| Tier         | Price   | Features                                                              |
|--------------|---------|-----------------------------------------------------------------------|
| **Free**     | $0/mo   | Basic listing, 3 photos, reviews visible                              |
| **Standard** | $29/mo  | Unlimited photos, reply to reviews, analytics, contact button         |
| **Premium**  | $79/mo  | Featured placement, top of search, promoted map pin, booking widget   |

---

## 🚀 Development Phases

### ✅ Phase 1 — MVP Foundation (COMPLETE)
- [x] 17 Swift source files, all registered in project.pbxproj
- [x] AppTheme — colors, fonts, spacing, radius, cross-platform shims
- [x] Models — Listing, Event, Review, AppUser, enums (default values)
- [x] MockDataService — 20+ listings, 6 events
- [x] MainTabView — 5 tabs
- [x] ExploreView, EventsView, MapExploreView, SearchView, ListingDetailView
- [x] ProfileView + LoginView (Email/Password, Sign Up, Magic Link, Apple, Google)
- [x] All reusable components
- [x] Builds clean: iOS ✅ macOS ✅

### ✅ Phase 2 — Backend, Auth & Admin Portal (COMPLETE)
- [x] Supabase project — URL + keys configured (new `sb_publishable_` format, NOT legacy JWT)
- [x] `supabase-swift` v2.41.1 linked in Xcode
- [x] `SupabaseService.swift` — client singleton
- [x] `ListingRepository` + `EventRepository` — Supabase + Mock fallback
- [x] `AuthService.swift` — Apple / Google / Email / Magic Link, session restore, profile upsert
- [x] ProfileView + LoginView wired to AuthService
- [x] Favorites persisted to Supabase
- [x] Reviews fetched from Supabase
- [x] All 5 ViewModels: async Supabase + auto mock fallback
- [x] Debounced search → PostgreSQL full-text
- [x] Deep link handler — `.onOpenURL` → `AuthService.handleURL()`
- [x] iOS ✅ macOS ✅ — zero errors, zero warnings
- [x] Cross-platform shims — iOS-only APIs wrapped so macOS builds clean
- [x] SQL schema run — all 5 tables live in Supabase
- [x] Auth providers enabled — Email ✅, Apple + Google pending OAuth client IDs
- [x] `photos` storage bucket created — public, ready for image uploads
- [x] `vallartapp-admin` Next.js 14 portal — **live on Vercel** ✅
  - [x] Login — Password + Magic Link with 60s rate-limit cooldown
  - [x] Dashboard — stats cards (listings, events, reviews, featured)
  - [x] Listings CRUD — table, add, edit, delete, photo upload, tags, flags
  - [x] Events CRUD — table, add, edit, delete, dates, tickets, recurrence
  - [x] Business Owners table
  - [x] Auth middleware — no redirect loops, `/unauthorized` page
  - [x] Connected to GitHub (`ElBeDev/vallartapp`) — auto-deploys on every push to `main`
- [x] ✅ **App confirmed running on physical iPhone** (iOS 26.3.1)

### 🔲 Phase 3 — Monetization & Business Features
- [ ] RevenueCat SDK — Free / Standard $29 / Premium $79
- [ ] App Store Connect — subscription products
- [ ] PaywallView (RevenueCat SwiftUI)
- [ ] BusinessSignUpView — claim/create listing in iOS app
- [ ] BusinessDashboardView — analytics, edit listing
- [ ] Featured placement sorting by `is_premium`
- [ ] Push notifications — Supabase Edge Functions + APNs
- [ ] Deep links — Universal Links for shareable URLs
- [ ] Notifications page in admin portal
- [ ] Admin approval flow for listing ownership

### 🔲 Phase 4 — Polish & Launch
- [ ] Localizable.strings — EN + ES-MX
- [ ] Dark mode AppTheme variant
- [ ] VoiceOver + Dynamic Type
- [ ] Haptic feedback
- [ ] Image caching (Kingfisher)
- [ ] SwiftData — recently viewed listings
- [ ] Pagination in all ViewModels
- [ ] App Store screenshots (6.7", 6.1", iPad)
- [ ] App Preview video
- [ ] PrivacyInfo.xcprivacy
- [ ] App Store submission

---

## 🔑 API Keys & Credentials

| Service | Where | Value / Notes |
|---|---|---|
| Supabase URL | `SupabaseService.swift` + `vallartapp-admin/.env.local` | ✅ `https://nvubaobivraevlnlpsjr.supabase.co` |
| Supabase Publishable Key | `SupabaseService.swift` + `.env.local` as `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | ✅ `sb_publishable__7Qzck7u_emY3MmeXS1bpQ_0zKNk2Zy` |
| Supabase Secret Key | `vallartapp-admin/.env.local` as `SUPABASE_SERVICE_ROLE_KEY` ONLY | ⚠️ Supabase → Settings → API. **NEVER in iOS app** |
| Google Sign-In | `Info.plist` | OAuth client ID from Google Cloud Console — Phase 2 remaining |
| RevenueCat | `VallartAppApp.swift` | Phase 3 — `sb_publishable_bO0ldeEwbUB0Ui0BwTNHFw__xeyxFeb` |
| APNs | Supabase dashboard → Push | Phase 3 |

---

## 📱 Device & Testing

| Item | Value |
|---|---|
| **Test Device** | Bernardo's iPhone (iOS 26.3.1) |
| **Device ID** | `00008140-001118EA21E3001C` |
| **Apple Team ID** | `55K745NA3G` |
| **iOS Target** | iOS 17+ |
| **Bundle ID** | `t4e.VallartApp` |
| **Simulator** | iPhone 17 Pro (iOS 26.3.1) |
| **Build** | ✅ BUILD SUCCEEDED — zero errors |
| **Physical Device** | ✅ **CONFIRMED WORKING** — app runs on real iPhone ✅ |

### ⚠️ Disk Space Note
Mac disk was hitting 100% capacity — caused `SwiftCompile` failures and package resolution errors.  
Freed ~8GB by clearing caches. **Keep at least 5GB free** to build successfully.
```bash
# If build fails with "out of space" errors, run this:
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/com.apple.dt.Xcode
xcrun simctl delete unavailable
```

### Run on physical device
```bash
# 1. Connect iPhone via USB
# 2. Enable Developer Mode: Settings → Privacy & Security → Developer Mode → ON
# 3. In Xcode: select "Bernardo's iPhone" from device picker → hit ▶ Run (⌘R)
# 4. First time: Settings → General → VPN & Device Management → [Apple ID] → Trust
```

---

## 🐙 GitHub & Deployment

| Repo | URL |
|---|---|
| **Admin Portal** | `https://github.com/ElBeDev/vallartapp.git` |
| **Vercel** | Connected to GitHub — auto-deploys on every push to `main` |

## 🐛 Known Issues / TODO — verify SF Symbol availability on iOS 17+
- [ ] `sailboat.fill` — verify availability on iOS 17+
- [ ] EventDetailView — add fallback CTA when no `ticketURL`
- [ ] MapExploreView — tapping a second pin leaves old preview card visible
- [ ] CategoryListView — no empty state when 0 listings in category
- [ ] Shopping category — 0 listings in MockData, add 2–3
- [ ] Real app icon needed in Assets.xcassets
- [ ] AuthService — Google Sign-In needs OAuth client ID in `Info.plist`

---

## 💡 Future Feature Ideas

- PV Weather widget on Explore home
- Tide chart for Sayulita surfers
- Reservation booking — OpenTable integration
- Ferry schedules — Yelapa, Las Caletas
- Currency converter — MXN ↔ USD ↔ CAD
- "Plan My Trip" — AI itinerary builder
- Influencer/creator verified accounts
- Video reviews — short-form style
- Loyalty program — points for reviews + check-ins
- Offline mode — SwiftData cache
- WhatsApp share — listing card as image
- Seasonal availability columns (whale watching Nov–Mar)
- Permit warning for Marieta Islands Hidden Beach
