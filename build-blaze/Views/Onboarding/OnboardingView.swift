import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Text("🎉")
                    .font(.system(size: 64))
                Text("Onboarding Coming Soon")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Text("We'll walk you through setting up\nyour cozy household")
                    .font(.system(size: 16))
                    .foregroundColor(CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
                Spacer()
                Button {
                    Task {
                        if var p = appState.profile {
                            p.onboardingCompleted = true
                            p.rooms = ["kitchen", "bedroom", "bathroom", "living_room"]
                            p.displayName = "You"
                            try? await DataService.shared.updateProfile(p)
                            appState.profile = p
                            appState.needsOnboarding = false
                        }
                    }
                } label: {
                    Text("Skip for now")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(CozyTheme.primary)
                        .cornerRadius(CozyTheme.cornerRadius)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
