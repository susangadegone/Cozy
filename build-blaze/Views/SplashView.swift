import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("🏠")
                    .font(.system(size: 64))
                Text("Cozy")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Text("Keep your home sparkling")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
