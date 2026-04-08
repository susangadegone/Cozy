import SwiftUI

struct OnboardingStep1: View {
    @Binding var name: String

    var body: some View {
        VStack(spacing: 0) {
            heroSection
            inputSection
            Spacer()
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            Text("🏡")
                .font(.system(size: 72))
                .padding(.top, 8)
            Text("Welcome to Cozy")
                .font(.custom("Fraunces-Regular", size: 30))
                .foregroundColor(CozyTheme.primary)
                .multilineTextAlignment(.center)
            Text("Let's get your home set up.\nWhat should we call you?")
                .font(.custom("DMSans-Regular", size: 16))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.bottom, 40)
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your name")
                .font(.custom("DMSans-Medium", size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .padding(.horizontal, 24)
            TextField("e.g. Jamie", text: $name)
                .font(.custom("DMSans-Regular", size: 17))
                .foregroundColor(CozyTheme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(CozyTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                        .stroke(name.isEmpty ? CozyTheme.border : CozyTheme.accent, lineWidth: 1.5)
                )
                .cornerRadius(CozyTheme.cornerRadius)
                .padding(.horizontal, 24)
                .autocorrectionDisabled()
        }
    }
}
