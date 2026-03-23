import SwiftUI
import Supabase

// MARK: - CategoryChipView
struct CategoryChipView: View {
    let category: ListingCategory
    let isSelected: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.Colors.coral : AppTheme.Colors.white)
                    .frame(width: 56, height: 56)
                    .shadow(color: isSelected ? AppTheme.Colors.coral.opacity(0.3) : .black.opacity(0.06), radius: 4, y: 2)
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : AppTheme.Colors.deepNavy)
            }
            Text(category.rawValue)
                .font(AppTheme.Font.caption(11))
                .foregroundStyle(isSelected ? AppTheme.Colors.coral : AppTheme.Colors.deepNavy)
                .lineLimit(1)
                .frame(width: 70)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - CategoryGridCard
struct CategoryGridCard: View {
    let category: ListingCategory

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(cardGradient)
                .frame(height: 110)
                .shadow(color: cardColor.opacity(0.25), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                Text(category.rawValue)
                    .font(AppTheme.Font.label(13))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    private var cardColor: Color {
        switch category {
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

    private var cardGradient: LinearGradient {
        LinearGradient(colors: [cardColor, cardColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - ListingImageView  (AsyncImage with gradient overlay + fallback)
struct ListingImageView: View {
    let urlString: String?
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 0
    var fallbackColor: Color = AppTheme.Colors.deepNavy

    var body: some View {
        ZStack {
            if let str = urlString, let url = URL(string: str) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                    case .failure:
                        fallbackView
                    case .empty:
                        ZStack {
                            fallbackColor.opacity(0.3)
                            ProgressView().tint(.white)
                        }
                        .frame(width: width, height: height)
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var fallbackView: some View {
        fallbackColor.opacity(0.25)
            .frame(width: width, height: height)
    }
}

// MARK: - FeaturedCardView
struct FeaturedCardView: View {
    let listing: Listing

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Real photo
            ListingImageView(
                urlString: listing.photos.first,
                width: 280, height: 180,
                cornerRadius: AppTheme.Radius.xl,
                fallbackColor: cardColor
            )

            // Dark gradient so text is always readable
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top, endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
            .frame(width: 280, height: 180)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                if listing.isFeatured {
                    BadgeView(text: "Editor's Pick", color: AppTheme.Colors.goldenSun, textColor: AppTheme.Colors.deepNavy)
                }
                Text(listing.name)
                    .font(AppTheme.Font.headline())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.goldenSun)
                    Text(String(format: "%.1f", listing.rating))
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(.white)
                    Text("·")
                        .foregroundStyle(.white.opacity(0.6))
                    Text(listing.neighborhood.displayName)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .frame(width: 280, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
        .shadow(color: cardColor.opacity(0.3), radius: 8, y: 4)
    }

    private var cardColor: Color {
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

// MARK: - ListingRowView
struct ListingRowView: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Thumbnail with real photo
            ListingImageView(
                urlString: listing.photos.first,
                width: 64, height: 64,
                cornerRadius: AppTheme.Radius.md,
                fallbackColor: iconColor
            )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text(listing.name)
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                        .lineLimit(1)
                    if listing.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.Colors.goldenSun)
                    }
                }
                Text("\(listing.category.rawValue) · \(listing.neighborhood.displayName)")
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
                    Spacer()
                    Circle()
                        .fill(listing.isOpen ? AppTheme.Colors.palmGreen : AppTheme.Colors.coral)
                        .frame(width: 6, height: 6)
                    Text(listing.isOpen ? "Open" : "Closed")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(listing.isOpen ? AppTheme.Colors.palmGreen : AppTheme.Colors.coral)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var iconColor: Color {
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

// MARK: - EventCardView
struct EventCardView: View {
    let event: Event

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                .fill(LinearGradient(
                    colors: [AppTheme.Colors.coral, AppTheme.Colors.nightPurple.opacity(0.8)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 220, height: 140)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    BadgeView(text: event.isPublic ? "Public" : "Private",
                              color: .white.opacity(0.25),
                              textColor: .white)
                    if event.isFree { BadgeView(text: "Free", color: AppTheme.Colors.teal, textColor: .white) }
                }
                Text(event.title)
                    .font(AppTheme.Font.label())
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(event.formattedDate)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(AppTheme.Spacing.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
        .shadow(color: AppTheme.Colors.coral.opacity(0.25), radius: 6, y: 3)
    }
}

// MARK: - BadgeView
struct BadgeView: View {
    let text: String
    let color: Color
    /// Override text color — if nil, auto-picks white or deepNavy based on background luminance
    var textColor: Color? = nil

    var body: some View {
        Text(text)
            .font(AppTheme.Font.caption(10))
            .foregroundStyle(resolvedTextColor)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }

    /// Returns white for dark backgrounds, deepNavy for light backgrounds
    private var resolvedTextColor: Color {
        if let override = textColor { return override }
        return color.isLight ? AppTheme.Colors.deepNavy : .white
    }
}

// MARK: - FilterChip
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(title)
                    .font(AppTheme.Font.label(13))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.Colors.deepNavy)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.Colors.coral : AppTheme.Colors.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }
}

// MARK: - ActiveFilterChip
struct ActiveFilterChip: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(AppTheme.Font.caption())
                .foregroundStyle(AppTheme.Colors.coral)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.coral)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 5)
        .background(AppTheme.Colors.coral.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - SectionHeaderView
struct SectionHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text(subtitle)
                .font(AppTheme.Font.caption())
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
    }
}

// MARK: - FlowTagsView
struct FlowTagsView: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80, maximum: 160))],
            alignment: .leading,
            spacing: AppTheme.Spacing.xs
        ) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.Colors.teal)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.teal.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - WriteReviewView
