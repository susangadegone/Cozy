import SwiftUI

struct SplashView: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                Image("CozyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .blendMode(.multiply)

                VStack(spacing: 8) {
                    Text("A calmer home starts here.")
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(CozyTheme.primary)

                    Text("Gentle chore suggestions that fit your day.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(CozyTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onGetStarted) {
                        Text("Get started")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(CozyTheme.accent)
                            .cornerRadius(CozyTheme.pillRadius)
                    }

                    Button(action: onSignIn) {
                        Text("I already have an account")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(CozyTheme.mutedText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
        }
    }
}
