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

### ✅ 2.1 Filtro por precio en SearchView
`selectedPriceRange: PriceRange?` en `SearchViewModel`. Chips "Any / Free / $ / $$ / $$$ / $$$$" en `FilterSheetView`. Query Supabase `.eq("price_range", value: price.rawValue)`. Chip activo en `activeFiltersBar`.

---

### ✅ 2.2 Filtros dentro de CategoryListView
`selectedNeighborhood: Neighborhood?` + `openOnly: Bool` + `filterBar` horizontal. `filteredListings` filtra client-side. Solo muestra los barrios que tienen listings en esa categoría. Skeleton mientras carga.

---

### ✅ 2.3 Share button en ListingDetailView y EventDetailView
`ShareLink` en toolbar de ambas detail views. Comparte nombre + zona + descripción + URL.

---

### ✅ 2.4 Deep link desde notificación push a listing/evento
`DeepLinkTarget: Identifiable` enum con `.listing(UUID)` y `.event(UUID)`. `PushDelegate.didReceive` parsea `userInfo` y setea `PushNotificationService.shared.pendingDeepLink`. `MainTabView` presenta `DeepLinkDetailView` como sheet — fetcha el objeto por ID y muestra `ListingDetailView` o `EventDetailView` según corresponda.

---

## Fase 3 — Code Quality & DRY 🛠️

### ✅ 3.1 Extraer categoryColor a ListingCategory
`extension ListingCategory { var color: Color }` en `Components.swift`. Eliminados 5 switch duplicados en: `CategoryGridCard`, `FeaturedCardView`, `ListingRowView`, `MapPinView`, `MapPreviewCard`, `ListingDetailView`.

---

### ✅ 3.2 Búsqueda full-text sobre nombre + descripción + tags
Reemplazado `textSearch("name", ...)` por `.or("name.ilike.%q%,description.ilike.%q%")`. Búsqueda parcial case-insensitive en name y description sin requerir columna tsvector.

---

### ✅ 3.3 Paginación en fetchAll()
`fetchPage(offset:limit:)` en protocolo e implementación. `ExploreViewModel` carga 20 al inicio; `loadNextPage()` appends on scroll. `canLoadMore` + `isLoadingMore` controlan el estado. `ProgressView()` en el footer.

---

### ✅ 3.4 "Photos" stat en ProfileView
`myPhotoCount` = suma de `review.photos.count` de todas las reviews del usuario. Ya se calcula junto con `myReviewCount` en el mismo `.task`.

---

## Fase 4 — Engagement & Retention 📈

### ✅ 4.1 Onboarding splash en primer launch
`OnboardingView.swift` — 3 páginas swipeables con `TabView .page`. Gradientes animados, dots de progreso, "Next" → "Create Free Account" / "Browse as Guest". `@AppStorage("hasSeenOnboarding")` en `VallartAppApp` controla si se muestra.

---

### ✅ 4.2 "Trending Now" section en ExploreView
`fetchTrending(limit:)` — ordena por `review_count DESC, rating DESC`, mín 1 review. Sección horizontal entre Featured y Events en `ExploreView`. Reutiliza `FeaturedCardView` + `FeaturedCardSkeleton`.

---

### 4.3 Notificaciones automáticas de eventos de la semana
Supabase Edge Function + cron cada lunes. Inserta rows en `notifications` con `user_id = null` (broadcast). **Requiere deploy en Supabase** — código Swift ya listo, sólo falta el backend.

---

## Fase 5 — Polish Round 2 🌟

### ✅ 5.1 StarRatingView — componente visual de estrellas
`StarRatingView` en `Components.swift`: soporta medias estrellas (`star.leadinghalf.filled`), tamaño y color configurables. Reemplaza el ícono single en `FeaturedCardView`, `ListingRowView`, `MapPreviewCard` y `ListingDetailView.titleSection`.

### ✅ 5.2 Error toast en ExploreView
Cuando `vm.errorMessage != nil`, se muestra un banner coral animado con botón × en la parte superior del `ZStack`. Animación con `.spring` + `.move(edge: .top)`.

### ✅ 5.3 Haptics completos en Auth
`signInWithApple` y `signInWithGoogle` ahora disparan `Haptic.success()` / `Haptic.error()` según resultado (complementa los haptics de email/magic-link ya existentes).

### ✅ 5.4 Search history persistente
`SearchViewModel` guarda hasta 8 búsquedas recientes en `UserDefaults`. Al volver al tab vacío se muestran como chips horizontales encima de la grilla de categorías. Tap en chip rellena la query. Botón "Clear" los elimina.

