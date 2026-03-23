import Foundation
import Combine
import Supabase
import AuthenticationServices
import UIKit

// MARK: - AuthService
// Handles all authentication: Apple, Google, Email/Password, Magic Link.
// Publishes current session state so any View can react to auth changes.

@MainActor
class AuthService: ObservableObject {

    static let shared = AuthService()

    @Published var session: Session?          // nil = logged out
    @Published var profile: UserProfile?      // loaded after sign-in
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isLoggedIn: Bool { session != nil }
    var currentUserID: UUID? { session?.user.id }

    private init() {
        // Listen to auth state changes in real-time
        Task {
            // Restore existing session on app launch
            session = supabase.auth.currentSession
            if let uid = currentUserID { await loadProfile(uid: uid) }

            // Stream future auth state changes
            for await (event, newSession) in supabase.auth.authStateChanges {
                switch event {
                case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                    session = newSession
                    if let uid = newSession?.user.id { await loadProfile(uid: uid) }
                case .signedOut:
                    session = nil
                    profile = nil
                default:
                    break
                }
            }
        }
    }

    // MARK: - Sign In with Apple
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        guard let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            errorMessage = "Apple Sign-In failed — no identity token"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let s = try await supabase.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: token)
            )
            session = s
            await ensureProfile(user: s.user, name: fullName(from: credential))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign In with Google (opens OAuth browser flow)
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "vallartapp://auth/callback")
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign In with Email + Password
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let s = try await supabase.auth.signIn(email: email, password: password)
            session = s
            await loadProfile(uid: s.user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Create Account with Email + Password
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["name": AnyJSON.string(name)]
            )
            // signUp returns AuthResponse — session is optional until email confirmed
            if let s = response.session {
                session = s
                await ensureProfile(user: s.user, name: name)
            } else {
                // Email confirmation required — tell the user
                errorMessage = "Check your email to confirm your account."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Magic Link
    func sendMagicLink(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.signInWithOTP(
                email: email,
                redirectTo: URL(string: "vallartapp://auth/callback")
            )
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Sign Out
    func signOut() async {
        do {
            try await supabase.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Handle deep link callback (magic link / OAuth)
    func handleURL(_ url: URL) {
        Task {
            do {
                try await supabase.auth.session(from: url)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Favorites
    func toggleSaved(listingID: UUID) async {
        guard let uid = currentUserID else { return }
        let idStr = listingID.uuidString
        var saved = profile?.savedListingIds ?? []
        if saved.contains(idStr) {
            saved.removeAll { $0 == idStr }
        } else {
            saved.append(idStr)
        }
        do {
            try await supabase
                .from("profiles")
                .update(["saved_listing_ids": saved])
                .eq("id", value: uid.uuidString)
                .execute()
            profile?.savedListingIds = saved
        } catch {
            print("toggleSaved error: \(error)")
        }
    }

    func isSaved(_ listingID: UUID) -> Bool {
        profile?.savedListingIds.contains(listingID.uuidString) ?? false
    }

    // MARK: - Update Profile Name
    func updateName(_ newName: String) async {
        guard let uid = currentUserID else { return }
        do {
            try await supabase
                .from("profiles")
                .update(["name": newName])
                .eq("id", value: uid.uuidString)
                .execute()
            profile?.name = newName
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Upload Avatar
    func uploadAvatar(_ image: UIImage) async -> String? {
        guard let uid = currentUserID,
              let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let path = "avatars/\(uid.uuidString).jpg"
        do {
            try await supabase.storage
                .from("listings")
                .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
            let url = try supabase.storage.from("listings").getPublicURL(path: path).absoluteString
            try await supabase
                .from("profiles")
                .update(["avatar_url": url])
                .eq("id", value: uid.uuidString)
                .execute()
            profile?.avatarUrl = url
            return url
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Fetch Saved Listings
    func fetchSavedListings() async -> [Listing] {
        guard let profile, !profile.savedListingIds.isEmpty else { return [] }
        do {
            let rows: [ListingRow] = try await supabase
                .from("listings")
                .select()
                .in("id", values: profile.savedListingIds)
                .execute()
                .value
            return rows.map { $0.toListing() }
        } catch {
            return []
        }
    }

    // MARK: - Fetch My Reviews
    func fetchMyReviews() async -> [Review] {
        guard let uid = currentUserID else { return [] }
        return (try? await SupabaseListingRepository.shared.fetchReviews(byUserID: uid)) ?? []
    }

    // MARK: - Refresh Profile (called after premium upgrade)
    func refreshProfile() async {
        guard let uid = currentUserID else { return }
        await loadProfile(uid: uid)
    }

    // MARK: - Private helpers
    private func loadProfile(uid: UUID) async {
        do {
            let result: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: uid.uuidString)
                .single()
                .execute()
                .value
            profile = result
        } catch {
            // Profile may not exist yet — created on first sign-up
        }
    }

    private func ensureProfile(user: User, name: String?) async {
        do {
            try await supabase
                .from("profiles")
                .upsert([
                    "id": user.id.uuidString,
                    "name": name ?? user.email ?? "Traveler",
                    "joined_at": ISO8601DateFormatter().string(from: Date())
                ])
                .execute()
            await loadProfile(uid: user.id)
        } catch {
            print("ensureProfile error: \(error)")
        }
    }

    private func fullName(from credential: ASAuthorizationAppleIDCredential) -> String? {
        guard let first = credential.fullName?.givenName else { return nil }
        let last = credential.fullName?.familyName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - UserProfile (matches Supabase `profiles` table)
struct UserProfile: Codable {
    let id: String
    var name: String?
    var avatarUrl: String?
    var isBusinessOwner: Bool
    var isPremium: Bool
    var premiumTier: String?
    var premiumStartedAt: String?
    var savedListingIds: [String]
    var joinedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarUrl          = "avatar_url"
        case isBusinessOwner    = "is_business_owner"
        case isPremium          = "is_premium"
        case premiumTier        = "premium_tier"
        case premiumStartedAt   = "premium_started_at"
        case savedListingIds    = "saved_listing_ids"
        case joinedAt           = "joined_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id               = try c.decode(String.self, forKey: .id)
        name             = try c.decodeIfPresent(String.self, forKey: .name)
        avatarUrl        = try c.decodeIfPresent(String.self, forKey: .avatarUrl)
        isBusinessOwner  = (try? c.decode(Bool.self, forKey: .isBusinessOwner)) ?? false
        isPremium        = (try? c.decode(Bool.self, forKey: .isPremium)) ?? false
        premiumTier      = try c.decodeIfPresent(String.self, forKey: .premiumTier)
        premiumStartedAt = try c.decodeIfPresent(String.self, forKey: .premiumStartedAt)
        savedListingIds  = (try? c.decode([String].self, forKey: .savedListingIds)) ?? []
        joinedAt         = try c.decodeIfPresent(String.self, forKey: .joinedAt)
    }
}
