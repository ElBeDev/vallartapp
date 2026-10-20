import SwiftUI
import MapKit

// MARK: - ListingDetailView
struct ListingDetailView: View {
    let listing: Listing
    @StateObject private var auth = AuthService.shared
    @State private var reviews: [Review] = []
    @State private var reviewsLoaded = false
    @AppStorage(ReviewModeration.blockedKey) private var blockedUserIDs = ""

    private var visibleReviews: [Review] {
        let blocked = ReviewModeration.blockedSet(blockedUserIDs)
        return reviews.filter { review in
            guard let uid = review.userID else { return true }
            return !blocked.contains(uid.uuidString)
        }
    }
    @State private var showDirectionsSheet = false
    @State private var showWriteReview = false
    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared

    var isSaved: Bool { auth.isSaved(listing.id) }

    private var shareContent: String {
        var lines = [listing.name, listing.neighborhood.displayName, listing.address]
        if let website = listing.website { lines.append(website) }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                heroSection

                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Title + meta
                    titleSection

                    Divider()

                    // Info grid
                    infoGrid

                    Divider()

                    // Inline map + navigate
                    locationSection

                    Divider()

                    // Description
                    descriptionSection

                    // Tags
                    FlowTagsView(tags: listing.tags)

                    Divider()

                    // Action buttons
                    actionButtons

                    // Reviews placeholder
                    reviewsSection

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
                .padding(AppTheme.Spacing.md)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navTitleMode(.inline)
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(listing: listing) { newReview in
                reviews.insert(newReview, at: 0)
            }
        }
        .confirmationDialog("Open directions in...", isPresented: $showDirectionsSheet, titleVisibility: .visible) {
            // Apple Maps
            Button("Apple Maps") {
                let q = listing.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let lat = listing.latitude, lon = listing.longitude
                if let url = URL(string: "maps://?daddr=\(lat),\(lon)&q=\(q)") {
                    UIApplication.shared.open(url)
                }
            }
            // Google Maps
            Button("Google Maps") {
                let lat = listing.latitude, lon = listing.longitude
                let name = listing.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&q=\(name)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else if let web = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)") {
                    UIApplication.shared.open(web)
                }
            }
            // Waze
            Button("Waze") {
                let lat = listing.latitude, lon = listing.longitude
                if let url = URL(string: "waze://?ll=\(lat),\(lon)&navigate=yes"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else if let web = URL(string: "https://waze.com/ul?ll=\(lat),\(lon)&navigate=yes") {
                    UIApplication.shared.open(web)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            if !reviewsLoaded {
                reviews = (try? await repo.fetchReviews(for: listing.id)) ?? []
                reviewsLoaded = true
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: shareContent) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                Button {
                    Haptic.medium()
                    Task { await auth.toggleSaved(listingID: listing.id) }
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? AppTheme.Colors.coral : .white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
            }
        }
    }

    // MARK: Hero
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            let w = UIScreen.main.bounds.width
            if listing.photos.count > 1 {
                TabView {
                    ForEach(listing.photos, id: \.self) { urlString in
                        ListingImageView(
                            urlString: urlString,
                            width: w,
                            height: 300,
                            cornerRadius: 0,
                            fallbackColor: categoryColor
                        )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 300)
            } else {
                ListingImageView(
                    urlString: listing.photos.first,
                    width: w,
                    height: 300,
                    cornerRadius: 0,
                    fallbackColor: categoryColor
                )
            }

            // Bottom gradient for badge readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center, endPoint: .bottom
            )
            .frame(height: 300)

            HStack(spacing: AppTheme.Spacing.xs) {
                BadgeView(text: listing.category.rawValue, color: .white.opacity(0.85), textColor: AppTheme.Colors.deepNavy)
                if listing.isPremium {
                    BadgeView(text: "Premium", color: AppTheme.Colors.goldenSun, textColor: AppTheme.Colors.deepNavy)
                }
                if listing.isFeatured {
                    BadgeView(text: "Editor's Pick", color: AppTheme.Colors.teal, textColor: .white)
                }
                if listing.isLGBTFriendly {
                    BadgeView(text: "LGBT+", color: AppTheme.Colors.nightPurple, textColor: .white)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [categoryColor, categoryColor.opacity(0.6)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var categoryColor: Color { listing.category.color }

    // MARK: Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(listing.name)
                .font(AppTheme.Font.display(26))
                .foregroundStyle(AppTheme.Colors.deepNavy)

            HStack(spacing: AppTheme.Spacing.sm) {
                // Rating
                HStack(spacing: 4) {
                    StarRatingView(rating: listing.rating, size: 13)
                    Text(String(format: "%.1f", listing.rating))
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                    Text("(\(listing.reviewCount) reviews)")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }

                Text("·")
                    .foregroundStyle(AppTheme.Colors.mediumGray)

                Text(listing.priceRange.symbol)
                    .font(AppTheme.Font.label())
                    .foregroundStyle(AppTheme.Colors.mediumGray)
            }

            // Open status
            HStack(spacing: AppTheme.Spacing.xs) {
                Circle()
                    .fill(listing.isOpen ? AppTheme.Colors.palmGreen : AppTheme.Colors.coral)
                    .frame(width: 8, height: 8)
                Text(listing.isOpen ? "Open" : "Closed")
                    .font(AppTheme.Font.label())
                    .foregroundStyle(listing.isOpen ? AppTheme.Colors.palmGreen : AppTheme.Colors.coral)
                if let hours = listing.openHours {
                    Text("· \(hours)")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
            }
        }
    }

    // MARK: Info Grid
    private var infoGrid: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            InfoRow(icon: "mappin.circle.fill", text: listing.address, color: AppTheme.Colors.coral)
            InfoRow(icon: "location.fill", text: listing.neighborhood.displayName, color: AppTheme.Colors.teal)
            if let phone = listing.phone {
                InfoRow(icon: "phone.fill", text: phone, color: AppTheme.Colors.palmGreen)
            }
            if let website = listing.website {
                InfoRow(icon: "globe", text: website, color: AppTheme.Colors.oceanBlue)
            }
            if let ig = listing.instagram {
                InfoRow(icon: "camera.fill", text: ig, color: AppTheme.Colors.nightPurple)
            }
        }
    }

    // MARK: Location (inline map + navigate)
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Location")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)

            // Mini map
            let coord = CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)
            let region = MKCoordinateRegion(center: coord,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            Map(initialPosition: .region(region)) {
                Annotation(listing.name, coordinate: coord) {
                    ZStack {
                        Circle()
                            .fill(categoryColor)
                            .frame(width: 36, height: 36)
                            .shadow(color: categoryColor.opacity(0.4), radius: 4, y: 2)
                        Image(systemName: listing.category.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .disabled(true) // non-interactive — tap Navigate instead

            // Address + Navigate button side by side
            HStack(spacing: AppTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.address)
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                    Text(listing.neighborhood.displayName)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
                Spacer()
                Button { showDirectionsSheet = true } label: {
                    Label("Navigate", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                        .font(AppTheme.Font.label())
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.coral)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: Description
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("About")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text(listing.description)
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.deepNavy.opacity(0.8))
                .lineSpacing(5)
        }
    }

    // MARK: Action Buttons
    private var actionButtons: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            if let phone = listing.phone, let url = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                Link(destination: url) {
                    ActionButtonView(icon: "phone.fill", title: "Call", color: AppTheme.Colors.palmGreen)
                }
            }
            if let website = listing.website, let url = URL(string: website) {
                Link(destination: url) {
                    ActionButtonView(icon: "globe", title: "Website", color: AppTheme.Colors.oceanBlue)
                }
            }
            if let ig = listing.instagram, let url = URL(string: "https://instagram.com/\(ig.replacingOccurrences(of: "@", with: ""))") {
                Link(destination: url) {
                    ActionButtonView(icon: "camera.fill", title: "Instagram", color: AppTheme.Colors.nightPurple)
                }
            }
        }
    }

    // MARK: Reviews
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Reviews")
                    .font(AppTheme.Font.headline())
                    .foregroundStyle(AppTheme.Colors.deepNavy)
                Spacer()
                Button {
                    showWriteReview = true
                } label: {
                    Label("Write a Review", systemImage: "square.and.pencil")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }

            if reviews.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(reviewsLoaded ? "No reviews yet. Be the first!" : "Loading reviews...")
                        .font(AppTheme.Font.body())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                    if reviewsLoaded {
                        Button {
                            showWriteReview = true
                        } label: {
                            Text("Write the first review")
                                .font(AppTheme.Font.label())
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.sm)
                                .background(AppTheme.Colors.coral)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            } else {
                ForEach(visibleReviews.prefix(5)) { review in
                    ReviewRowView(review: review)
                }
            }
        }
    }
}

