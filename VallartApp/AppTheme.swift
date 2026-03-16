import SwiftUI

// MARK: - AppTheme
enum AppTheme {

    enum Colors {
        static let coral        = Color(hex: "#FF6B6B")
        static let teal         = Color(hex: "#2EC4B6")
        static let sand         = Color(hex: "#F7F3E3")
        static let deepNavy     = Color(hex: "#1A2F4E")
        static let goldenSun    = Color(hex: "#FFB347")
        static let palmGreen    = Color(hex: "#4CAF50")
        static let nightPurple  = Color(hex: "#6C5CE7")
        static let oceanBlue    = Color(hex: "#0077B6")
        static let lightGray    = Color(hex: "#F2F2F7")
        static let mediumGray   = Color(hex: "#8E8E93")
        static let white        = Color.white
    }

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 24
        static let full: CGFloat = 999
    }

    enum Font {
        static func display(_ size: CGFloat = 32)   -> SwiftUI.Font { .system(size: size, weight: .bold,     design: .rounded) }
        static func headline(_ size: CGFloat = 20)  -> SwiftUI.Font { .system(size: size, weight: .semibold, design: .default) }
        static func body(_ size: CGFloat = 16)      -> SwiftUI.Font { .system(size: size, weight: .regular,  design: .default) }
        static func label(_ size: CGFloat = 14)     -> SwiftUI.Font { .system(size: size, weight: .medium,   design: .default) }
        static func caption(_ size: CGFloat = 12)   -> SwiftUI.Font { .system(size: size, weight: .regular,  design: .default) }
    }
}

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8)*17, (int >> 4 & 0xF)*17, (int & 0xF)*17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Color luminance helper
extension Color {
    /// True when the color is "light" (perceptual luminance > 0.55) — use dark text on top
    var isLight: Bool {
        // Resolve to UIColor/NSColor to extract RGB components
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif canImport(AppKit)
        guard let cgColor = NSColor(self).cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil),
              let comps = cgColor.components, comps.count >= 3 else { return false }
        let (r, g, b) = (comps[0], comps[1], comps[2])
        #endif
        // Perceived luminance (WCAG formula)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.55
    }
}

// MARK: - Cross-platform View modifiers
#if os(iOS) || os(visionOS)
extension View {
    func navTitleMode(_ mode: NavigationBarItem.TitleDisplayMode) -> some View {
        self.navigationBarTitleDisplayMode(mode)
    }
    func inputAutocap(_ style: TextInputAutocapitalization) -> some View {
        self.textInputAutocapitalization(style)
    }
    func iOSKeyboard(_ type: UIKeyboardType) -> some View {
        self.keyboardType(type)
    }
    func navBarHidden(_ hidden: Bool) -> some View {
        self.navigationBarHidden(hidden)
    }
}
#else
/// Fake enums so call sites compile on macOS without scattered #if blocks
enum NavTitleDisplayMode { case large, inline, automatic }
enum AutocapStyle        { case words, never, sentences, characters }
enum KeyboardStyle       { case emailAddress, `default`, numberPad }
extension View {
    func navTitleMode(_ mode: NavTitleDisplayMode) -> some View { self }
    func inputAutocap(_ style: AutocapStyle)       -> some View { self }
    func iOSKeyboard(_ type: KeyboardStyle)        -> some View { self }
    func navBarHidden(_ hidden: Bool)              -> some View { self }
}
#endif
