import Foundation
import Combine
import Supabase
import StripePaymentSheet

// MARK: - PremiumTier
enum PremiumTier: String, CaseIterable, Identifiable {
    case monthlyStandard = "monthly_standard"
    case monthlyPremium  = "monthly_premium"
    case yearlyStandard  = "yearly_standard"
    case yearlyPremium   = "yearly_premium"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monthlyStandard: return "Standard"
        case .monthlyPremium:  return "Premium"
        case .yearlyStandard:  return "Standard (Yearly)"
        case .yearlyPremium:   return "Premium (Yearly)"
        }
    }

    var price: String {
        switch self {
        case .monthlyStandard: return "$29 / month"
        case .monthlyPremium:  return "$79 / month"
        case .yearlyStandard:  return "$249 / year"
        case .yearlyPremium:   return "$699 / year"
        }
    }

    var priceNote: String? {
        switch self {
        case .yearlyStandard, .yearlyPremium: return "Save 30%"
        default: return nil
        }
    }

    var features: [String] {
        switch self {
        case .monthlyStandard, .yearlyStandard:
            return [
                "Unlimited photos on your listing",
                "Reply to reviews",
                "Contact button visible",
                "Basic analytics"
            ]
        case .monthlyPremium, .yearlyPremium:
            return [
                "Everything in Standard",
                "Featured placement — top of search",
                "Promoted map pin",
                "Priority customer support",
                "Booking widget integration"
            ]
        }
    }

    var isPopular: Bool { self == .monthlyPremium || self == .yearlyPremium }
}

// MARK: - StripeService
@MainActor
class StripeService: ObservableObject {

    static let shared = StripeService()

    static let publishableKey = "pk_test_51TDwPCLJz5VzlqoYHj0RpZNOv4vacLYFEHjV7RifYFafBavQ6sLo3FO02CunEnxvM5YqrKR1husABqnuniEt1y0S00Xo4uJ4P0"
    private let edgeFunctionURL = "https://nvubaobivraevlnlpsjr.supabase.co/functions/v1/create-payment-intent"

    @Published var isLoading     = false
    @Published var errorMessage: String?
    @Published var paymentSheet: PaymentSheet?    // non-nil triggers .paymentSheet modifier
    @Published var paymentResult: PaymentSheetResult?

    private init() {
        StripeAPI.defaultPublishableKey = Self.publishableKey
    }

    // MARK: - Build PaymentSheet from Edge Function
    func preparePaymentSheet(tier: PremiumTier, userID: String) async {
        isLoading     = true
        errorMessage  = nil
        paymentSheet  = nil
        paymentResult = nil

        do {
            guard let url = URL(string: edgeFunctionURL) else { throw URLError(.badURL) }
            var req = URLRequest(url: url)
            req.httpMethod  = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody    = try JSONSerialization.data(withJSONObject: [
                "tier":   tier.rawValue,
                "userID": userID
            ])

            let (data, response) = try await URLSession.shared.data(for: req)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                let msg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Payment server error"
                throw NSError(domain: msg, code: 0)
            }

            struct Resp: Decodable { let clientSecret: String }
            let r = try JSONDecoder().decode(Resp.self, from: data)

            var config                           = PaymentSheet.Configuration()
            config.merchantDisplayName           = "VallartApp"
            config.allowsDelayedPaymentMethods   = false
            config.defaultBillingDetails.address.country = "MX"

            paymentSheet = PaymentSheet(
                paymentIntentClientSecret: r.clientSecret,
                configuration: config
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Handle result after PaymentSheet closes
    func handleResult(_ result: PaymentSheetResult, tier: PremiumTier, userID: String) async -> Bool {
        switch result {
        case .completed:
            await activatePremium(userID: userID, tier: tier)
            return true
        case .failed(let err):
            errorMessage = err.localizedDescription
            return false
        case .canceled:
            return false
        }
    }

    // MARK: - Mark user premium in Supabase
    func activatePremium(userID: String, tier: PremiumTier) async {
        do {
            try await supabase
                .from("profiles")
                .update([
                    "is_premium":           AnyJSON.bool(true),
                    "premium_tier":         AnyJSON.string(tier.rawValue),
                    "premium_started_at":   AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                ])
                .eq("id", value: userID)
                .execute()
            await AuthService.shared.refreshProfile()
        } catch {
            print("activatePremium error:", error)
        }
    }
}

// MARK: - PaymentIntentResponse (kept for reference)
private struct PaymentIntentResponse: Decodable {
    let clientSecret: String
}
