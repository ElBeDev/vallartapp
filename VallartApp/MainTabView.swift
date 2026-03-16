import SwiftUI

// MARK: - MainTabView
struct MainTabView: View {
    @State private var selectedTab = 0
    /// Single source of truth for all listings — shared between Explore and Map
    @StateObject private var exploreVM = ExploreViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView(vm: exploreVM)
                .tabItem { Label("Explore", systemImage: "safari.fill") }
                .tag(0)

            MapExploreView(listings: exploreVM.popularListings)
                .tabItem { Label("Map", systemImage: "map.fill") }
                .tag(1)

            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }
                .tag(2)

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .tint(AppTheme.Colors.coral)
    }
}
