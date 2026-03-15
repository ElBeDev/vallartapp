import Link from 'next/link'
import { MapPin, ShieldX } from 'lucide-react'

export default function UnauthorizedPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-teal-50 flex items-center justify-center p-4">
      <div className="text-center max-w-md">
        <div className="flex justify-center mb-6">
          <div className="bg-red-100 rounded-2xl p-5">
            <ShieldX className="h-12 w-12 text-red-500" />
          </div>
        </div>
        <h1 className="text-2xl font-bold text-slate-800 mb-2">Access Denied</h1>
        <p className="text-slate-500 mb-8">
          Your account doesn&apos;t have admin access to VallartApp.<br />
          Contact the app owner to request access.
        </p>
        <div className="flex items-center justify-center gap-2 text-slate-400 text-sm">
          <MapPin className="h-4 w-4 text-orange-400" />
          <span>VallartApp Admin Portal</span>
        </div>
        <Link
          href="/login"
          className="inline-block mt-6 text-sm text-orange-500 hover:text-orange-600 underline underline-offset-2"
        >
          Sign in with a different account
        </Link>
      </div>
    </div>
  )
}
