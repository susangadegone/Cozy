import SwiftUI

enum CozyTheme {
    // MARK: - Core Colors
    static let primary = Color(hex: "5C3D2E")
    static let accent = Color(hex: "C47C3E")
    static let background = Color(hex: "FDF6F0")
    static let card = Color(hex: "FFF8F0")
    static let border = Color(hex: "E8DDD5")
    static let mutedText = Color(hex: "9B7E6E")

    // MARK: - Room Colors
    static let kitchenColor = Color(hex: "FFF0D6")
    static let bedroomColor = Color(hex: "F5EDE6")
    static let bathroomColor = Color(hex: "FDEEF4")
    static let livingRoomColor = Color(hex: "FFF5E6")
    static let outdoorColor = Color(hex: "E8F5E9")
    static let otherColor = Color(hex: "F0EBF5")

    // MARK: - Spacing
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 20
    static let padding: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64 = 255
        let r: UInt64 = (int >> 16) & 0xFF
        let g: UInt64 = (int >> 8) & 0xFF
        let b: UInt64 = int & 0xFF
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
