# VallartApp — Roadmap de Mejoras

> Análisis completo del estado actual (Aug 2026) + plan de implementación priorizado.

---

## Estado actual — resumen rápido

| Área | Estado |
|---|---|
| Arquitectura (MVVM, async/await, Supabase, protocols) | ✅ Sólida |
| Auth (Email, Apple, Google, Magic Link) | ✅ Completa |
| ProfileView (avatar upload, saved, reviews, premium badge) | ✅ Completa |
| ListingDetailView (mapa inline, GPS, reviews, acciones) | ✅ Completa |
| MapExploreView (pins, filtros, preview card) | ✅ Funcional |
| Search (debounce, full-text, filtros) | ✅ Funcional |
| EventsView (filtros, EventDetailView, tickets URL) | ✅ Funcional |
| Premium / Stripe (viajeros + negocios, mensual/anual) | ✅ Funcional |
| Push Notifications (APNs, Supabase inbox, badges) | ✅ Conectado |
| Localización en/es | ✅ Completa |

---

## Fase 1 — Visual Wins 🔥

### ✅ 1.1 Gallery/pager de fotos en ListingDetailView
`heroSection` ahora usa `TabView` con `PageTabViewStyle`. Dots automáticos cuando hay >1 foto.

### ✅ 1.2 Fotos en EventCardView y EventListRowView
- `EventCardView`: foto real con gradiente overlay, gradiente coral como fallback.
- `EventListRowView`: thumbnail 64×64 de la foto; date badge solo como fallback.

### ✅ 1.3 Skeleton/shimmer loading en ExploreView y EventsView
`ShimmerView`, `FeaturedCardSkeleton`, `ListingRowSkeleton`, `EventRowSkeleton` — activos mientras `isLoading == true`.

### ✅ 1.4 Botón "Near Me" en MapExploreView
`UserAnnotation()` + `MapUserLocationButton()` nativo de MapKit. Un toque recentra al usuario.

---

## Fase 2 — Feature Completeness 💪

### 2.1 Filtro por precio en SearchView
**Archivo:** `SearchView.swift` — `SearchViewModel` + `FilterSheetView`

Agregar `@Published var maxPrice: PriceRange? = nil` en `SearchViewModel`. En `FilterSheetView` sección "Price" con chips: $, $$, $$$, $$$$. Query Supabase: `.lte("price_range", value: maxPrice.rawValue)`.

---

### 2.2 Filtros dentro de CategoryListView
**Archivo:** `ListingDetailView.swift` — `CategoryListView`

Agregar `filterBar` horizontal con chips: All / Open Now / Por zona. Reutiliza `FilterChip` existente.

---

### ✅ 2.3 Share button en ListingDetailView y EventDetailView
`ShareLink` en toolbar de ambas detail views. Comparte nombre + zona + descripción + URL.

---

### 2.4 Deep link desde notificación push a listing/evento
**Archivo:** `PushNotificationService.swift`, `VallartAppApp.swift`

`@Published var deepLinkTarget: DeepLinkTarget?` en `PushNotificationService`. `PushDelegate.didReceive` parsea `userInfo` y escribe al shared service. `VallartAppApp` observa el target y navega.

```swift
enum DeepLinkTarget {
  case listing(UUID)
  case event(UUID)
}
```

---

## Fase 3 — Code Quality & DRY 🛠️

### ✅ 3.1 Extraer categoryColor a ListingCategory
`extension ListingCategory { var color: Color }` en `Components.swift`. Eliminados 5 switch duplicados en: `CategoryGridCard`, `FeaturedCardView`, `ListingRowView`, `MapPinView`, `MapPreviewCard`, `ListingDetailView`.

---

### 3.2 Búsqueda full-text sobre nombre + descripción + tags
**Archivo:** `ListingRepository.swift` — `search()`

`textSearch("name", ...)` solo busca en name. Fix: `.or("name.ilike.%\(q)%,description.ilike.%\(q)%")` para búsqueda parcial case-insensitive, o columna `tsvector` en Supabase.

---

### 3.3 Paginación en fetchAll()
**Archivo:** `ListingRepository.swift`

`fetchAll()` retorna 258+ listings en una sola query. Agregar `.limit()` + `.range()` al protocolo. En `ExploreViewModel`, infinite scroll con `.onAppear` del último elemento.

---

### 3.4 "Photos" stat en ProfileView
**Archivo:** `ProfileView.swift`

Stat hardcodeado a `"0"`. Opción A: ocultarlo. Opción B: contar fotos de reviews del usuario.

---

## Fase 4 — Engagement & Retention 📈

### 4.1 Onboarding splash en primer launch
Nuevo `OnboardingView.swift`. 3 pantallas: discover → find spots → CTA sign up / browse as guest. `UserDefaults` para no repetirlo.

---

### 4.2 "Trending Now" section en ExploreView
Nueva query `fetchTrending()` — ordena por `review_count DESC` + `created_at` reciente. Sección horizontal en Explore.

---

### 4.3 Notificaciones automáticas de eventos de la semana
Supabase Edge Function + cron cada lunes. Inserta rows en `notifications` con `user_id = null` (broadcast).

---

## Progreso

```
Sprint 1 ✅  : 1.1 ✅  1.2 ✅  1.3 ✅  3.1 ✅
Sprint 2 ✅  : 1.4 ✅  2.3 ✅
Sprint 3     : 2.1 → 2.4 → 3.2
Sprint 4     : 2.2 → 3.3 → 3.4
Sprint 5     : 4.1 → 4.2 → 4.3
```

---

## Lo que NO tocar (está bien como está)

- `AuthService` — flujo de auth completo y bien implementado
- `StripeService` / `PremiumView` — paywall funcional
- `AppTheme` — sistema de design coherente y reutilizable
- `SupabaseListingRepository` / `SupabaseEventRepository` — queries limpias
- `PushNotificationService` — token registro + inbox conectado a Supabase
- `WriteReviewView` — flujo de review completo
