import SwiftUI

// MARK: - NotificationsView
// Tab 3 replacement for Events, or reached from the Profile bell icon.
// Shows: permission banner (if not granted) + inbox of AppNotifications.
struct NotificationsView: View {
    @EnvironmentObject private var push: PushNotificationService
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()

                if !auth.isLoggedIn {
                    guestPrompt
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            .navTitleMode(.large)
            .toolbar {
                if !push.notifications.isEmpty && push.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Mark all read") {
                            Task { await push.markAllRead() }
                        }
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.teal)
                    }
                }
            }
            .task {
                if auth.isLoggedIn { await push.loadNotifications() }
            }
            .refreshable {
                if auth.isLoggedIn { await push.loadNotifications() }
            }
        }
    }

    // MARK: - Permission Banner
    @ViewBuilder
    private var permissionBanner: some View {
        if push.permissionStatus == .denied || push.permissionStatus == .notDetermined {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.Colors.coral)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable notifications")
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                    Text("Get alerts for new events & exclusive deals")
                        .font(AppTheme.Font.caption(12))
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
                Spacer()
                if push.permissionStatus == .notDetermined {
                    Button("Allow") {
                        Task { await push.requestPermissionAndRegister() }
                    }
                    .font(AppTheme.Font.label(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.teal)
                    .clipShape(Capsule())
                } else {
                    Button("Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(AppTheme.Font.label(13))
                    .foregroundStyle(AppTheme.Colors.teal)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    // MARK: - Notification List
    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                permissionBanner
                    .padding(.top, AppTheme.Spacing.md)

                if push.notifications.isEmpty {
                    emptyState
                } else {
                    ForEach(push.notifications) { notif in
                        NotificationRow(notification: notif)
                            .onTapGesture {
                                if !notif.isRead {
                                    Task { await push.markRead(notif.id) }
                                }
                            }
                        if notif.id != push.notifications.last?.id {
                            Divider().padding(.leading, 68)
                        }
                    }
                }
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
        .background(AppTheme.Colors.sand)
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer(minLength: 60)
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.teal.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "bell.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppTheme.Colors.teal.opacity(0.5))
            }
            Text("No notifications yet")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text("We'll let you know about new events,\nexclusive deals and more.")
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.mediumGray)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.xl)
    }

    // MARK: - Guest prompt
    private var guestPrompt: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.teal.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppTheme.Colors.teal)
            }
            Text("Sign in for notifications")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text("Get personalized alerts for new events,\nexclusive deals and your favorite spots.")
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.mediumGray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - NotificationRow
struct NotificationRow: View {
    let notification: AppNotification

    private var timeAgo: String {
        guard let date = ISO8601DateFormatter().date(from: notification.createdAt) else { return "" }
        let diff = Date().timeIntervalSince(date)
        switch diff {
        case ..<60:          return "Just now"
        case ..<3600:        return "\(Int(diff/60))m ago"
        case ..<86400:       return "\(Int(diff/3600))h ago"
        default:             return "\(Int(diff/86400))d ago"
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case "new_event":  return AppTheme.Colors.teal
        case "promo":      return AppTheme.Colors.goldenSun
        case "review":     return AppTheme.Colors.coral
        default:           return AppTheme.Colors.nightPurple
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.typeIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                        .lineLimit(1)
                    Spacer()
                    if !notification.isRead {
                        Circle()
                            .fill(AppTheme.Colors.teal)
                            .frame(width: 8, height: 8)
                    }
                }
                Text(notification.body)
                    .font(AppTheme.Font.body())
                    .foregroundStyle(AppTheme.Colors.mediumGray)
                    .lineLimit(2)
                Text(timeAgo)
                    .font(AppTheme.Font.caption(11))
                    .foregroundStyle(AppTheme.Colors.mediumGray.opacity(0.7))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm + 4)
        .background(notification.isRead ? Color.clear : AppTheme.Colors.teal.opacity(0.04))
    }
}
