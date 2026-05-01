import SwiftUI

enum CozyTheme {
    // MARK: - Core Colors (warm, human-intentional)
    static let background  = Color(hex: "FBF8F3")  // unbleached linen
    static let card        = Color(hex: "FFFFFF")
    static let border      = Color(hex: "EAE5DE")  // pencil-on-paper hairline
    static let primary     = Color(hex: "2B2520")  // warm brown — reads "sophisticated home"
    static let mutedText   = Color(hex: "9B9489")  // warm gray — quiet and readable
    static let accent      = Color(hex: "BA7517")  // beeswax amber — inviting not urgent
    static let teal        = Color(hex: "5C9B8D")  // sage — calm earthy completion
    static let yellow      = Color(hex: "D4A574")  // terracotta — cozy rewards

    // MARK: - Room Colors (warmed)
    static let kitchenColor    = Color(hex: "FFF3DC")  // buttery
    static let bedroomColor    = Color(hex: "F0E8E0")  // warm taupe
    static let bathroomColor   = Color(hex: "E4EEF2")  // cool mist
    static let livingRoomColor = Color(hex: "FDF3E3")  // amber cream
    static let outdoorColor    = Color(hex: "E5EDDF")  // sage green
    static let otherColor      = Color(hex: "EDE6F5")  // soft violet

    // MARK: - Shape
    static let cornerRadius: CGFloat = 12
    static let pillRadius:   CGFloat = 28
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
