import SwiftUI

// MARK: - MainTabView
struct MainTabView: View {
    @State private var selectedTab = 0
    /// Single source of truth for all listings — shared between Explore and Map
    @StateObject private var exploreVM = ExploreViewModel()

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

            SearchView()
                .tabItem { Label(String(localized: "tab.search"), systemImage: "magnifyingglass") }
                .tag(3)

            ProfileView()
                .tabItem { Label(String(localized: "tab.profile"), systemImage: "person.fill") }
                .tag(4)
        }
        .tint(AppTheme.Colors.coral)
    }
}
