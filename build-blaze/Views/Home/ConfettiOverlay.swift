import SwiftUI

struct ConfettiOverlay: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size)
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
        }
        .allowsHitTesting(false)
        .onAppear { spawnParticles() }
    }

    private func spawnParticles() {
        let colors: [Color] = [
            CozyTheme.accent,
            CozyTheme.primary,
            Color(hex: "FFF0D6"),
            Color(hex: "FDEEF4"),
            Color.orange,
            Color.yellow
        ]
        let screenW: CGFloat = UIScreen.main.bounds.width
        let screenH: CGFloat = UIScreen.main.bounds.height

        particles = (0..<90).map { i in
            ConfettiParticle(
                id: i,
                x: CGFloat.random(in: -screenW/2...screenW/2),
                y: -screenH / 2,
                size: CGFloat.random(in: 4...10),
                color: colors.randomElement() ?? .orange,
                opacity: 1
            )
        }

        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let targetY = CGFloat.random(in: 0...screenH/2)
            let targetX = particles[i].x + CGFloat.random(in: -60...60)
            withAnimation(.easeOut(duration: 1.5).delay(delay)) {
                particles[i].y = targetY
                particles[i].x = targetX
            }
            withAnimation(.easeIn(duration: 0.5).delay(delay + 1.2)) {
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}
