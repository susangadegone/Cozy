import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Cozy")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(CozyTheme.accent)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) { opacity = 1 }
            }
        }
    }
}
