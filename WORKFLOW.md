# VallartApp — Development Workflow

**Version:** 1.0  
**Last Updated:** March 14, 2026  
**Platform:** iOS 17+  
**Language:** Swift / SwiftUI  
**Primary Language:** English | **Secondary Language:** Spanish (es-MX)

---

## 🧭 App Overview

VallartApp is a tourism discovery platform for **Puerto Vallarta and surrounding areas** (Riviera Nayarit, Sayulita, Punta Mita, Bucerías, Sayulita, San Pancho, etc.).

**Business Model:** Yelp / TripAdvisor style
- ✅ **Free for users** — browse everything, read reviews, save favorites
- 💼 **Paid plans for business owners** — featured placement, analytics, unlimited photos, booking integration
- 🌟 **User Premium (future)** — ad-free, exclusive deals, early event access

---

## 📁 Project Structure

```
VallartApp/
├── VallartApp/
│   ├── App/
│   │   └── MainTabView.swift
│   ├── Models/
│   │   ├── Category.swift
│   │   ├── Listing.swift
│   │   ├── Event.swift
│   │   ├── Restaurant.swift
│   │   ├── Hotel.swift
│   │   ├── Activity.swift
│   │   ├── YachtRental.swift
│   │   ├── VehicleRental.swift
│   │   ├── Review.swift
│   │   └── User.swift
│   ├── Features/
│   │   ├── Explore/
│   │   │   ├── ExploreView.swift
│   │   │   └── ExploreViewModel.swift
│   │   ├── Events/
│   │   │   ├── EventsView.swift
│   │   │   ├── EventDetailView.swift
│   │   │   └── EventsViewModel.swift
│   │   ├── Map/
│   │   │   ├── MapExploreView.swift
│   │   │   └── MapViewModel.swift
│   │   ├── Search/
│   │   │   ├── SearchView.swift
│   │   │   └── SearchViewModel.swift
│   │   ├── Detail/
│   │   │   ├── ListingDetailView.swift
│   │   │   └── ReviewRowView.swift
│   │   ├── Profile/
│   │   │   ├── ProfileView.swift
│   │   │   └── ProfileViewModel.swift
│   │   └── Auth/
│   │       ├── LoginView.swift
│   │       └── SignUpView.swift
│   ├── Components/
│   │   ├── ListingCardView.swift
│   │   ├── CategoryChipView.swift
│   │   ├── RatingStarsView.swift
│   │   ├── FeaturedCarouselView.swift
│   │   ├── SectionHeaderView.swift
│   │   └── BadgeView.swift
│   ├── Services/
│   │   ├── MockDataService.swift
│   │   └── LocationService.swift
│   ├── Resources/
│   │   └── AppTheme.swift
│   ├── ContentView.swift
│   └── VallartAppApp.swift
└── WORKFLOW.md
```

---

## 🎨 Design System — AppTheme

### Color Palette
| Name            | Hex       | Usage                              |
|-----------------|-----------|------------------------------------|
| `coral`         | `#FF6B6B` | Primary CTA buttons, highlights    |
| `teal`          | `#2EC4B6` | Secondary accent, map pins         |
| `sand`          | `#F7F3E3` | Background, cards                  |
| `deepNavy`      | `#1A2F4E` | Headers, primary text              |
| `goldenSun`     | `#FFB347` | Stars, premium badges              |
| `palmGreen`     | `#4CAF50` | Active states, open status         |
| `nightPurple`   | `#6C5CE7` | Nightlife category                 |
| `oceanBlue`     | `#0077B6` | Water activities, yachts           |

### Typography
- **Display:** SF Pro Rounded Bold — hero titles
- **Headline:** SF Pro Display Semibold — section headers
- **Body:** SF Pro Text Regular — descriptions
- **Caption:** SF Pro Text — metadata, tags

### Spacing System
- `xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`, `xxl: 48`

---

## 📦 Categories

| ID  | Name              | Icon | Color         |
|-----|-------------------|------|---------------|
| 1   | Restaurants       | 🍽️  | coral         |
| 2   | Bars & Nightlife  | 🍹  | nightPurple   |
| 3   | Hotels            | 🏨  | deepNavy      |
| 4   | Activities        | 🏄  | teal          |
| 5   | Yacht Rentals     | ⛵  | oceanBlue     |
| 6   | Car & Moto Rental | 🏍️  | goldenSun     |
| 7   | Events            | 🎉  | coral         |
| 8   | Beaches           | 🏖️  | teal          |
| 9   | Shopping          | 🛍️  | sand/navy     |
| 10  | Spas & Wellness   | 💆  | palmGreen     |

---

## 🗺️ Geographic Coverage

- Puerto Vallarta (Centro, Zona Romántica, Marina, Hotel Zone)
- Nuevo Vallarta / Riviera Nayarit
- Bucerías
- La Cruz de Huanacaxtle
- Punta Mita
- Sayulita
- San Pancho (San Francisco)
- Yelapa

---

## 📱 Navigation Structure

```
MainTabView
├── Tab 1: Explore       — Home feed, featured, categories grid
├── Tab 2: Map           — MapKit map with category pins & filters
├── Tab 3: Events        — Calendar view, public/private events
├── Tab 4: Search        — Full-text search + filter sheet
└── Tab 5: Profile       — User profile / Business owner portal
```

---

## 🏗️ Architecture

