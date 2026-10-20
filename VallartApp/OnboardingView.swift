import SwiftUI

// MARK: - OnboardingView
// Shown on first launch only.
struct OnboardingView: View {
    let onSignUp: () -> Void
    let onGuest: () -> Void
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            gradient: [AppTheme.Colors.coral, AppTheme.Colors.nightPurple],
            icon: "safari.fill",
            title: "Puerto Vallarta\n& Riviera Nayarit",
            subtitle: "Discover Mexico's most vibrant Pacific paradise — beaches, jungles, nightlife and more."
        ),
        OnboardingPage(
            gradient: [AppTheme.Colors.teal, AppTheme.Colors.palmGreen],
            icon: "mappin.and.ellipse",
            title: "258+ Curated\nSpots",
            subtitle: "Restaurants, bars, hotels, spas, activities, yacht rentals — all hand-picked and reviewed."
        ),
        OnboardingPage(
            gradient: [AppTheme.Colors.goldenSun, AppTheme.Colors.coral],
            icon: "star.fill",
            title: "Ready to\nExplore?",
            subtitle: "Create a free account to save your favorites, write reviews, and unlock exclusive deals."
        )
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            VStack {
                Spacer()
                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.white : Color.white.opacity(0.4))
                            .frame(width: i == currentPage ? 20 : 8, height: 8)
                            .animation(.spring(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.lg)

                // CTA buttons
                if currentPage == pages.count - 1 {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Button(action: onSignUp) {
                            Text("Create Free Account")
                                .font(AppTheme.Font.headline())
                                .foregroundStyle(AppTheme.Colors.coral)
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.Spacing.md)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                        }
                        Button(action: onGuest) {
                            Text("Browse as Guest")
                                .font(AppTheme.Font.label())
                                .foregroundStyle(.white.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.Spacing.md)
                                .background(.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Text("Next")
                                .font(AppTheme.Font.headline())
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(AppTheme.Colors.coral)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: currentPage)
        }
    }
}

// MARK: - OnboardingPage model
private struct OnboardingPage {
    let gradient: [Color]
    let icon: String
    let title: String
    let subtitle: String
}

// MARK: - OnboardingPageView
private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ZStack {
            LinearGradient(
                colors: page.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: page.icon)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(page.title)
                        .font(AppTheme.Font.display(34))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text(page.subtitle)
                        .font(AppTheme.Font.body(17))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                }

                Spacer()
                Spacer()
            }
        }
    }
}
