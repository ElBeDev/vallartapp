import type { Metadata } from 'next'
import { site } from '@/lib/site'

export const metadata: Metadata = { title: `Support — ${site.appName}` }

export default function SupportPage() {
  return (
    <article>
      <h1>Support / Soporte</h1>
      <p>
        Questions, problems or want to list your business? Email us at
        {' '}<a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a> — we usually reply within 2 business days.
      </p>
      <p>
        ¿Dudas, problemas o quieres agregar tu negocio? Escríbenos a
        {' '}<a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.
      </p>

      <h2>FAQ</h2>
      <ul>
        <li><strong>Is the app free? / ¿Es gratis?</strong> Yes. / Sí.</li>
        <li>
          <strong>How do I delete my account? / ¿Cómo elimino mi cuenta?</strong> Profile → Settings → Delete Account. /
          Perfil → Ajustes → Eliminar Cuenta.
        </li>
        <li>
          <strong>A listing has wrong info. / Un lugar tiene información incorrecta.</strong> Email us the name and the
          correction. / Envíanos el nombre y la corrección.
        </li>
      </ul>
    </article>
  )
}
