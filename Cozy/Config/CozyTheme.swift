import SwiftUI

enum CozyTheme {
    // MARK: - Core Colors
    static let background  = Color(hex: "F2EDE8")  // warm linen
    static let card        = Color(hex: "FFFFFF")
    static let border      = Color(hex: "E0D8D0")
    static let primary     = Color(hex: "1C1C1E")   // iOS system black
    static let mutedText   = Color(hex: "8E8E93")   // iOS gray
    static let accent      = Color(hex: "FF6B5A")   // coral — CTAs only
    static let teal        = Color(hex: "5DAFAB")   // done/complete
    static let yellow      = Color(hex: "F4D975")   // streak/rewards

    // MARK: - Deprecated room colors kept for backward compat
    static let kitchenColor    = Color(hex: "FFF0D6")
    static let bedroomColor    = Color(hex: "F5EDE6")
    static let bathroomColor   = Color(hex: "FDEEF4")
    static let livingRoomColor = Color(hex: "FFF5E6")
    static let outdoorColor    = Color(hex: "E8F5E9")
    static let otherColor      = Color(hex: "F0EBF5")

    // MARK: - Shape
    static let cornerRadius: CGFloat = 12   // cards / rows
    static let pillRadius:   CGFloat = 28   // buttons
    static let cardCornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
}

// MARK: - Hex initialiser
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64 = 255
        let r = (int >> 16) & 0xFF
        let g = (int >> 8)  & 0xFF
        let b =  int        & 0xFF
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
