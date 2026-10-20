import type { Metadata } from 'next'
import { site } from '@/lib/site'

export const metadata: Metadata = { title: `Privacy Policy — ${site.appName}` }

export default function PrivacyPage() {
  return (
    <article>
      <h1>Privacy Policy / Aviso de Privacidad</h1>
      <p className="text-sm text-slate-500">Last updated / Última actualización: {site.lastUpdated}</p>

      <h2>Who we are</h2>
      <p>
        {site.appName} is a free guide to places and events in Puerto Vallarta, operated by {site.owner},
        {' '}{site.city} (&quot;we&quot;). Contact: <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.
      </p>

      <h2>What we collect</h2>
      <ul>
        <li><strong>Account data</strong> — email address and name, when you create an account (email, Sign in with Apple or Google).</li>
        <li><strong>Profile photo</strong> — only if you choose to upload one.</li>
        <li><strong>Content you create</strong> — reviews, ratings and saved places.</li>
        <li><strong>Push notification token</strong> — if you allow notifications, so we can send you updates about events.</li>
      </ul>
      <p>
        Your location is used <strong>only on your device</strong> to show your position on the map. We do not store or share it.
        You can use the app without an account.
      </p>

      <h2>How we use it</h2>
      <p>
        Only to run the app: sign you in, show your profile, publish your reviews and send notifications you opted into.
        We do not sell your data, show third-party ads or track you across other apps or websites.
      </p>

      <h2>Service providers</h2>
      <p>
        Data is stored with Supabase (database, authentication and file storage). Push notifications are delivered through
        Apple Push Notification service. These providers process data on our behalf only.
      </p>

      <h2>Your rights and account deletion</h2>
      <p>
        You can edit your name and photo in the app, and delete your account at any time from
        {' '}<strong>Profile → Settings → Delete Account</strong>. This permanently removes your account, profile, reviews
        and saved places. You may also exercise your ARCO rights (access, rectification, cancellation and opposition) by
        writing to <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.
      </p>

      <h2>Children</h2>
      <p>The app is not directed to children under 13 and we do not knowingly collect their data.</p>

      <h2>Changes</h2>
      <p>If we change this policy we will update the date above and, for significant changes, notify you in the app.</p>

      <hr className="my-10 border-orange-100" />

      <h2>Resumen en español</h2>
      <p>
        {site.appName} es una guía gratuita de lugares y eventos en Puerto Vallarta. El responsable del tratamiento de tus
        datos es {site.owner}, {site.city}. Recabamos tu correo y nombre (si creas una cuenta), tu foto de perfil (si la subes),
        tus reseñas y lugares guardados, y el token de notificaciones (si las permites). Tu ubicación solo se usa en tu
        dispositivo para mostrar el mapa y no se guarda. Usamos estos datos únicamente para que la app funcione; no los vendemos
        ni los usamos para publicidad. Puedes eliminar tu cuenta desde <strong>Perfil → Ajustes → Eliminar Cuenta</strong> o
        ejercer tus derechos ARCO escribiendo a <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.
      </p>
    </article>
  )
}
