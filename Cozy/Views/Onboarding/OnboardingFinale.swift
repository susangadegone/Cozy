import SwiftUI

struct OnboardingFinale: View {
    let name: String
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var appState: AppState
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var isEntering = false

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            if showConfetti {
                SparseCalmConfetti()
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
        VStack(spacing: 28) {
            Spacer()
            houseIcon
            headingBlock
            Spacer()
            enterButton
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }

    private var houseIcon: some View {
        ZStack {
            Circle()
                .fill(CozyTheme.accent.opacity(0.12))
                .frame(width: 110, height: 110)
            Text("🏠")
                .font(.system(size: 52))
        }
    }

    private var headingBlock: some View {
        VStack(spacing: 12) {
            Text("Your home is ready, \(name.isEmpty ? "you" : name).")
                .font(.system(size: 26, weight: .semibold, design: .default))
                .foregroundColor(CozyTheme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Text("Your first chore is waiting.\nTakes about 20 minutes.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(CozyTheme.primary.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 40)
        }
    }

    private var enterButton: some View {
        Button {
            guard !isEntering else { return }
            isEntering = true
            if var p = appState.profile {
                p.onboardingCompleted = true
                appState.profile = p
                Task { try? await DataService.shared.updateProfile(p) }
            }
            appState.needsOnboarding = false
            appRouter.navigate(to: .dashboard)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: CozyTheme.pillRadius)
                    .fill(CozyTheme.accent)
                    .frame(height: 54)
                if isEntering {
                    ProgressView().tint(.white)
                } else {
                    Text("Enter my home →")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isEntering)
    }
}

// MARK: - Sparse Calm Confetti

struct SparseCalmConfetti: View {
    let particles: [CalmParticle] = (0..<20).map { _ in CalmParticle() }

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { p in
                FallingCircle(particle: p, totalHeight: geo.size.height)
                    .position(x: p.x * geo.size.width, y: p.startY * geo.size.height)
            }
        }
    }
}

struct CalmParticle: Identifiable {
    let id = UUID()
    let x: CGFloat = .random(in: 0...1)
    let startY: CGFloat = .random(in: -0.15...0.05)
    let size: CGFloat = .random(in: 5...10)
    let duration: Double = .random(in: 6...10)
    let delay: Double = .random(in: 0...3)
    let color: Color = [
        Color(red: 0.73, green: 0.42, blue: 0.28),
        Color(red: 0.96, green: 0.93, blue: 0.87),
        Color(red: 0.83, green: 0.64, blue: 0.45),
    ].randomElement()!
}

struct FallingCircle: View {
    let particle: CalmParticle
    let totalHeight: CGFloat
    @State private var offsetY: CGFloat = 0

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .opacity(0.5)
            .offset(y: offsetY)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay) {
                    withAnimation(
                        .linear(duration: particle.duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        offsetY = totalHeight * 1.3
                    }
                }
            }
    }
}
