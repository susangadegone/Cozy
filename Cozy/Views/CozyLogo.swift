import SwiftUI

// MARK: - CozyLogo
// SwiftUI port of the Broadsheet logo system from `Cozy Logo.html`.
// Three wordmarks + five icons — pick by style.
//
// Uses system serif (`.serif` design) so it works with no custom font installed.
// If you ever ship Newsreader as a bundled font, swap `.serif` for
// `.custom("Newsreader", size: …)` everywhere in this file.

// MARK: - Wordmark

enum CozyWordmarkStyle {
    case plain          // 1 · Just the serif word
    case dot            // 2 · Serif word + small red square (recommended)
    case masthead       // 3 · Full nameplate with rule + issue number
}

struct CozyWordmark: View {
    var style: CozyWordmarkStyle = .dot
    /// Visual scale. 1.0 ≈ 96pt serif word. Use ~0.35 for nav, 1.0 for splash.
    var scale: CGFloat = 1.0
    var color: Color = CozyTheme.primary
    var accent: Color = CozyTheme.accent

    var body: some View {
        switch style {
        case .plain:    plainMark
        case .dot:      dotMark
        case .masthead: mastheadMark
        }
    }

    private var wordSize: CGFloat { 96 * scale }
    private var tracking: CGFloat { -2.4 * scale }

    // 1 · Plain wordmark
    private var plainMark: some View {
        Text("Cozy")
            .font(.system(size: wordSize, weight: .medium, design: .serif))
            .tracking(tracking)
            .foregroundColor(color)
    }

    // 2 · Wordmark with red square seal — the pick
    private var dotMark: some View {
        HStack(alignment: .lastTextBaseline, spacing: 6 * scale) {
            Text("Cozy")
                .font(.system(size: wordSize, weight: .medium, design: .serif))
                .tracking(tracking)
                .foregroundColor(color)
            Rectangle()
                .fill(accent)
                .frame(width: 12 * scale, height: 12 * scale)
                .offset(y: -4 * scale)
        }
    }

    // 3 · Masthead lockup — kicker / word / rule / volume
    private var mastheadMark: some View {
        VStack(spacing: 8 * scale) {
            Text("THE MORNING EDITION")
                .font(.system(size: 11 * scale, weight: .semibold))
                .tracking(4.5 * scale)
                .foregroundColor(CozyTheme.mutedText)
            Text("Cozy")
                .font(.system(size: 92 * scale, weight: .medium, design: .serif))
                .tracking(-2.2 * scale)
                .foregroundColor(color)
            Rectangle()
                .fill(color)
                .frame(height: 2)
                .padding(.top, 6 * scale)
            Text("VOL. 1 · NO. 471")
                .font(.system(size: 10 * scale, weight: .medium))
                .tracking(2.4 * scale)
                .foregroundColor(CozyTheme.mutedText)
        }
        .fixedSize()
    }
}

// MARK: - Icon

enum CozyIconStyle {
    case cOnPaper       // 4 · Serif C on newsprint grey
    case cOnRed         // 5 · Serif C on front-page red
    case masthead       // 6 · Mini front-page composition
    case stamp          // 7 · Serif C in a thick ruled frame
    case inkWithMark    // 8 · Cream C on ink + red square corner (recommended)
}

struct CozyIcon: View {
    var style: CozyIconStyle = .inkWithMark
    /// The icon paints a square at this side length. 1024 in production; pass
    /// the actual rendered size in the UI (e.g. 64 for a nav avatar).
    var size: CGFloat = 1024

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(width: size, height: size)
        .clipped()
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .cOnPaper:    CozyTheme.background
        case .cOnRed:      CozyTheme.accent
        case .masthead:    CozyTheme.background
        case .stamp:       CozyTheme.background
        case .inkWithMark: CozyTheme.primary
        }
    }

    @ViewBuilder private var content: some View {
        switch style {
        case .cOnPaper:    bigC(color: CozyTheme.primary)
        case .cOnRed:      bigC(color: CozyTheme.background)
        case .stamp:       stampInterior
        case .inkWithMark: inkInterior
        case .masthead:    mastheadInterior
        }
    }

    // Shared glyph
    private func bigC(color: Color) -> some View {
        Text("C")
            .font(.system(size: size * 0.62, weight: .medium, design: .serif))
            .tracking(-size * 0.012)
            .foregroundColor(color)
            .offset(y: size * 0.02)
    }

    // 7 · Stamp
    private var stampInterior: some View {
        ZStack {
            Rectangle()
                .stroke(CozyTheme.primary, lineWidth: max(1, size * 0.012))
                .padding(size * 0.105)
            Text("C")
                .font(.system(size: size * 0.55, weight: .medium, design: .serif))
                .tracking(-size * 0.012)
                .foregroundColor(CozyTheme.primary)
                .offset(y: size * 0.012)
        }
    }

    // 8 · Ink with red mark
    private var inkInterior: some View {
        ZStack(alignment: .topTrailing) {
            Text("C")
                .font(.system(size: size * 0.62, weight: .medium, design: .serif))
                .tracking(-size * 0.012)
                .foregroundColor(CozyTheme.background)
                .offset(y: size * 0.02)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Rectangle()
                .fill(CozyTheme.accent)
                .frame(width: size * 0.055, height: size * 0.055)
                .padding(size * 0.055)
        }
    }

    // 6 · Masthead icon
    private var mastheadInterior: some View {
        VStack(spacing: 0) {
            Text("COZY")
                .font(.system(size: size * 0.043, weight: .semibold))
                .tracking(size * 0.016)
                .foregroundColor(CozyTheme.mutedText)
                .padding(.top, size * 0.11)
            Rectangle()
                .fill(CozyTheme.primary)
                .frame(height: max(1, size * 0.004))
                .padding(.horizontal, size * 0.11)
                .padding(.top, size * 0.025)
            Text("C")
                .font(.system(size: size * 0.4, weight: .medium, design: .serif))
                .tracking(-size * 0.012)
                .foregroundColor(CozyTheme.primary)
                .padding(.top, size * 0.04)
            Spacer(minLength: 0)
            Rectangle()
                .fill(CozyTheme.mutedText)
                .frame(height: max(1, size * 0.002))
                .padding(.horizontal, size * 0.11)
            Text("NO. 471")
                .font(.system(size: size * 0.027, weight: .medium))
                .tracking(size * 0.006)
                .foregroundColor(CozyTheme.mutedText)
                .padding(.top, size * 0.025)
                .padding(.bottom, size * 0.055)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SwiftUI Previews
#Preview("Wordmarks") {
    VStack(spacing: 40) {
        CozyWordmark(style: .plain, scale: 0.6)
        CozyWordmark(style: .dot,   scale: 0.6)
        CozyWordmark(style: .masthead, scale: 0.6)
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(CozyTheme.background)
}

#Preview("Icons") {
    let s: CGFloat = 140
    return VStack(spacing: 18) {
        HStack(spacing: 18) {
            CozyIcon(style: .cOnPaper,    size: s)
            CozyIcon(style: .cOnRed,      size: s)
            CozyIcon(style: .stamp,       size: s)
        }
        HStack(spacing: 18) {
            CozyIcon(style: .masthead,    size: s)
            CozyIcon(style: .inkWithMark, size: s)
        }
    }
    .padding(24)
    .background(Color(hex: "e9e6df"))
}
