import SwiftUI

// MARK: - Confetti Event Type
enum ConfettiEvent {
    case choreAdded   // 45 pieces, max 10px
    case choreDone    // 90 pieces, max 18px
    case badgeUnlock  // 90 pieces, max 18px
}

// MARK: - Spec Colors
private extension Color {
    static let confettiAmber    = Color(hex: "E8A000")
    static let confettiBrown    = Color(hex: "C47C3E")
    static let confettiTerra    = Color(hex: "D4785A")
    static let confettiGold     = Color(hex: "B8860B")
    static let confettiBrandDark = Color(hex: "5C3D2E")
    static let confettiBrandBg  = Color(hex: "FDF6F0")
}

private let confettiColors: [Color] = [
    .confettiAmber, .confettiBrown, .confettiTerra,
    .confettiGold, .confettiBrandDark, .confettiBrandBg
]

// MARK: - Overlay View
struct ConfettiOverlay: View {
    let event: ConfettiEvent
    @State private var particles: [ConfettiParticle] = []

    private var pieceCount: Int {
        switch event {
        case .choreAdded: return 45
        case .choreDone, .badgeUnlock: return 90
        }
    }

    private var maxSize: CGFloat {
        switch event {
        case .choreAdded: return 10
        case .choreDone, .badgeUnlock: return 18
        }
    }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                RoundedRectangle(cornerRadius: p.size * 0.3)
                    .fill(p.color)
                    .frame(width: p.size, height: p.size * 0.6)
                    .rotationEffect(.degrees(p.rotation))
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
        }
        .allowsHitTesting(false)
        .onAppear { spawnParticles() }
    }

    private func spawnParticles() {
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        let minSize: CGFloat = max(4, maxSize * 0.4)

        particles = (0..<pieceCount).map { i in
            ConfettiParticle(
                id: i,
                x: CGFloat.random(in: -screenW / 2 ... screenW / 2),
                y: -screenH * 0.4,
                size: CGFloat.random(in: minSize...maxSize),
                color: confettiColors.randomElement() ?? .confettiAmber,
                opacity: 1,
                rotation: Double.random(in: 0...360)
            )
        }

        for i in particles.indices {
            let delay = Double.random(in: 0...0.4)
            let targetY = CGFloat.random(in: screenH * 0.1 ... screenH * 0.6)
            let targetX = particles[i].x + CGFloat.random(in: -80...80)
            let spin = Double.random(in: 180...540)
            withAnimation(.easeOut(duration: 1.4).delay(delay)) {
                particles[i].y = targetY
                particles[i].x = targetX
                particles[i].rotation += spin
            }
            withAnimation(.easeIn(duration: 0.5).delay(delay + 1.1)) {
                particles[i].opacity = 0
            }
        }
    }
}

// MARK: - Particle model
struct ConfettiParticle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
    var rotation: Double
}
