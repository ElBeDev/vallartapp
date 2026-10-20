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

            MapExploreView()
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
        .sheet(item: $push.pendingDeepLink) { target in
            DeepLinkDetailView(target: target)
        }
#if DEBUG
        // App Store screenshots: `-screenshotTab <n>` / `-screenshotListing <uuid>` launch arguments
        .onAppear {
            let args = UserDefaults.standard
            selectedTab = args.integer(forKey: "screenshotTab")
            if let id = args.string(forKey: "screenshotListing").flatMap(UUID.init(uuidString:)) {
                push.pendingDeepLink = .listing(id)
            }
        }
#endif
    }
}

// MARK: - DeepLinkDetailView
// Fetches listing or event by ID and presents the appropriate detail view.
struct DeepLinkDetailView: View {
    let target: DeepLinkTarget
    @State private var listing: Listing?
    @State private var event: Event?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.Colors.sand)
                } else if let listing {
                    ListingDetailView(listing: listing)
                } else if let event {
                    EventDetailView(event: event)
                } else {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                        Text("Content not found")
                            .font(AppTheme.Font.headline())
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.Colors.sand)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
        }
        .task { await fetchContent() }
    }

    private func fetchContent() async {
        switch target {
        case .listing(let id):
            listing = try? await SupabaseListingRepository.shared.fetchByID(id)
        case .event(let id):
            event = try? await SupabaseEventRepository.shared.fetchByID(id)
        }
        isLoading = false
    }
}
