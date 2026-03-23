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
    @StateObject private var auth = AuthService.shared
    @StateObject private var push = PushNotificationService.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(auth)
                .environmentObject(push)
                .onOpenURL { url in
                    auth.handleURL(url)
                }
                .task {
                    // Request push permission on first launch
                    await push.requestPermissionAndRegister()
                }
                .onChange(of: auth.isLoggedIn) { _, loggedIn in
                    if loggedIn {
                        Task {
                            // Upload any token saved before user signed in
                            await push.uploadPendingTokenIfNeeded()
                            // Load notification inbox
                            await push.loadNotifications()
                        }
                    }
                }
        }
    }
}
