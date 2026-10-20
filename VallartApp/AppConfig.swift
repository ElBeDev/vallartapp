import Foundation

// MARK: - AppConfig
// Single place for branding and public URLs, so a rename only touches this file
// (plus APP_DISPLAY_NAME in the Xcode build settings).
enum AppConfig {
    static let appName      = "VallartApp"
    static let tagline      = "Puerto Vallarta in your pocket"
    static let supportEmail = "support@vallartapp.com"

    // Public site served by the admin panel (Next.js). Must be live before App Review.
    static let webBaseURL   = URL(string: "https://vallartapp.com")!

    static var privacyURL:  URL { webBaseURL.appendingPathComponent("privacy") }
    static var termsURL:    URL { webBaseURL.appendingPathComponent("terms") }
    static var supportURL:  URL { webBaseURL.appendingPathComponent("support") }
    static var businessURL: URL { webBaseURL.appendingPathComponent("business/login") }
    static var supportMailURL: URL { URL(string: "mailto:\(supportEmail)")! }
    static var businessContactURL: URL { URL(string: "mailto:\(supportEmail)?subject=List%20my%20business")! }
}
