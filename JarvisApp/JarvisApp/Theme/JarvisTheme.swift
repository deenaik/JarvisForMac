import SwiftUI

enum JarvisTheme {
    // MARK: - Colors
    static let background = Color(hex: "0A0F1C")
    static let sidebar = Color(hex: "0F172A")
    static let card = Color(hex: "1E293B")
    static let accent = Color(hex: "22D3EE")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "94A3B8")
    static let textMuted = Color(hex: "64748B")
    static let label = Color(hex: "475569")

    // Status colors
    static let statusActive = Color(hex: "22C55E")
    static let statusWarning = Color(hex: "F59E0B")
    static let statusError = Color(hex: "EF4444")

    // MARK: - Radii
    static let cardRadius: CGFloat = 12
    static let buttonRadius: CGFloat = 8

    // MARK: - Spacing
    static let sidebarWidth: CGFloat = 240
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}
