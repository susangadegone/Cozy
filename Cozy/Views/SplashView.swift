import SwiftUI

struct SplashView: View {
    let onContinue: () -> Void
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                Image("CozyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280)
                    .blendMode(.multiply)
                Spacer()
                Text("Tap to continue")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(.bottom, 56)
            }
            .opacity(opacity)
        }
        .contentShape(Rectangle())
        .onTapGesture { onContinue() }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
        }
    }
}