struct WriteReviewView: View {
    let listing: Listing
    let onSubmitted: (Review) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var auth = AuthService.shared
    @State private var rating: Int = 5
    @State private var reviewText = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {

                        // Listing info
                        HStack(spacing: AppTheme.Spacing.sm) {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                .fill(AppTheme.Colors.coral.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: listing.category.icon)
                                        .font(.system(size: 22))
                                        .foregroundStyle(AppTheme.Colors.coral)
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(listing.name)
                                    .font(AppTheme.Font.headline())
                                    .foregroundStyle(AppTheme.Colors.deepNavy)
                                Text(listing.category.rawValue)
                                    .font(AppTheme.Font.caption())
                                    .foregroundStyle(AppTheme.Colors.mediumGray)
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

                        // Star rating
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Your rating")
                                .font(AppTheme.Font.label())
                                .foregroundStyle(AppTheme.Colors.deepNavy)
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        rating = star
                                    } label: {
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .font(.system(size: 36))
                                            .foregroundStyle(star <= rating ? AppTheme.Colors.goldenSun : AppTheme.Colors.mediumGray.opacity(0.4))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

                        // Review text
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Tell others about your experience")
                                .font(AppTheme.Font.label())
                                .foregroundStyle(AppTheme.Colors.deepNavy)
                            TextEditor(text: $reviewText)
                                .font(AppTheme.Font.body())
                                .frame(minHeight: 140)
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.Colors.sand)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                        .strokeBorder(AppTheme.Colors.mediumGray.opacity(0.3), lineWidth: 1)
                                }
                            Text("\(reviewText.count)/500")
                                .font(AppTheme.Font.caption())
                                .foregroundStyle(AppTheme.Colors.mediumGray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

                        if let err = errorMessage {
                            Text(err)
                                .font(AppTheme.Font.caption())
                                .foregroundStyle(AppTheme.Colors.coral)
                                .padding(.horizontal, AppTheme.Spacing.md)
                        }

                        // Submit button
                        Button {
                            Task { await submit() }
                        } label: {
                            Group {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Submit Review")
                                        .font(AppTheme.Font.headline())
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppTheme.Spacing.md)
                            .background(reviewText.count >= 10 ? AppTheme.Colors.coral : AppTheme.Colors.mediumGray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                        }
                        .disabled(reviewText.count < 10 || isSubmitting)
                        .padding(.horizontal, AppTheme.Spacing.md)
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
            .navigationTitle("Write a Review")
            .navTitleMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submit() async {
        guard let uid = auth.currentUserID else {
            errorMessage = "Please sign in to write a review."
            return
        }
        isSubmitting = true
        errorMessage = nil
        let input = ReviewInput(
            listingID: listing.id,
            userID: uid,
            authorName: auth.profile?.name ?? "Traveler",
            rating: Double(rating),
            text: reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        do {
            try await repo.submitReview(input)
            // Build a local Review to insert immediately into the list
            let newReview = Review(
                id: UUID(),
                listingID: listing.id,
                authorName: input.authorName,
                authorAvatar: "person.circle.fill",
                rating: input.rating,
                text: input.text,
                date: Date(),
                photos: []
            )
            onSubmitted(newReview)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}

// MARK: - MyReviewsView
struct MyReviewsView: View {
    @StateObject private var auth = AuthService.shared
    @State private var reviews: [Review] = []
    @State private var isLoading = true
    @State private var listingNames: [UUID: String] = [:]

    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.sand.ignoresSafeArea()
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if reviews.isEmpty {
                emptyState
            } else {
                reviewsList
            }
        }
        .navigationTitle(String(localized: "profile.menu.reviews"))
        .navTitleMode(.large)
        .task {
            await loadReviews()
        }
    }

    // MARK: Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "star.slash")
                .font(.system(size: 52))
                .foregroundStyle(AppTheme.Colors.mediumGray)
            Text("No reviews yet")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text("Visit a place and share your experience — your reviews help other travelers.")
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Reviews List
    private var reviewsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(reviews) { review in
                    MyReviewRowView(
                        review: review,
                        listingName: listingNames[review.listingID] ?? "Place"
                    )
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await deleteReview(review) }
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    // MARK: Data
    private func loadReviews() async {
        isLoading = true
        reviews = await auth.fetchMyReviews()
        // Fetch listing names for all reviews in one batch
        let ids = Set(reviews.map { $0.listingID.uuidString })
        if !ids.isEmpty {
            if let rows = try? await supabase
                .from("listings")
                .select("id, name")
                .in("id", values: Array(ids))
                .execute()
                .value as [ListingNameRow] {
                for row in rows {
                    if let uid = UUID(uuidString: row.id) {
                        listingNames[uid] = row.name
                    }
                }
            }
        }
        isLoading = false
    }

    private func deleteReview(_ review: Review) async {
        do {
            try await supabase
                .from("reviews")
                .delete()
                .eq("id", value: review.id.uuidString)
                .execute()
            reviews.removeAll { $0.id == review.id }
        } catch {
            print("deleteReview error:", error)
        }
    }
}

// Lightweight codable for listing name lookup
private struct ListingNameRow: Codable {
    let id: String
    let name: String
}

// MARK: - MyReviewRowView
struct MyReviewRowView: View {
    let review: Review
    let listingName: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Listing name + date header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(listingName)
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.deepNavy)
                    Text(review.formattedDate)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
                Spacer()
                // Star rating badge
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: Double(star) <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundStyle(Double(star) <= review.rating
                                ? AppTheme.Colors.goldenSun
                                : AppTheme.Colors.mediumGray.opacity(0.4))
                    }
                }
            }
            // Review text
            Text(review.text)
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.deepNavy.opacity(0.8))
                .lineSpacing(4)
                .lineLimit(4)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