// MARK: - CategoryListView
struct CategoryListView: View {
    let category: ListingCategory
    @State private var listings: [Listing] = []
    @State private var isLoading = true
    @State private var selectedNeighborhood: Neighborhood? = nil
    @State private var openOnly = false
    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared

    private var filteredListings: [Listing] {
        listings.filter { listing in
            (selectedNeighborhood == nil || listing.neighborhood == selectedNeighborhood) &&
            (!openOnly || listing.isOpen)
        }
    }

    // Only show neighborhoods that actually appear in the fetched listings
    private var availableNeighborhoods: [Neighborhood] {
        Array(Set(listings.map { $0.neighborhood })).sorted { $0.displayName < $1.displayName }
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.sand.ignoresSafeArea()
            VStack(spacing: 0) {
                if !listings.isEmpty {
                    filterBar
                }
                if isLoading {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(0..<5, id: \.self) { _ in
                                ListingRowSkeleton().padding(.horizontal, AppTheme.Spacing.md)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.md)
                    }
                } else if filteredListings.isEmpty {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 52))
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                        Text("No places match your filters")
                            .font(AppTheme.Font.headline())
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                        Button {
                            selectedNeighborhood = nil
                            openOnly = false
                        } label: {
                            Text("Clear filters")
                                .font(AppTheme.Font.label())
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.sm)
                                .background(AppTheme.Colors.coral)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    ListingRowView(listing: listing)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppTheme.Spacing.md)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.md)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                    }
                }
            }
        }
        .navigationTitle(category.rawValue)
        .navTitleMode(.large)
        .task {
            do {
                listings = try await repo.fetchByCategory(category)
            } catch {
                listings = []
            }
            isLoading = false
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                FilterChip(title: "All", isSelected: selectedNeighborhood == nil && !openOnly) {
                    selectedNeighborhood = nil
                    openOnly = false
                }
                FilterChip(title: "Open Now", icon: "clock", isSelected: openOnly) {
                    openOnly.toggle()
                }
                ForEach(availableNeighborhoods, id: \.self) { hood in
                    FilterChip(title: hood.displayName, isSelected: selectedNeighborhood == hood) {
                        selectedNeighborhood = selectedNeighborhood == hood ? nil : hood
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - ReviewRowView
// Report / block for user-generated reviews (App Store guideline 1.2).
// Blocks are per-device; reports go to support by email.
enum ReviewModeration {
    static let blockedKey = "blockedReviewUserIDs"

    static func blockedSet(_ raw: String) -> Set<String> {
        Set(raw.split(separator: ",").map(String.init))
    }

    static func reportURL(for review: Review) -> URL? {
        var c = URLComponents()
        c.scheme = "mailto"
        c.path = AppConfig.supportEmail
        c.queryItems = [
            URLQueryItem(name: "subject", value: "Report review \(review.id.uuidString)"),
            URLQueryItem(name: "body", value: "Review by \(review.authorName):\n\"\(review.text)\"\n\nReason: ")
        ]
        return c.url
    }
}

struct ReviewRowView: View {
    let review: Review
    @AppStorage(ReviewModeration.blockedKey) private var blockedUserIDs = ""
    @Environment(\.openURL) private var openURL
    @State private var showBlockConfirm = false

    private var canBlock: Bool {
        guard let uid = review.userID else { return false }
        return uid != AuthService.shared.currentUserID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: review.authorAvatar)
                    .font(.system(size: 32))
                    .foregroundStyle(AppTheme.Colors.teal)
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorName)
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                    Text(review.formattedDate)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
                Spacer()
                HStack(spacing: 2) {
                    StarRatingView(rating: review.rating, size: 10)
                    Text(String(format: "%.1f", review.rating))
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                }
                Menu {
                    Button {
                        if let url = ReviewModeration.reportURL(for: review) { openURL(url) }
                    } label: {
                        Label(String(localized: "review.report"), systemImage: "flag")
                    }
                    if canBlock {
                        Button(role: .destructive) { showBlockConfirm = true } label: {
                            Label(String(localized: "review.block"), systemImage: "hand.raised")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(String(localized: "review.options"))
            }
            Text(review.text)
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.deepNavy.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .confirmationDialog(String(localized: "review.block.title"), isPresented: $showBlockConfirm, titleVisibility: .visible) {
            Button(String(localized: "review.block"), role: .destructive) {
                guard let uid = review.userID?.uuidString else { return }
                var blocked = ReviewModeration.blockedSet(blockedUserIDs)
                blocked.insert(uid)
                blockedUserIDs = blocked.joined(separator: ",")
                Haptic.success()
            }
        } message: {
            Text(String(localized: "review.block.message"))
        }
    }
}

// MARK: - InfoRow
struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(color)
            Text(text)
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.deepNavy)
                .lineLimit(1)
        }
    }
}

// MARK: - ActionButtonView
struct ActionButtonView: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
            Text(title)
                .font(AppTheme.Font.caption())
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.sm)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
