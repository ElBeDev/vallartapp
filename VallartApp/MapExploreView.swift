import SwiftUI
import Combine
import MapKit

// MARK: - MapExploreView
struct MapExploreView: View {
    /// All listings passed in from ExploreViewModel — same data as Explore tab
    var listings: [Listing] = []
    @State private var selectedCategory: ListingCategory? = nil
    @State private var selectedListing: Listing? = nil
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.6534, longitude: -105.2253),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )

    /// Filter listings by selected category — no network call needed
    private var visibleListings: [Listing] {
        guard let cat = selectedCategory else { return listings }
        return listings.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(visibleListings) { listing in
                        Annotation(listing.name, coordinate: listing.coordinate) {
                            MapPinView(listing: listing)
                                .onTapGesture {
                                    selectedListing = listing
                                    // Animate camera to tapped pin
                                    withAnimation {
                                        cameraPosition = .region(MKCoordinateRegion(
                                            center: listing.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                        ))
                                    }
                                }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea(edges: .top)
                // Dismiss card when tapping the map
                .onTapGesture { selectedListing = nil }

                VStack(spacing: 0) {
                    // Category filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(ListingCategory.allCases) { cat in
                                FilterChip(title: cat.rawValue,
                                           icon: cat.icon,
                                           isSelected: selectedCategory == cat) {
                                    selectedCategory = cat
                                    selectedListing = nil
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                    }
                    .background(.ultraThinMaterial)

                    // Bottom preview card
                    if let listing = selectedListing {
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            MapPreviewCard(listing: listing)
                                .padding(AppTheme.Spacing.md)
                        }
                        .buttonStyle(.plain)
                        .background(.ultraThinMaterial)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Map")
            .navTitleMode(.inline)
            .animation(.spring(duration: 0.3), value: selectedListing?.id)
        }
    }
}

// MARK: - MapPinView
struct MapPinView: View {
    let listing: Listing

    var body: some View {
        ZStack {
            Circle()
                .fill(pinColor)
                .frame(width: 36, height: 36)
                .shadow(color: pinColor.opacity(0.4), radius: 4, y: 2)
            Image(systemName: listing.category.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var pinColor: Color {
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
}

// MARK: - MapPreviewCard
struct MapPreviewCard: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ListingImageView(
                urlString: listing.photos.first,
                width: 70, height: 70,
                cornerRadius: AppTheme.Radius.sm,
                fallbackColor: pinColor
            )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(listing.name)
                    .font(AppTheme.Font.label())
                    .foregroundStyle(AppTheme.Colors.deepNavy)
                    .lineLimit(1)
                Text(listing.neighborhood.rawValue)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.Colors.mediumGray)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.goldenSun)
                    Text(String(format: "%.1f", listing.rating))
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                    Text("(\(listing.reviewCount))")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                    Text("·")
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                    Text(listing.priceRange.symbol)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var pinColor: Color {
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
}
