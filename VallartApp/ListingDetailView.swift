import SwiftUI

// MARK: - ListingDetailView
struct ListingDetailView: View {
    let listing: Listing
    @StateObject private var auth = AuthService.shared
    @State private var reviews: [Review] = []
    @State private var reviewsLoaded = false
    @State private var showDirectionsSheet = false
    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared

    var isSaved: Bool { auth.isSaved(listing.id) }

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
            ToolbarItem(placement: .automatic) {
                Button {
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
            RoundedRectangle(cornerRadius: 0)
                .fill(categoryGradient)
                .frame(height: 300)
                .overlay {
                    Image(systemName: listing.heroPhoto)
                        .font(.system(size: 90))
                        .foregroundStyle(.white.opacity(0.3))
                }

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

    private var categoryColor: Color {
        switch listing.category {
        case .restaurants: return AppTheme.Colors.coral
        case .bars:        return AppTheme.Colors.nightPurple
        case .hotels:      return AppTheme.Colors.deepNavy
        case .activities:  return AppTheme.Colors.teal
        case .yachts:      return AppTheme.Colors.oceanBlue
        case .rentals:     return AppTheme.Colors.goldenSun
        case .events:      return AppTheme.Colors.coral
        case .beaches:     return AppTheme.Colors.teal
        case .shopping:    return AppTheme.Colors.deepNavy
        case .spas:        return AppTheme.Colors.palmGreen
        }
    }

    // MARK: Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(listing.name)
                .font(AppTheme.Font.display(26))
                .foregroundStyle(AppTheme.Colors.deepNavy)

            HStack(spacing: AppTheme.Spacing.sm) {
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(AppTheme.Colors.goldenSun)
                        .font(.caption)
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
            InfoRow(icon: "location.fill", text: listing.neighborhood.rawValue, color: AppTheme.Colors.teal)
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
            Button { showDirectionsSheet = true } label: {
                ActionButtonView(icon: "map.fill", title: "Directions", color: AppTheme.Colors.coral)
            }
        }
    }

    // MARK: Reviews
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Reviews")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)

            if reviews.isEmpty {
                Text(reviewsLoaded ? "No reviews yet. Be the first!" : "Loading reviews...")
                    .font(AppTheme.Font.body())
                    .foregroundStyle(AppTheme.Colors.mediumGray)
            } else {
                ForEach(reviews.prefix(5)) { review in
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
    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.sand.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(listings) { listing in
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
        .navigationTitle(category.rawValue)
        .navTitleMode(.large)
        .task {
            do {
                listings = try await repo.fetchByCategory(category)
            } catch {
                listings = MockDataService.shared.listings(for: category)
            }
            isLoading = false
        }
    }
}

// MARK: - ReviewRowView
struct ReviewRowView: View {
    let review: Review

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
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.goldenSun)
                    Text(String(format: "%.1f", review.rating))
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                }
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
