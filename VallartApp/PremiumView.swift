import SwiftUI
import StripePaymentSheet

// MARK: - PremiumView
// Entry point — shows two tabs: one for users, one for business owners.
struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    enum Tab { case user, business }
    @State private var selectedTab: Tab

    init(startOn tab: Tab = .user) { _selectedTab = State(initialValue: tab) }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.Colors.deepNavy, AppTheme.Colors.nightPurple.opacity(0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab Switcher
                    tabSwitcher.padding(.top, AppTheme.Spacing.md)

                    // Content
                    if selectedTab == .user {
                        UserPaywallView(onDismiss: { dismiss() })
                    } else {
                        BusinessPaywallView(onDismiss: { dismiss() })
                    }
                }
            }
            .navTitleMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(6)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton(title: "For Travelers", icon: "person.fill", tab: .user)
            tabButton(title: "For Businesses", icon: "building.2.fill", tab: .business)
        }
        .padding(4)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func tabButton(title: String, icon: String, tab: Tab) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab } } label: {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                Text(title).font(AppTheme.Font.label(13))
            }
            .foregroundStyle(selectedTab == tab ? AppTheme.Colors.deepNavy : .white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(selectedTab == tab ? .white : .clear)
            .clipShape(Capsule())
        }
    }
}

// MARK: - UserPaywallView
// Single Explorer tier — cheap, focused on traveler perks.
struct UserPaywallView: View {
    let onDismiss: () -> Void
    @StateObject private var stripe = StripeService.shared
    @StateObject private var auth   = AuthService.shared

    @State private var selectedTier: UserTier  = .explorer
    @State private var paymentSuccess           = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                VStack(spacing: AppTheme.Spacing.sm) {
                    ZStack {
                        Circle().fill(.white.opacity(0.08)).frame(width: 72, height: 72)
                        Image(systemName: "figure.walk.departure")
                            .font(.system(size: 32)).foregroundStyle(AppTheme.Colors.teal)
                    }
                    Text("Explorer Premium").font(AppTheme.Font.display(26)).foregroundStyle(.white)
                    Text("The best of Puerto Vallarta, unlocked")
                        .font(AppTheme.Font.body()).foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppTheme.Spacing.md)