### ✅ 5.5 MapExploreView — dataset completo
`MapExploreView` ahora es self-contained: fetch propio de hasta 500 listings (`fetchPage(offset:0, limit:500)`) en `.task`. Antes solo mostraba los 20 de `popularListings`. Se desacopla de `ExploreViewModel`.

### ✅ 5.6 URLCache — caché de imágenes agresivo
`URLCache.shared` configurado en el `init()` de `VallartAppApp` con 50 MB memoria + 250 MB disco. `AsyncImage` ya no re-fetcha la misma foto al navegar entre pantallas.

---

## Fase 6 — Audit & Hardening 🔒

### ✅ 6.1 PremiumView — haptics + sign-in CTA
Botones "Get Explorer" y "Get [Business Tier]" disparan `Haptic.medium()` al tocar y `Haptic.success()` cuando el pago se activa. Usuarios no logueados ven un botón blanco "Sign In / Register" que abre `LoginView` como sheet — antes era texto muerto sin acción.

### ✅ 6.2 Bug fix: swipe-to-remove en Saved Listings
`savedSheet` usaba `LazyVStack` con `.swipeActions` que SwiftUI ignora silenciosamente. Convertido a `List` con `.listStyle(.plain)` + `.scrollContentBackground(.hidden)`. El swipe-to-remove ahora funciona.

### ✅ 6.3 Bug fix: swipe-to-delete en My Reviews
`MyReviewsView.reviewsList` tenía el mismo bug. Convertido a `List`. El swipe "Delete" ahora funciona.

### ✅ 6.4 StarRatingView — cobertura completa
`ReviewRowView` (en ListingDetail) y `MyReviewRowView` (en My Reviews) actualizados. `MyReviewRowView` tenía su propio `ForEach(1...5)` inline — eliminado. Ahora todas las vistas de rating usan `StarRatingView`.

### ✅ 6.5 ContentView.swift eliminado
Archivo de código muerto (el entry point real es `VallartAppApp`). Removido del proyecto y del disco vía `XcodeRM`.

---

## Progreso

```
Sprint 1 ✅  : 1.1 ✅  1.2 ✅  1.3 ✅  3.1 ✅
Sprint 2 ✅  : 1.4 ✅  2.3 ✅
Sprint 3 ✅  : 2.1 ✅  2.4 ✅  3.2 ✅
Sprint 4 ✅  : 2.2 ✅  3.3 ✅  3.4 ✅
Sprint 5 ✅  : 4.1 ✅  4.2 ✅  (4.3 = backend deploy)
Sprint 6 ✅  : 5.1 ✅  5.2 ✅  5.3 ✅  5.4 ✅  5.5 ✅  5.6 ✅
Sprint 7 ✅  : 6.1 ✅  6.2 ✅  6.3 ✅  6.4 ✅  6.5 ✅
```

---

## Estado final del cliente iOS

| Área | Estado |
|---|---|
| Arquitectura (MVVM, async/await, protocols) | ✅ Sólida |
| Auth (Email, Apple, Google, Magic Link) | ✅ Completa con haptics |
| Onboarding (3 páginas, guest/signup) | ✅ Completo |
| ExploreView (featured, trending, infinite scroll, error toast) | ✅ Completo |
| MapExploreView (500 pins, filtros, preview card, user location) | ✅ Completo |
| SearchView (debounce, filtros, skeleton, historial reciente) | ✅ Completo |
| EventsView (filtros, detail, share, skeleton) | ✅ Completo |
| ListingDetailView (galería, mapa inline, navigate, share, reviews) | ✅ Completo |
| ProfileView (avatar, saved*, reviews*, stats, settings) | ✅ Completo |
| PremiumView (Explorer + Business, Stripe checkout) | ✅ Completo |
| NotificationsView (swipe read/delete, deep link) | ✅ Completo |
| Push Notifications (APNs, Supabase inbox, badges, deep link) | ✅ Conectado |
| StarRatingView (medias estrellas, todas las vistas) | ✅ Uniforme |
| Haptics (light/medium/success/error en toda la app) | ✅ Uniforme |
| URLCache (50MB mem + 250MB disco) | ✅ Activo |
| Localización en/es | ✅ Completa |

*swipe actions funcionando tras fix de LazyVStack → List

## Pendiente (backend)

- **4.3** Supabase Edge Function — broadcast semanal de eventos vía cron. El código Swift está listo; solo requiere deploy en el dashboard de Supabase.
