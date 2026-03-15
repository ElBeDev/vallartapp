import SwiftUI

@main
struct VallartAppApp: App {
    // Eagerly init AuthService so session is restored before first view appears
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(auth)
                .onOpenURL { url in
                    // Handles: magic link sign-in, Google OAuth callback
                    // URL scheme: vallartapp://auth/callback?code=...
                    auth.handleURL(url)
                }
        }
    }
}
