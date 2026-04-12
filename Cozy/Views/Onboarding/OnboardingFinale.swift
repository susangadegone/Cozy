import SwiftUI

struct OnboardingFinale: View {
    let name: String
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            if showConfetti {
                FinaleConfettiOverlay()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            contentStack
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showConfetti = true
            }
        }
    }

    private var contentStack: some View {
        VStack(spacing: 24) {
            Spacer()
            houseIcon
            titleText
            subtitleText
            statsRow
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }

    private var houseIcon: some View {
        ZStack {
            Circle()
                .fill(CozyTheme.accent.opacity(0.15))
                .frame(width: 130, height: 130)
            Text("🏡")
                .font(.system(size: 70))
        }
    }

    private var titleText: some View {
        VStack(spacing: 8) {
            Text("You're all set,")
                .font(.custom("Fraunces-Regular", size: 32))
                .foregroundColor(CozyTheme.mutedText)
            Text(name.isEmpty ? "Friend" : name + "!")
                .font(.custom("Fraunces-Regular", size: 38))
                .foregroundColor(CozyTheme.primary)
        }
    }

    private var subtitleText: some View {
        Text("Your cozy home is ready.\nLet's keep it clean and happy ✨")
            .font(.custom("DMSans-Regular", size: 16))
            .foregroundColor(CozyTheme.mutedText)
            .multilineTextAlignment(.center)
            .lineSpacing(5)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            FinaleStatBadge(emoji: "🏠", label: "Rooms set")
            Divider()
                .frame(width: 1, height: 40)
                .background(CozyTheme.border)
            FinaleStatBadge(emoji: "✅", label: "Chores ready")
            Divider()
                .frame(width: 1, height: 40)
                .background(CozyTheme.border)
            FinaleStatBadge(emoji: "🔔", label: "Reminders on")
        }
        .padding(.vertical, 20)
        .background(CozyTheme.card)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        .cornerRadius(CozyTheme.cardCornerRadius)
        .padding(.horizontal, 32)
    }
}

struct FinaleStatBadge: View {
    let emoji: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 24))
            Text(label)
                .font(.custom("DMSans-Regular", size: 12))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Confetti for Finale
struct FinaleConfettiOverlay: View {
    @State private var particles: [FinaleParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Text(p.symbol)
                    .font(.system(size: p.size))
                    .position(x: p.x, y: p.y)
                    .opacity(p.opacity)
                    .rotationEffect(.degrees(p.rotation))
            }
        }
        .onAppear { spawnParticles() }
    }

    private func spawnParticles() {
        let symbols = ["🎉","✨","🌟","🎊","💛","🧡","🌸","⭐","🎈","🍀"]
        let screenW = UIScreen.main.bounds.width
        particles = (0..<80).map { i in
            FinaleParticle(
                id: i,
                symbol: symbols.randomElement()!,
                x: CGFloat.random(in: 0...screenW),
                y: CGFloat.random(in: -100...200),
                size: CGFloat.random(in: 14...28),
                opacity: 1.0,
                rotation: Double.random(in: 0...360)
            )
        }
        let screenH = UIScreen.main.bounds.height
        for i in particles.indices {
            let delay = Double(i) * 0.015
            withAnimation(.easeOut(duration: 2.2).delay(delay)) {
                particles[i].y = screenH + 60
                particles[i].opacity = 0
                particles[i].rotation += Double.random(in: 180...540)
            }
        }
    }
}

struct FinaleParticle: Identifiable {
    let id: Int
    let symbol: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
    var rotation: Double
}
