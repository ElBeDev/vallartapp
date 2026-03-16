import SwiftUI

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

// MARK: - FeaturedCardView
struct FeaturedCardView: View {
    let listing: Listing

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                .fill(cardGradient)
                .frame(width: 280, height: 180)

            Image(systemName: listing.heroPhoto)
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.2))
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
                    Text(listing.neighborhood.rawValue)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(AppTheme.Spacing.md)
        }
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

    private var cardGradient: LinearGradient {
        LinearGradient(colors: [cardColor, cardColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - ListingRowView
struct ListingRowView: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(iconBg)
                    .frame(width: 64, height: 64)
                Image(systemName: listing.heroPhoto)
                    .font(.system(size: 26))
                    .foregroundStyle(iconColor)
            }

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
                Text("\(listing.category.rawValue) · \(listing.neighborhood.rawValue)")
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

    private var iconBg: Color { iconColor.opacity(0.12) }
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
