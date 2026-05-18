import SwiftUI

enum CozyTheme {
    // MARK: - Core (Claude warm palette: cream paper, ink, terracotta)
    static let background  = Color(hex: "F8F7F3")  // warm cream
    static let card        = Color(hex: "FFFFFF")  // white
    static let border      = Color(hex: "E0DED6")  // soft taupe
    static let primary     = Color(hex: "191915")  // near-black ink
    static let mutedText   = Color(hex: "8A8071")  // warm grey
    static let accent      = Color(hex: "B5A8D9")  // lavender — primary
    static let lavender    = Color(hex: "B5A8D9")  // alias
    static let lavenderDeep = Color(hex: "9285C2") // hover/pressed
    static let teal        = Color(hex: "6F9B7B")  // sage — done
    static let yellow      = Color(hex: "EFE5DA")  // peach cream — tile

    // MARK: - Room tints (soft pastels)
    static let kitchenColor    = Color(hex: "D9CFEC")  // lavender tile
    static let bedroomColor    = Color(hex: "D9CFEC")
    static let bathroomColor   = Color(hex: "D9CFEC")
    static let livingRoomColor = Color(hex: "EFE5DA")  // peach cream tile
    static let outdoorColor    = Color(hex: "EFE5DA")
    static let otherColor      = Color(hex: "EFE5DA")

    // MARK: - Shape
    static let cornerRadius: CGFloat = 14
    static let pillRadius:   CGFloat = 28
    static let cardCornerRadius: CGFloat = 18
    static let padding: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = (int >> 16) & 0xFF
        let g = (int >> 8)  & 0xFF
        let b =  int        & 0xFF
        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: 1)
    }
}
