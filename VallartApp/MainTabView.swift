import SwiftUI

// MARK: - MainTabView
struct MainTabView: View {
    @State private var selectedTab = 0
    /// Single source of truth for all listings — shared between Explore and Map
    @StateObject private var exploreVM = ExploreViewModel()
    @EnvironmentObject private var push: PushNotificationService

    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView(vm: exploreVM)
                .tabItem { Label(String(localized: "tab.explore"), systemImage: "safari.fill") }
                .tag(0)

            MapExploreView(listings: exploreVM.popularListings)
                .tabItem { Label(String(localized: "tab.map"), systemImage: "map.fill") }
                .tag(1)

            EventsView()
                .tabItem { Label(String(localized: "tab.events"), systemImage: "calendar") }
                .tag(2)

            NotificationsView()
                .tabItem { Label(String(localized: "tab.notifications"), systemImage: "bell.fill") }
                .badge(push.unreadCount > 0 ? push.unreadCount : 0)
                .tag(3)

            SearchView()
                .tabItem { Label(String(localized: "tab.search"), systemImage: "magnifyingglass") }
                .tag(4)

            ProfileView()
                .tabItem { Label(String(localized: "tab.profile"), systemImage: "person.fill") }
                .tag(5)
        }
        .tint(AppTheme.Colors.coral)
    }
}
