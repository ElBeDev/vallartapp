import type { Metadata } from 'next'
import { site } from '@/lib/site'

export const metadata: Metadata = { title: `Terms of Use — ${site.appName}` }

export default function TermsPage() {
  return (
    <article>
      <h1>Terms of Use / Términos de Uso</h1>
      <p className="text-sm text-slate-500">Last updated / Última actualización: {site.lastUpdated}</p>

      <h2>Using the app</h2>
      <p>
        {site.appName} is free. Listings, hours, prices and events are provided for information only and may change;
        please confirm details with each business before visiting.
      </p>

      <h2>Your content</h2>
      <p>
        You are responsible for the reviews and photos you post. Do not post content that is false, offensive, hateful,
        sexual, or that infringes someone else&apos;s rights. We may remove content or suspend accounts that break these rules.
        To report content, write to <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.
      </p>

      <h2>Liability</h2>
      <p>
        The app is provided &quot;as is&quot;. We are not responsible for the services offered by the businesses listed.
      </p>

      <h2>Contact</h2>
      <p><a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a></p>

      <hr className="my-10 border-orange-100" />
      <p>
        <strong>En español:</strong> {site.appName} es gratuita y la información de negocios y eventos es solo de referencia.
        Eres responsable de las reseñas y fotos que publiques; podemos eliminar contenido que sea falso u ofensivo.
        Para reportar contenido escribe a <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.
      </p>
    </article>
  )
}
