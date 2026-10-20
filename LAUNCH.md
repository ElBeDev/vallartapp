# VallartApp — Checklist de lanzamiento (v1.0 gratis)

## 1. Backend (Supabase)
- [ ] Restaurar el proyecto `nvubaobivraevlnlpsjr` (dashboard → Restore). Hoy da NXDOMAIN.
- [ ] Rotar la service_role key (estuvo pública en GitHub, commit 73a63e3) y desactivar las JWT legacy.
- [ ] Correr `supabase/migrations/20261020_delete_my_account.sql` (SQL Editor). Sin esto falla "Eliminar cuenta".
- [ ] Auth → URL Configuration: Site URL = dominio del panel; Redirect URLs: `vallartapp://auth/callback` y `https://<dominio>/auth/callback`.
- [ ] Auth → Providers: Apple (client ID = `com.bener.VallartApp`) y Google configurados.
- [ ] Push: llave APNs `.p8` → secrets `APNS_KEY_ID`, `APNS_TEAM_ID`, `APNS_PRIVATE_KEY`, `APNS_BUNDLE_ID` para `send-push-notification`.
- [ ] (Opcional) borrar la función `create-payment-intent` ya desplegada.

## 2. Panel admin (Next.js, raíz del repo)
- [x] Desplegado en Vercel (deploy automático en cada push a `main`).
- [x] Variables: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `ADMIN_EMAILS` (obligatorio; vacío = nadie entra).
- [x] Verificar públicas: `/privacy`, `/terms`, `/support` (200 OK).
- [ ] Actualizar `SUPABASE_SERVICE_ROLE_KEY` en Vercel después de rotarla y hacer Redeploy.
- [ ] Borrar el proyecto duplicado `vallartapp-4kx5` en Vercel.

## 3. App iOS
- [x] Panel en Vercel: https://vallartapp.vercel.app (proyecto `vallartapp`). Si compras dominio, cambiar `webBaseURL` en `VallartApp/AppConfig.swift`.
- [ ] Correo de soporte real en `AppConfig.swift` (`supportEmail`) y `src/lib/site.ts`.
- [ ] Confirmar que `support@…` recibe correo.
- [ ] Reemplazar el ícono provisional (`Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`, 1024×1024 sin transparencia).
- [ ] Xcode → Product → Archive → Distribute → App Store Connect.

## 4. App Store Connect
- [ ] Crear la app (bundle `com.bener.VallartApp` — permanente; el nombre visible sí se puede cambiar).
- [ ] URLs: Privacy Policy = `/privacy`, Support = `/support`.
- [ ] Capturas iPhone 6.9" (mín. 3). Solo iPhone (iPad desactivado).
- [ ] App Privacy: Email, Nombre, User ID, Fotos, Contenido de usuario — todo "App Functionality", ligado al usuario, sin tracking.
- [ ] Cuenta demo (email + password) en App Review Information.
- [ ] Categoría Travel · Precio Gratis · Export compliance ya declarado (sin cifrado propio).

## Cambiar el nombre después
`AppConfig.swift` (appName), build setting `APP_DISPLAY_NAME`, `src/lib/site.ts` y el nombre en App Store Connect.
