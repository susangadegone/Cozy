import SwiftUI

enum CozyTheme {
    // MARK: - Core Colors (Broadsheet — newsprint grey paper, near-black ink, front-page red)
    static let background  = Color(hex: "E6E3DB")  // newsprint grey
    static let card        = Color(hex: "F1EEE6")  // raised surface, one notch above the paper
    static let border      = Color(hex: "B6B2A4")  // hairline rule
    static let primary     = Color(hex: "161512")  // near-black ink
    static let mutedText   = Color(hex: "787567")  // soft grey — captions, hints
    static let accent      = Color(hex: "B41E1E")  // front-page red — used sparingly
    static let teal        = Color(hex: "1F5C42")  // forest green — completion / done
    static let yellow      = Color(hex: "3B3A33")  // soft ink — secondary text (was warm yellow)

    // MARK: - Room Colors (kept; warm tints harmonize with newsprint grey)
    static let kitchenColor    = Color(hex: "FFF3DC")  // buttery
    static let bedroomColor    = Color(hex: "F0E8E0")  // warm taupe
    static let bathroomColor   = Color(hex: "E4EEF2")  // cool mist
    static let livingRoomColor = Color(hex: "FDF3E3")  // amber cream
    static let outdoorColor    = Color(hex: "E5EDDF")  // sage green
    static let otherColor      = Color(hex: "EDE6F5")  // soft violet

    // MARK: - Shape
    static let cornerRadius: CGFloat = 4         // square corners — editorial
    static let pillRadius:   CGFloat = 28
    static let cardCornerRadius: CGFloat = 4
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
