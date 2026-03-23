import SwiftUI

// MARK: - PremiumView
// Paywall shown when a user taps a premium feature or "Upgrade" in Profile.
struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var stripe = StripeService.shared
    @StateObject private var auth   = AuthService.shared

    @State private var billingCycle: BillingCycle = .monthly
    @State private var selectedTier: PremiumTier  = .monthlyPremium
    @State private var paymentSuccess              = false
    @State private var showEdgeFunctionNote        = false

    enum BillingCycle: String, CaseIterable {
        case monthly = "Monthly"
        case yearly  = "Yearly"
    }

    // Tiers shown for the current billing cycle
    private var visibleTiers: [PremiumTier] {
        billingCycle == .monthly
            ? [.monthlyStandard, .monthlyPremium]
            : [.yearlyStandard, .yearlyPremium]
    }

    // Sync selected tier when billing cycle changes
    private func syncTier() {
        switch (billingCycle, selectedTier) {
        case (.monthly, .yearlyStandard):  selectedTier = .monthlyStandard
        case (.monthly, .yearlyPremium):   selectedTier = .monthlyPremium
        case (.yearly,  .monthlyStandard): selectedTier = .yearlyStandard
        case (.yearly,  .monthlyPremium):  selectedTier = .yearlyPremium
        default: break
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [AppTheme.Colors.deepNavy, AppTheme.Colors.nightPurple.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Header
                        headerSection

                        // Billing toggle
                        billingToggle

                        // Tier cards
                        tierCards

                        // Feature comparison
                        featureSection

                        // CTA button
                        ctaSection

                        // Fine print
                        finePrint

                        Spacer(minLength: AppTheme.Spacing.xxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.lg)
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
            .alert("Upgrade Started!", isPresented: $showEdgeFunctionNote) {
                Button("OK") {}
            } message: {
                Text("The payment system is almost ready.\n\nTo complete setup:\n1. Deploy the Edge Function from supabase/functions/create-payment-intent\n2. The Upgrade button will activate the full Stripe payment sheet.\n\nFor now, use Stripe test card: 4242 4242 4242 4242.")
            }
            .alert("Payment Successful!", isPresented: $paymentSuccess) {
                Button("Done") { dismiss() }
            } message: {
                Text("Welcome to VallartApp \(selectedTier.displayName)!")
            }
        }
    }

    // MARK: Header
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(AppTheme.Colors.goldenSun)
            }
            Text("VallartApp Premium")
                .font(AppTheme.Font.display(28))
                .foregroundStyle(.white)
            Text("Grow your business in Puerto Vallarta")
                .font(AppTheme.Font.body())
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: Billing Toggle
    private var billingToggle: some View {
        HStack(spacing: 0) {
            ForEach(BillingCycle.allCases, id: \.self) { cycle in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        billingCycle = cycle
                        syncTier()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(cycle.rawValue)
                            .font(AppTheme.Font.label())
                            .foregroundStyle(billingCycle == cycle ? AppTheme.Colors.deepNavy : .white.opacity(0.7))
                        if cycle == .yearly {
                            Text("Save 30%")
                                .font(AppTheme.Font.caption(10))
                                .foregroundStyle(billingCycle == .yearly ? AppTheme.Colors.deepNavy : AppTheme.Colors.goldenSun)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background((billingCycle == .yearly ? AppTheme.Colors.goldenSun : AppTheme.Colors.goldenSun).opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(billingCycle == cycle ? .white : .clear)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: Tier Cards
    private var tierCards: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(visibleTiers) { tier in
                TierCardView(tier: tier, isSelected: selectedTier == tier) {
                    withAnimation(.spring(duration: 0.2)) { selectedTier = tier }
                }
            }
        }
    }

    // MARK: Feature Section
    private var featureSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("What you get")
                .font(AppTheme.Font.label())
                .foregroundStyle(.white.opacity(0.6))
                .padding(.bottom, 4)
            ForEach(selectedTier.features, id: \.self) { feature in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.Colors.goldenSun)
                    Text(feature)
                        .font(AppTheme.Font.body())
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
    }

    // MARK: CTA
    @ViewBuilder
    private var ctaSection: some View {
        // Sign-in gate
        if !auth.isLoggedIn {
            Text("Please sign in to upgrade")
                .font(AppTheme.Font.caption())
                .foregroundStyle(.white.opacity(0.6))
        } else {
            VStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    Task {
                        guard let uid = auth.currentUserID?.uuidString else { return }
                        await stripe.preparePayment(tier: selectedTier, userID: uid)
                        // If Edge Function not deployed yet — show info
                        if stripe.errorMessage != nil {
                            showEdgeFunctionNote = true
                            stripe.errorMessage = nil
                        }
                        // If clientSecret ready — in a future sprint we present PaymentSheet here
                        // For now simulate sandbox activation
                        if stripe.paymentReady {
                            await stripe.activatePremium(userID: uid, tier: selectedTier)
                            paymentSuccess = true
                            stripe.paymentReady = false
                        }
                    }
                } label: {
                    Group {
                        if stripe.isLoading {
                            ProgressView().tint(AppTheme.Colors.deepNavy)
                        } else {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                Text("Get \(selectedTier.displayName) — \(selectedTier.price)")
                                    .font(AppTheme.Font.headline())
                            }
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.goldenSun)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                    .shadow(color: AppTheme.Colors.goldenSun.opacity(0.4), radius: 8, y: 4)
                }
                .disabled(stripe.isLoading)

                if let err = stripe.errorMessage {
                    Text(err)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.coral)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: Fine Print
    private var finePrint: some View {
        VStack(spacing: 4) {
            Text("Secure payment via Stripe")
            Text("Cancel anytime from your account settings")
        }
        .font(AppTheme.Font.caption(11))
        .foregroundStyle(.white.opacity(0.4))
        .multilineTextAlignment(.center)
    }
}

// MARK: - TierCardView
struct TierCardView: View {
    let tier: PremiumTier
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
                        Text("Popular")
                            .font(AppTheme.Font.caption(10))
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(AppTheme.Colors.goldenSun)
                            .clipShape(Capsule())
                    }
                }
                Text(tier.price)
                    .font(AppTheme.Font.display(20))
                    .foregroundStyle(isSelected ? AppTheme.Colors.goldenSun : .white.opacity(0.6))
                if let note = tier.priceNote {
                    Text(note)
                        .font(AppTheme.Font.caption(11))
                        .foregroundStyle(AppTheme.Colors.goldenSun)
                }
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                    ? LinearGradient(colors: [AppTheme.Colors.coral.opacity(0.8), AppTheme.Colors.nightPurple.opacity(0.6)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.05)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .strokeBorder(isSelected ? AppTheme.Colors.goldenSun.opacity(0.6) : .white.opacity(0.1),
                                  lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: isSelected ? AppTheme.Colors.coral.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PremiumBadgeView (shown on profile when user is premium)
struct PremiumBadgeView: View {
    let tierName: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10))
            Text(tierName)
                .font(AppTheme.Font.caption(11))
        }
        .foregroundStyle(AppTheme.Colors.deepNavy)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 4)
        .background(AppTheme.Colors.goldenSun)
        .clipShape(Capsule())
    }
}
