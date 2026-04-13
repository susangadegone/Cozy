import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var opacity: Double = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(spacing: 14) {
                Text("🏠")
                    .font(.system(size: 72))
                    .scaleEffect(pulse ? 1.06 : 1.0)
                Text("Cozy")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Text("your home, your rhythm")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(CozyTheme.mutedText)
                    .italic()
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7)) { opacity = 1 }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(0.7)) {
                pulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                appRouter.navigate(to: .welcome)
            }
        }
    }
}
