import Foundation
import Combine
import Supabase
import StripePaymentSheet

// MARK: - BusinessTier
// For business owners who want to list/promote their business on VallartApp.
enum BusinessTier: String, CaseIterable, Identifiable {
    case standard       = "biz_standard"
    case premium        = "biz_premium"
    case standardYearly = "biz_standard_yearly"
    case premiumYearly  = "biz_premium_yearly"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard:       return "Standard"
        case .premium:        return "Premium"
        case .standardYearly: return "Standard (Yearly)"
        case .premiumYearly:  return "Premium (Yearly)"
        }
    }

    var price: String {
        switch self {
        case .standard:       return "$29 / month"
        case .premium:        return "$79 / month"
        case .standardYearly: return "$249 / year"
        case .premiumYearly:  return "$699 / year"
        }
    }

    var priceNote: String? {
        switch self {
        case .standardYearly, .premiumYearly: return "Save 30%"
        default: return nil
        }
    }

    var amountCents: Int {
        switch self {
        case .standard:       return 2900
        case .premium:        return 7900
        case .standardYearly: return 24900
        case .premiumYearly:  return 69900
        }
    }

    var features: [String] {
        switch self {
        case .standard, .standardYearly:
            return [
                "Unlimited listing photos",
                "Reply to customer reviews",
                "Contact button & WhatsApp link",
                "Website & Instagram links",
                "Basic monthly analytics",
                "Verified business badge"
            ]
        case .premium, .premiumYearly:
            return [
                "Everything in Standard",
                "Featured placement — top of search",
                "Promoted map pin (golden crown)",
                "Appear in 'Editor's Picks' carousel",
                "Priority customer support",
                "Booking widget integration"
            ]
        }
    }

    var isPopular: Bool { self == .premium || self == .premiumYearly }
}

// MARK: - UserTier
// For regular users who want premium explorer benefits.
enum UserTier: String, CaseIterable, Identifiable {
    case explorer       = "user_explorer"
    case explorerYearly = "user_explorer_yearly"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .explorer:       return "Explorer"
        case .explorerYearly: return "Explorer (Yearly)"
        }
    }

    var price: String {
        switch self {
        case .explorer:       return "$4.99 / month"
        case .explorerYearly: return "$39.99 / year"
        }
    }

    var priceNote: String? {
        switch self {
        case .explorerYearly: return "Save 33%"
        default: return nil
        }
    }

    var amountCents: Int {
        switch self {
        case .explorer:       return 499
        case .explorerYearly: return 3999
        }
    }

    var features: [String] {
        [
            "Ad-free experience",
            "Early access to private events",
            "Exclusive member discounts at partner venues",
            "Advanced filters (open now, distance, price)",
            "Offline maps & saved routes",
            "Explorer badge on your profile"
        ]
    }
}

// MARK: - StripeService
@MainActor
class StripeService: ObservableObject {

    static let shared = StripeService()

    static let publishableKey = "pk_test_51TDwPCLJz5VzlqoYHj0RpZNOv4vacLYFEHjV7RifYFafBavQ6sLo3FO02CunEnxvM5YqrKR1husABqnuniEt1y0S00Xo4uJ4P0"
    private let edgeFunctionURL = "https://nvubaobivraevlnlpsjr.supabase.co/functions/v1/create-payment-intent"

    @Published var isLoading     = false
    @Published var errorMessage: String?
    @Published var paymentSheet: PaymentSheet?

    private init() {
        StripeAPI.defaultPublishableKey = Self.publishableKey
    }

    // MARK: - Build PaymentSheet — Business tier
    func prepareBusinessPayment(tier: BusinessTier, userID: String) async {
        await prepare(tierRawValue: tier.rawValue, amountCents: tier.amountCents, userID: userID)
    }

    // MARK: - Build PaymentSheet — User tier
    func prepareUserPayment(tier: UserTier, userID: String) async {
        await prepare(tierRawValue: tier.rawValue, amountCents: tier.amountCents, userID: userID)
    }

    private func prepare(tierRawValue: String, amountCents: Int, userID: String) async {
        isLoading    = true
        errorMessage = nil
        paymentSheet = nil

        do {
            guard let url = URL(string: edgeFunctionURL) else { throw URLError(.badURL) }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody   = try JSONSerialization.data(withJSONObject: [
                "tier":   tierRawValue,
                "userID": userID
            ])
            let (data, response) = try await URLSession.shared.data(for: req)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                let msg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Payment server error"
                throw NSError(domain: msg, code: 0)
            }
            struct Resp: Decodable { let clientSecret: String }
            let r = try JSONDecoder().decode(Resp.self, from: data)

            var config = PaymentSheet.Configuration()
            config.merchantDisplayName = "VallartApp"
            config.allowsDelayedPaymentMethods = false
            config.defaultBillingDetails.address.country = "MX"
            paymentSheet = PaymentSheet(paymentIntentClientSecret: r.clientSecret, configuration: config)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Handle payment result — Business
    func handleBusinessResult(_ result: PaymentSheetResult, tier: BusinessTier, userID: String) async -> Bool {
        switch result {
        case .completed:
            await activateBusinessTier(userID: userID, tier: tier)
            return true
        case .failed(let err):
            errorMessage = err.localizedDescription; return false
        case .canceled:
            return false
        }
    }

    // MARK: - Handle payment result — User
    func handleUserResult(_ result: PaymentSheetResult, tier: UserTier, userID: String) async -> Bool {
        switch result {
        case .completed:
            await activateUserTier(userID: userID, tier: tier)
            return true
        case .failed(let err):
            errorMessage = err.localizedDescription; return false
        case .canceled:
            return false
        }
    }

    // MARK: - Activate business tier in Supabase
    func activateBusinessTier(userID: String, tier: BusinessTier) async {
        do {
            // Upsert into business_owners table (handles both new and existing columns)
            try await supabase
                .from("business_owners")
                .upsert([
                    "user_id":             userID,
                    "plan":                tier.rawValue,
                    "plan_started_at":     ISO8601DateFormatter().string(from: Date()),
                    "is_active":           "true",
                    "subscription_tier":   tier.rawValue,
                    "subscription_status": "active"
                ], onConflict: "user_id")
                .execute()
            // Flag profile as business owner
            try await supabase
                .from("profiles")
                .update(["is_business_owner": true])
                .eq("id", value: userID)
                .execute()
            await AuthService.shared.refreshProfile()
        } catch { print("activateBusinessTier error:", error) }
    }

    // MARK: - Activate user tier in Supabase
    func activateUserTier(userID: String, tier: UserTier) async {
        do {
            try await supabase
                .from("profiles")
                .update([
                    "is_premium":          AnyJSON.bool(true),
                    "premium_tier":        AnyJSON.string(tier.rawValue),
                    "premium_started_at":  AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                ])
                .eq("id", value: userID)
                .execute()
            await AuthService.shared.refreshProfile()
        } catch { print("activateUserTier error:", error) }
    }
}
