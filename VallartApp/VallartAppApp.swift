import SwiftUI
import UIKit

// MARK: - AppDelegate — handles APNs token registration callbacks
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { await PushNotificationService.shared.saveToken(deviceToken) }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNs registration failed:", error.localizedDescription)
    }
}

// MARK: - App entry point
@main
struct VallartAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // 50 MB memory + 250 MB disk so AsyncImage doesn't re-fetch on every navigation
        URLCache.shared = URLCache(memoryCapacity: 50_000_000, diskCapacity: 250_000_000)
    }
    @StateObject private var auth = AuthService.shared
    @StateObject private var push = PushNotificationService.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showLoginAfterOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .environmentObject(auth)
                    .environmentObject(push)
                    .onOpenURL { url in
                        auth.handleURL(url)
                    }
                    .task {
                        await push.requestPermissionAndRegister()
                    }
                    .onChange(of: auth.isLoggedIn) { _, loggedIn in
                        if loggedIn {
                            Task {
                                await push.uploadPendingTokenIfNeeded()
                                await push.loadNotifications()
                            }
                        }
                    }
                    .sheet(isPresented: $showLoginAfterOnboarding) { LoginView() }
            } else {
                OnboardingView(
                    onSignUp: {
                        hasSeenOnboarding = true
                        showLoginAfterOnboarding = true
                    },
                    onGuest: {
                        hasSeenOnboarding = true
                    }
                )
            }
        }
    }
}
