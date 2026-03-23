import Foundation
import Combine
import UserNotifications
import UIKit
import Supabase

// MARK: - PushNotificationService
// Handles APNs registration, permission prompt, token save to Supabase,
// and foreground notification display.
@MainActor
final class PushNotificationService: ObservableObject {

    static let shared = PushNotificationService()

    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0

    private let delegate = PushDelegate()

    private init() {
        UNUserNotificationCenter.current().delegate = delegate
    }

    // MARK: - Request permission + register
    func requestPermissionAndRegister() async {
        let center = UNUserNotificationCenter.current()

        let settings = await center.notificationSettings()
        permissionStatus = settings.authorizationStatus

        if settings.authorizationStatus == .notDetermined {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                permissionStatus = granted ? .authorized : .denied
                if granted {
                    await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
                }
            } catch {
                print("PushNotification permission error:", error)
            }
        } else if settings.authorizationStatus == .authorized {
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        }
    }

    // MARK: - Save APNs token to Supabase
    func saveToken(_ tokenData: Data) async {
        let token = tokenData.map { String(format: "%02x", $0) }.joined()
        guard let uid = AuthService.shared.currentUserID?.uuidString else {
            // Store locally and retry when user signs in
            UserDefaults.standard.set(token, forKey: "pendingPushToken")
            return
        }
        await uploadToken(token, userID: uid)
    }

    func uploadPendingTokenIfNeeded() async {
        guard let token = UserDefaults.standard.string(forKey: "pendingPushToken"),
              let uid   = AuthService.shared.currentUserID?.uuidString else { return }
        await uploadToken(token, userID: uid)
        UserDefaults.standard.removeObject(forKey: "pendingPushToken")
    }

    private func uploadToken(_ token: String, userID: String) async {
        do {
            let platform = "ios"
            let bundle   = Bundle.main.bundleIdentifier ?? "com.vallartapp"
            try await supabase
                .from("device_tokens")
                .upsert([
                    "user_id":  userID,
                    "token":    token,
                    "platform": platform,
                    "bundle_id": bundle,
                    "updated_at": ISO8601DateFormatter().string(from: Date())
                ], onConflict: "user_id,token")
                .execute()
            print("Push token saved:", token.prefix(12), "...")
        } catch {
            print("saveToken error:", error)
        }
    }

    // MARK: - Load notifications from Supabase
    func loadNotifications() async {
        guard let uid = AuthService.shared.currentUserID?.uuidString else { return }
        do {
            let result: [AppNotification] = try await supabase
                .from("notifications")
                .select()
                .or("user_id.eq.\(uid),user_id.is.null")   // user-specific + broadcast
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            notifications = result
            unreadCount   = result.filter { !$0.isRead }.count
        } catch {
            print("loadNotifications error:", error)
        }
    }

    // MARK: - Mark all as read
    func markAllRead() async {
        guard let uid = AuthService.shared.currentUserID?.uuidString else { return }
        do {
            try await supabase
                .from("notifications")
                .update(["is_read": true])
                .or("user_id.eq.\(uid),user_id.is.null")
                .eq("is_read", value: false)
                .execute()
            notifications = notifications.map {
                var n = $0; n.isRead = true; return n
            }
            unreadCount = 0
        } catch {
            print("markAllRead error:", error)
        }
    }

    // MARK: - Mark single as read
    func markRead(_ id: String) async {
        do {
            try await supabase
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: id)
                .execute()
            if let i = notifications.firstIndex(where: { $0.id == id }) {
                notifications[i].isRead = true
            }
            unreadCount = max(0, unreadCount - 1)
        } catch {
            print("markRead error:", error)
        }
    }

    // MARK: - Update badge count
    func updateBadge(_ count: Int) async {
        do {
            try await UNUserNotificationCenter.current()
                .setBadgeCount(count)
        } catch {
            print("setBadgeCount error:", error)
        }
    }
}

// MARK: - PushDelegate
// Separate NSObject subclass for UNUserNotificationCenterDelegate callbacks
final class PushDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Show notifications while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let listingID = userInfo["listing_id"] as? String {
            print("Push tapped → listing:", listingID)
        } else if let eventID = userInfo["event_id"] as? String {
            print("Push tapped → event:", eventID)
        }
        completionHandler()
    }
}

// MARK: - AppNotification model
struct AppNotification: Codable, Identifiable {
    let id: String
    var title: String
    var body: String
    var type: String          // "new_event" | "promo" | "review" | "broadcast"
    var isRead: Bool
    var listingId: String?
    var eventId: String?
    var createdAt: String

    var typeIcon: String {
        switch type {
        case "new_event":  return "calendar.badge.plus"
        case "promo":      return "tag.fill"
        case "review":     return "star.fill"
        case "broadcast":  return "megaphone.fill"
        default:           return "bell.fill"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, body, type
        case isRead     = "is_read"
        case listingId  = "listing_id"
        case eventId    = "event_id"
        case createdAt  = "created_at"
    }
}
