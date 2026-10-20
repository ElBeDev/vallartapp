import SwiftUI
import Combine

// MARK: - ExploreView
struct ExploreView: View {
    @ObservedObject var vm: ExploreViewModel
    @State private var selectedCategory: ListingCategory? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.Colors.sand.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        headerView
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.top, AppTheme.Spacing.lg)

                        // Category Grid
                        categoryGrid
                            .padding(.top, AppTheme.Spacing.md)

                        // Featured Banner
                        featuredSection
                            .padding(.top, AppTheme.Spacing.lg)

                        // Trending Now
                        if !vm.trendingListings.isEmpty || vm.isLoading {
                            trendingSection
                                .padding(.top, AppTheme.Spacing.lg)
                        }

                        // Upcoming Events
                        upcomingEventsSection
                            .padding(.top, AppTheme.Spacing.lg)

                        // All Listings
                        allListingsSection
                            .padding(.top, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.xxl)
                    }
                }
                .refreshable { await vm.load() }

                if let errorMsg = vm.errorMessage {
                    VStack {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            Text(errorMsg)
                                .font(AppTheme.Font.label())
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Spacer()
                            Button {
                                withAnimation(.spring(duration: 0.3)) { vm.errorMessage = nil }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.coral)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .shadow(color: AppTheme.Colors.coral.opacity(0.4), radius: 8, y: 4)
                        Spacer()
                    }
                    .padding(.top, AppTheme.Spacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
                }
            }
            .animation(.spring(duration: 0.3), value: vm.errorMessage != nil)
            .navBarHidden(true)
        }
    }

    // MARK: Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(timeGreeting)
                .font(AppTheme.Font.caption())
                .foregroundStyle(AppTheme.Colors.mediumGray)
            Text(String(localized: "explore.title"))
                .font(AppTheme.Font.display(30))
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text(String(localized: "explore.subtitle"))
                .font(AppTheme.Font.headline(18))
                .foregroundStyle(AppTheme.Colors.coral)
        }
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return String(localized: "explore.greeting.morning")
        case 12..<19: return String(localized: "explore.greeting.afternoon")
        default:      return String(localized: "explore.greeting.evening")
        }
    }

    // MARK: Category Grid
    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(String(localized: "explore.section.explore"))
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
                .padding(.horizontal, AppTheme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(ListingCategory.allCases) { cat in
                        NavigationLink(destination: CategoryListView(category: cat)) {
                            CategoryChipView(category: cat, isSelected: selectedCategory == cat)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeaderView(title: String(localized: "explore.section.featured"), subtitle: "Editor's picks")
                .padding(.horizontal, AppTheme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    if vm.isLoading {
                        ForEach(0..<3, id: \.self) { _ in FeaturedCardSkeleton() }
                    } else {
                        ForEach(vm.featuredListings) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                FeaturedCardView(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: Trending Now
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeaderView(title: "Trending Now", subtitle: "Most reviewed this week")
                .padding(.horizontal, AppTheme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    if vm.isLoading {
                        ForEach(0..<3, id: \.self) { _ in FeaturedCardSkeleton() }
                    } else {
                        ForEach(vm.trendingListings) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                FeaturedCardView(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: Upcoming Events
    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeaderView(title: String(localized: "explore.section.events"), subtitle: "Don't miss out")
                .padding(.horizontal, AppTheme.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(vm.featuredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventCardView(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: All Listings
    private var allListingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeaderView(title: String(localized: "explore.section.all"), subtitle: "Top rated in PV")
                .padding(.horizontal, AppTheme.Spacing.md)

            LazyVStack(spacing: AppTheme.Spacing.sm) {
                if vm.isLoading {
                    ForEach(0..<5, id: \.self) { _ in
                        ListingRowSkeleton()
                            .padding(.horizontal, AppTheme.Spacing.md)
                    }
                } else {
                    ForEach(vm.popularListings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            ListingRowView(listing: listing)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppTheme.Spacing.md)
                    }
                    // Infinite scroll trigger
                    if vm.canLoadMore {
                        HStack {
                            if vm.isLoadingMore { ProgressView() }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .onAppear { Task { await vm.loadNextPage() } }
                    }
                }
            }
        }
    }
}

// MARK: - ExploreViewModel
class ExploreViewModel: ObservableObject {
    @Published var featuredListings: [Listing] = []
    @Published var featuredEvents: [Event] = []
    @Published var popularListings: [Listing] = []
    @Published var trendingListings: [Listing] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var canLoadMore = true
    @Published var errorMessage: String?

    private let pageSize = 20
    private let listingRepo: ListingRepositoryProtocol = SupabaseListingRepository.shared
    private let eventRepo: EventRepositoryProtocol     = SupabaseEventRepository.shared

    init() { Task { await load() } }

    @MainActor
    func load() async {
        isLoading = true
        canLoadMore = true
        errorMessage = nil
        do {
            async let featured  = listingRepo.fetchFeatured()
            async let popular   = listingRepo.fetchPage(offset: 0, limit: pageSize)
            async let events    = eventRepo.fetchFeatured()
            async let trending  = listingRepo.fetchTrending(limit: 10)
            featuredListings  = try await featured
            popularListings   = try await popular
            featuredEvents    = try await events
            trendingListings  = try await trending
            canLoadMore = popularListings.count == pageSize
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func loadNextPage() async {
        guard !isLoadingMore && canLoadMore else { return }
        isLoadingMore = true
        do {
            let next = try await listingRepo.fetchPage(offset: popularListings.count, limit: pageSize)
            popularListings.append(contentsOf: next)
            canLoadMore = next.count == pageSize
        } catch {}
        isLoadingMore = false
    }
}
