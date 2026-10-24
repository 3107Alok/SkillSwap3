import SwiftUI

// MARK: - SkillSwap Warm Cream & Forest Green Design System
enum Theme {
    // Primary Backgrounds
    static let creamBackground = Color(hex: "FAF3E3")
    static let creamCard = Color.white
    static let creamCardSecondary = Color(hex: "F8F4EC")
    
    // Forest Green Palette
    static let forestGreen = Color(hex: "1B3B2B")
    static let forestGreenDark = Color(hex: "132C20")
    static let forestGreenLight = Color(hex: "E8EFE8")
    static let forestGreenPill = Color(hex: "E3EDE5")
    static let forestGreenBorder = Color(hex: "D2E0D4")
    
    // Terracotta Palette
    static let terracotta = Color(hex: "D97451")
    static let terracottaDark = Color(hex: "C2613F")
    static let terracottaLight = Color(hex: "FDF2EE")
    static let terracottaBorder = Color(hex: "F6D5C8")
    
    // Neutrals & Text
    static let textPrimary = Color(hex: "192D23")
    static let textSecondary = Color(hex: "5A6E63")
    static let textMuted = Color(hex: "84968C")
    static let cardBorder = Color(hex: "EFE8DC")
    static let folderBg = Color(hex: "EFE9DE")
    static let shadow = Color(hex: "1B3B2B").opacity(0.06)
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
