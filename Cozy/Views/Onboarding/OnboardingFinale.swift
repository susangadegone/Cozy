import SwiftUI

struct OnboardingFinale: View {
    let name: String
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.7
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
                .fill(CozyTheme.accent.opacity(0.12))
                .frame(width: 120, height: 120)
            Text("🏡")
                .font(.system(size: 64))
        }
    }

    private var titleText: some View {
        VStack(spacing: 6) {
            Text("You're all set,")
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(CozyTheme.mutedText)
            Text(name.isEmpty ? "friend!" : "\(name)!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(CozyTheme.primary)
        }
    }

    private var subtitleText: some View {
        Text("Your cozy home is ready.\nLet's keep it clean and happy ✨")
            .font(.system(size: 16))
            .foregroundColor(CozyTheme.mutedText)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            FinaleStatBadge(emoji: "🏠", label: "Rooms set")
            Divider()
                .frame(width: 1, height: 36)
                .background(CozyTheme.border)
            FinaleStatBadge(emoji: "✅", label: "Chores ready")
            Divider()
                .frame(width: 1, height: 36)
                .background(CozyTheme.border)
            FinaleStatBadge(emoji: "🔔", label: "Reminders on")
        }
        .padding(.vertical, 18)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                .stroke(CozyTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}

struct FinaleStatBadge: View {
    let emoji: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 22))
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Confetti overlay

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
        let screenH = UIScreen.main.bounds.height
        particles = (0..<70).map { i in
            FinaleParticle(
                id: i,
                symbol: symbols.randomElement()!,
                x: CGFloat.random(in: 0...screenW),
                y: CGFloat.random(in: -80...160),
                size: CGFloat.random(in: 14...26),
                opacity: 1.0,
                rotation: Double.random(in: 0...360)
            )
        }
        for i in particles.indices {
            let delay = Double(i) * 0.015
            withAnimation(.easeOut(duration: 2.0).delay(delay)) {
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