- **Pattern:** MVVM (Model-View-ViewModel)
- **State Management:** `@StateObject`, `@ObservableObject`, `@Published`
- **Navigation:** `NavigationStack` + `TabView`
- **Data (Phase 1):** Mock data via `MockDataService.swift`
- **Data (Phase 2+):** Firebase Firestore + Firebase Auth
- **Maps:** MapKit (native)
- **Images:** `AsyncImage` → Kingfisher (Phase 2)
- **Payments:** RevenueCat + StoreKit 2 (Phase 3)
- **Push Notifications:** Firebase Cloud Messaging (Phase 3)

---

## 💼 Business Owner Subscription Tiers

| Tier       | Price     | Features                                                      |
|------------|-----------|---------------------------------------------------------------|
| **Free**   | $0/mo     | Basic listing, 3 photos, reviews visible                      |
| **Standard** | $29/mo  | Unlimited photos, reply to reviews, contact button, analytics |
| **Premium** | $79/mo   | Featured placement, top of search, promoted pin on map, booking widget |

---

## 🚀 Development Phases

### Phase 1 — MVP Foundation (Current)
- [x] Project folder structure
- [x] AppTheme (colors, fonts, spacing)
- [x] All data models
- [x] MainTabView (5 tabs)
- [x] ExploreView + ExploreViewModel
- [x] EventsView + EventDetailView
- [x] ListingDetailView (shared)
- [x] SearchView + filters
- [x] MapExploreView (MapKit)
- [x] ProfileView
- [x] MockDataService with sample Puerto Vallarta data
- [x] All reusable components

### Phase 2 — Backend & Auth (Next)
- [ ] Firebase project setup
- [ ] Firebase Auth (email + Sign in with Apple)
- [ ] Firestore data models & repositories
- [ ] Google Places API integration (pre-populate listings)
- [ ] Reviews & ratings (write, read, paginate)
- [ ] Favorites / saved listings (persisted)
- [ ] Image upload to Firebase Storage
- [ ] Algolia search integration

### Phase 3 — Monetization & Business Dashboard
- [ ] RevenueCat subscription integration
- [ ] Business owner sign-up + listing claim flow
- [ ] Business dashboard (analytics, edit listing)
- [ ] Featured/promoted placement logic
- [ ] Firebase Cloud Messaging push notifications
- [ ] Firebase Dynamic Links (shareable deep links)

### Phase 4 — Polish & Launch
- [ ] Full ES-MX localization (all strings in `Localizable.strings`)
- [ ] Dark mode support
- [ ] Offline caching (Firestore offline + SwiftData)
- [ ] Accessibility (VoiceOver, Dynamic Type)
- [ ] App Store assets (screenshots, App Preview video)
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`)
- [ ] App Store submission

---

## 🌐 Localization

| Key            | English (default) | Spanish (es-MX)       |
|----------------|-------------------|-----------------------|
| `tab.explore`  | Explore           | Explorar              |
| `tab.map`      | Map               | Mapa                  |
| `tab.events`   | Events            | Eventos               |
| `tab.search`   | Search            | Buscar                |
| `tab.profile`  | Profile           | Perfil                |
| `cat.restaurants` | Restaurants    | Restaurantes          |
| `cat.bars`     | Bars & Nightlife  | Bares y Antros        |
| `cat.hotels`   | Hotels            | Hoteles               |
| `cat.activities` | Activities      | Actividades           |
| `cat.yachts`   | Yacht Rentals     | Renta de Yates        |
| `cat.rentals`  | Car & Moto Rental | Renta de Autos/Motos  |
| `cat.events`   | Events            | Eventos               |
| `cat.beaches`  | Beaches           | Playas                |
| `cat.shopping` | Shopping          | Compras               |
| `cat.spas`     | Spas & Wellness   | Spas y Bienestar      |

---

## 📋 Mock Data Included (Phase 1)

### Restaurants
- Café des Artistes (Fine dining, Centro)
- El Arrayán (Mexican cuisine, Zona Romántica)
- La Palapa (Seafood, Playa Los Muertos)
- Taco Bar Sayulita (Casual, Sayulita)

### Events
- Vallarta Pride (Annual, public, Zona Romántica)
- Moonlight Jazz Night (Weekly, private, Marina)
- Sayulita Surf Competition (Annual, public, Sayulita)
- Downtown Food Festival (Monthly, public, Centro)

### Hotels
- Garza Blanca Preserve Resort & Spa (Luxury)
- Hotel Rosita (Boutique, historic)
- Casa Kimberly (Boutique luxury)
- W Punta de Mita (Luxury resort)

### Activities
- Marieta Islands Snorkeling Tour
- ATV Jungle Adventure
- Zip-line Canopy Tour
- Whale Watching (seasonal Nov–Mar)
- Paddle Board Yoga at Sayulita

### Yacht Rentals
- Sunset Sailing Cruise (4h)
- Private Catamaran — Marietas
- Sport Fishing Charter (Full day)

### Car & Moto Rentals
- Vallarta Car Rental (Centro)
- Moto Rent PV (Zona Romántica)
- ATV Adventures PV

---

## 🔑 API Keys Needed (Phase 2+)

| Service              | Key Location                    |
|----------------------|---------------------------------|
| Firebase             | `GoogleService-Info.plist`      |
| Google Places API    | `Info.plist` → `GMSApiKey`      |
| RevenueCat           | `VallartAppApp.swift` init      |
| Algolia              | `Services/SearchService.swift`  |

---

## 📌 Notes

- Puerto Vallarta is **LGBT+ friendly** — Zona Romántica nightlife should have a dedicated filter/badge
- **Whale watching** is seasonal (November–March) — listings should support seasonal availability flags
- **Sayulita** has strong surf culture — separate sub-tags within Activities
- All prices displayed in **MXN** by default, with USD toggle
- Coordinate center for PV map: `lat: 20.6534, lng: -105.2253`