                // Billing toggle (monthly / yearly)
                HStack(spacing: 0) {
                    ForEach(UserTier.allCases) { tier in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTier = tier }
                        } label: {
                            VStack(spacing: 2) {
                                Text(tier == .explorer ? "Monthly" : "Yearly")
                                    .font(AppTheme.Font.label(13))
                                    .foregroundStyle(selectedTier == tier ? AppTheme.Colors.deepNavy : .white.opacity(0.7))
                                Text(tier.price)
                                    .font(AppTheme.Font.caption(11))
                                    .foregroundStyle(selectedTier == tier ? AppTheme.Colors.deepNavy.opacity(0.7) : .white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(selectedTier == tier ? .white : .clear)
                            .clipShape(Capsule())
                            .overlay(alignment: .topTrailing) {
                                if let note = tier.priceNote {
                                    Text(note)
                                        .font(AppTheme.Font.caption(9))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 5).padding(.vertical, 2)
                                        .background(AppTheme.Colors.teal)
                                        .clipShape(Capsule())
                                        .offset(x: -4, y: -8)
                                }
                            }
                        }
                    }
                }
                .padding(4)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())

                // Feature list
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("What you get").font(AppTheme.Font.label())
                        .foregroundStyle(.white.opacity(0.6)).padding(.bottom, 4)
                    ForEach(UserTier.explorer.features, id: \.self) { feature in
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16)).foregroundStyle(AppTheme.Colors.teal)
                            Text(feature).font(AppTheme.Font.body()).foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.md)
                .background(.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))

                // CTA
                ctaSection

                // Fine print
                VStack(spacing: 4) {
                    Text("Secure payment via Stripe")
                    Text("Cancel anytime · No hidden fees")
                }
                .font(AppTheme.Font.caption(11))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .paymentSheet(
            isPresented: Binding(get: { stripe.paymentSheet != nil }, set: { if !$0 { stripe.paymentSheet = nil } }),
            paymentSheet: stripe.paymentSheet ?? PaymentSheet(paymentIntentClientSecret: "placeholder", configuration: .init()),
            onCompletion: { result in
                Task {
                    guard let uid = auth.currentUserID?.uuidString else { return }
                    let ok = await stripe.handleUserResult(result, tier: selectedTier, userID: uid)
                    if ok { paymentSuccess = true }
                }
            }
        )
        .alert("Welcome, Explorer!", isPresented: $paymentSuccess) {
            Button("Let's go!") { onDismiss() }
        } message: {
            Text("Your Explorer badge is now active. Enjoy early event access, exclusive deals and more!")
        }
    }

    @ViewBuilder
    private var ctaSection: some View {
        if !auth.isLoggedIn {
            Text("Please sign in to upgrade")
                .font(AppTheme.Font.caption()).foregroundStyle(.white.opacity(0.6))
        } else if auth.profile?.isPremium == true {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "checkmark.seal.fill").foregroundStyle(AppTheme.Colors.teal)
                Text("You're already an Explorer!").font(AppTheme.Font.headline()).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
        } else {
            VStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    Task {
                        guard let uid = auth.currentUserID?.uuidString else { return }
                        await stripe.prepareUserPayment(tier: selectedTier, userID: uid)
                    }
                } label: {
                    Group {
                        if stripe.isLoading {
                            ProgressView().tint(AppTheme.Colors.deepNavy)
                        } else {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "figure.walk.departure").font(.system(size: 16))
                                Text("Get Explorer — \(selectedTier.price)").font(AppTheme.Font.headline())
                            }
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.teal)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                    .shadow(color: AppTheme.Colors.teal.opacity(0.4), radius: 8, y: 4)
                }
                .disabled(stripe.isLoading)
                if let err = stripe.errorMessage {
                    Text(err).font(AppTheme.Font.caption()).foregroundStyle(AppTheme.Colors.coral).multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - BusinessPaywallView
// For business owners: two tiers (Standard / Premium), monthly or yearly.
struct BusinessPaywallView: View {
    let onDismiss: () -> Void
    @StateObject private var stripe = StripeService.shared
    @StateObject private var auth   = AuthService.shared

    enum BillingCycle { case monthly, yearly }
    @State private var billing: BillingCycle   = .monthly
    @State private var selectedTier: BusinessTier = .premium
    @State private var paymentSuccess             = false

    private var visibleTiers: [BusinessTier] {
        billing == .monthly ? [.standard, .premium] : [.standardYearly, .premiumYearly]
    }

    private func syncTier() {
        switch (billing, selectedTier) {
        case (.monthly, .standardYearly): selectedTier = .standard
        case (.monthly, .premiumYearly):  selectedTier = .premium
        case (.yearly, .standard):        selectedTier = .standardYearly
        case (.yearly, .premium):         selectedTier = .premiumYearly
        default: break
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                VStack(spacing: AppTheme.Spacing.sm) {
                    ZStack {
                        Circle().fill(.white.opacity(0.08)).frame(width: 72, height: 72)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 30)).foregroundStyle(AppTheme.Colors.goldenSun)
                    }
                    Text("List Your Business").font(AppTheme.Font.display(26)).foregroundStyle(.white)
                    Text("Reach thousands of tourists every day")
                        .font(AppTheme.Font.body()).foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppTheme.Spacing.md)

                // Billing toggle
                HStack(spacing: 0) {
                    ForEach([BillingCycle.monthly, .yearly], id: \.self) { cycle in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { billing = cycle; syncTier() }
                        } label: {
                            HStack(spacing: 4) {
                                Text(cycle == .monthly ? "Monthly" : "Yearly")
                                    .font(AppTheme.Font.label())
                                    .foregroundStyle(billing == cycle ? AppTheme.Colors.deepNavy : .white.opacity(0.7))
                                if cycle == .yearly {
                                    Text("Save 30%")
                                        .font(AppTheme.Font.caption(10))
                                        .foregroundStyle(billing == .yearly ? AppTheme.Colors.deepNavy : AppTheme.Colors.goldenSun)
                                        .padding(.horizontal, 5).padding(.vertical, 2)
                                        .background((billing == .yearly ? AppTheme.Colors.goldenSun : AppTheme.Colors.goldenSun).opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(billing == cycle ? .white : .clear)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(4).background(.white.opacity(0.12)).clipShape(Capsule())

                // Tier cards
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(visibleTiers) { tier in
                        TierCardView(tier: tier, isSelected: selectedTier == tier) {
                            withAnimation(.spring(duration: 0.2)) { selectedTier = tier }
                        }
                    }
                }

                // Feature list for selected tier
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("What you get").font(AppTheme.Font.label())
                        .foregroundStyle(.white.opacity(0.6)).padding(.bottom, 4)
                    ForEach(selectedTier.features, id: \.self) { feature in
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16)).foregroundStyle(AppTheme.Colors.goldenSun)
                            Text(feature).font(AppTheme.Font.body()).foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.md)
                .background(.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))

                // CTA
                bizCTASection

                VStack(spacing: 4) {
                    Text("Secure payment via Stripe")
                    Text("Cancel anytime · Listing reviewed within 24h")
                }
                .font(AppTheme.Font.caption(11))
                .foregroundStyle(.white.opacity(0.4)).multilineTextAlignment(.center)

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .paymentSheet(
            isPresented: Binding(get: { stripe.paymentSheet != nil }, set: { if !$0 { stripe.paymentSheet = nil } }),
            paymentSheet: stripe.paymentSheet ?? PaymentSheet(paymentIntentClientSecret: "placeholder", configuration: .init()),
            onCompletion: { result in
                Task {
                    guard let uid = auth.currentUserID?.uuidString else { return }
                    let ok = await stripe.handleBusinessResult(result, tier: selectedTier, userID: uid)
                    if ok { paymentSuccess = true }
                }
            }
        )
        .alert("Business Registered!", isPresented: $paymentSuccess) {
            Button("Done") { onDismiss() }
        } message: {
            Text("Your \(selectedTier.displayName) plan is now active. Your listing will appear on VallartApp within 24 hours.")
        }
    }

    @ViewBuilder
    private var bizCTASection: some View {
        if !auth.isLoggedIn {
            Text("Please sign in to register your business")
                .font(AppTheme.Font.caption()).foregroundStyle(.white.opacity(0.6))
        } else {
            VStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    Task {
                        guard let uid = auth.currentUserID?.uuidString else { return }
                        await stripe.prepareBusinessPayment(tier: selectedTier, userID: uid)
                    }
                } label: {
                    Group {
                        if stripe.isLoading {
                            ProgressView().tint(AppTheme.Colors.deepNavy)
                        } else {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "crown.fill").font(.system(size: 16))
                                Text("Get \(selectedTier.displayName) — \(selectedTier.price)").font(AppTheme.Font.headline())
                            }
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.goldenSun)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                    .shadow(color: AppTheme.Colors.goldenSun.opacity(0.4), radius: 8, y: 4)
                }
                .disabled(stripe.isLoading)
                if let err = stripe.errorMessage {
                    Text(err).font(AppTheme.Font.caption()).foregroundStyle(AppTheme.Colors.coral).multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - TierCardView (shared by business paywall)
struct TierCardView: View {
    let tier: BusinessTier
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    Text(tier.displayName.components(separatedBy: " ").first ?? tier.displayName)
                        .font(AppTheme.Font.headline())
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                    Spacer()
                    if tier.isPopular {
                        Text("Popular").font(AppTheme.Font.caption(10))
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(AppTheme.Colors.goldenSun).clipShape(Capsule())
                    }
                }
                Text(tier.price).font(AppTheme.Font.display(20))
                    .foregroundStyle(isSelected ? AppTheme.Colors.goldenSun : .white.opacity(0.6))
                if let note = tier.priceNote {
                    Text(note).font(AppTheme.Font.caption(11)).foregroundStyle(AppTheme.Colors.goldenSun)
                }
            }
            .padding(AppTheme.Spacing.md).frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                    ? LinearGradient(colors: [AppTheme.Colors.coral.opacity(0.8), AppTheme.Colors.nightPurple.opacity(0.6)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.05)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .strokeBorder(isSelected ? AppTheme.Colors.goldenSun.opacity(0.6) : .white.opacity(0.1),
                              lineWidth: isSelected ? 1.5 : 1))
            .shadow(color: isSelected ? AppTheme.Colors.coral.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PremiumBadgeView
struct PremiumBadgeView: View {
    let tierName: String
    var isExplorer: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isExplorer ? "figure.walk.departure" : "crown.fill")
                .font(.system(size: 10))
            Text(tierName).font(AppTheme.Font.caption(11))
        }
        .foregroundStyle(isExplorer ? .white : AppTheme.Colors.deepNavy)
        .padding(.horizontal, AppTheme.Spacing.sm).padding(.vertical, 4)
        .background(isExplorer ? AppTheme.Colors.teal : AppTheme.Colors.goldenSun)
        .clipShape(Capsule())
    }
}

// MARK: - BillingCycle Hashable
extension BusinessPaywallView.BillingCycle: Hashable {}
