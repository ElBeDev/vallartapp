# VallartApp — Checklist de lanzamiento (v1.0 gratis)

## 1. Backend (Supabase)
- [x] Proyecto activo (ACTIVE_HEALTHY).
- [x] RLS activo en todas las tablas + políticas de Storage (`20261020_rls_hardening.sql`, aplicado).
- [x] Función `delete_my_account` (aplicada).
- [x] Admins en `public.admin_users` (elbedev90@gmail.com). Para agregar otro: `insert into admin_users(email) values ('...')` + `ADMIN_EMAILS` en Vercel.
- [x] Auth → URL Configuration: Site URL `https://vallartapp.vercel.app`; Redirect URLs `vallartapp://auth/callback` y `https://vallartapp.vercel.app/**`.
- [ ] Auth → Providers → Apple: Enable, Client IDs = `com.bener.VallartApp` (para login nativo no hace falta secret).
- [x] API Keys → Legacy API keys → Disable (mata la service_role filtrada; app y panel ya usan las llaves nuevas).
- [x] Edge Functions: borrar `create-payment-intent`; Secrets: borrar `STRIPE_SECRET_KEY`.
- [x] Auth → Users → Add user: tu cuenta admin (si no existe) y la cuenta demo para Apple (Auto Confirm).
- [ ] Revocar el access token `sbp_…` usado en la sesión con Claude.
- [ ] (Después) SMTP propio: el integrado solo manda 2 correos/hora.
- [ ] (Push) llave APNs `.p8` → secrets `APNS_*`; y proteger `send-push-notification` (hoy verify_jwt=false, cualquiera puede llamarla).
- [ ] (Después) Google: crear OAuth client en Google Cloud, configurarlo en Supabase y poner `googleSignInEnabled = true` en `AppConfig.swift`.

## 2. Panel admin (Next.js, raíz del repo)
- [x] Desplegado en Vercel (deploy automático en cada push a `main`).
- [x] Variables: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `ADMIN_EMAILS` (obligatorio; vacío = nadie entra).
- [x] Verificar públicas: `/privacy`, `/terms`, `/support` (200 OK).
- [ ] Actualizar `SUPABASE_SERVICE_ROLE_KEY` en Vercel después de rotarla y hacer Redeploy.
- [ ] Borrar el proyecto duplicado `vallartapp-4kx5` en Vercel.

## 3. App iOS
- [x] Panel en Vercel: https://vallartapp.vercel.app (proyecto `vallartapp`). Si compras dominio, cambiar `webBaseURL` en `VallartApp/AppConfig.swift`.
- [x] Correo de soporte: elbedev90@gmail.com.
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
