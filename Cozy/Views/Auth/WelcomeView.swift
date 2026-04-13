import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appRouter: AppRouter

    private let benefits = [
        "Know what needs doing without the mental load",
        "Share chores without the conversation",
        "Build habits that actually stick"
    ]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                headline
                Spacer()
                benefitCards
                Spacer()
                buttons
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)
            .padding(.bottom, 44)
        }
    }

    private var headline: some View {
        Text("A calmer home\nstarts here.")
            .font(.system(size: 36, weight: .light, design: .serif))
            .foregroundColor(CozyTheme.primary)
            .lineSpacing(4)
    }

    private var benefitCards: some View {
        VStack(spacing: 12) {
            ForEach(benefits, id: \.self) { benefit in
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CozyTheme.accent)
                        .font(.system(size: 20))
                    Text(benefit)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(CozyTheme.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(16)
                .background(Color(hex: "F5EDE4"))
                .cornerRadius(14)
            }
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button { appRouter.navigate(to: .signUp) } label: {
                Text("Get started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(CozyTheme.primary)
                    .cornerRadius(CozyTheme.cornerRadius)
            }
            Button { appRouter.navigate(to: .login) } label: {
                Text("I already have an account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .overlay(
                        RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                            .stroke(CozyTheme.primary.opacity(0.4), lineWidth: 1.5)
                    )
                    .cornerRadius(CozyTheme.cornerRadius)
            }
        }
    }
}
