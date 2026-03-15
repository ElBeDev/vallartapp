import Foundation
import Supabase

// MARK: - SupabaseService
// Single shared Supabase client for the entire app.
// Uses the new publishable key format (sb_publishable_...).

enum SupabaseConfig {
    static let projectURL     = "https://nvubaobivraevlnlpsjr.supabase.co"
    static let publishableKey = "sb_publishable__7Qzck7u_emY3MmeXS1bpQ_0zKNk2Zy"
}

// Global singleton — use `supabase` anywhere in the app
let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.projectURL)!,
    supabaseKey: SupabaseConfig.publishableKey,
    options: SupabaseClientOptions(
        auth: SupabaseClientOptions.AuthOptions(
            emitLocalSessionAsInitialSession: true
        )
    )
)
