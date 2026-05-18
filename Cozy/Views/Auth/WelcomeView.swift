import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                wordmark
                Spacer()
                benefits
                Spacer()
                buttons
            }
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 44)
        }
    }

    // MARK: - Wordmark
    private var wordmark: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image("CozyLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .blendMode(.multiply)
            Text("A calmer home starts here.")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    // MARK: - Benefits
    private var benefits: some View {
        VStack(alignment: .leading, spacing: 20) {
            benefitRow("Know what needs doing without the mental load")
            benefitRow("Share chores without the conversation")
            benefitRow("Build habits that actually stick")
        }
    }

    private func benefitRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(CozyTheme.accent)
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(CozyTheme.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    // MARK: - Buttons
    private var buttons: some View {
        VStack(spacing: 12) {
            Button { appRouter.navigate(to: .signUp) } label: {
                Text("Get started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(CozyTheme.accent)
                    .cornerRadius(CozyTheme.pillRadius)
            }
            Button { appRouter.navigate(to: .login) } label: {
                Text("I already have an account")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
        }
    }
}
