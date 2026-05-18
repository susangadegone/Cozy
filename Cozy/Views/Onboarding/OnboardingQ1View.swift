import SwiftUI

struct OnboardingQ1View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil
    @State private var appeared = false

    private struct HomeOption: Identifiable {
        let id: String
        let icon: String
    }

    private let options: [HomeOption] = [
        HomeOption(id: "Studio or 1-bed apartment", icon: "building.2"),
        HomeOption(id: "2+ bedroom apartment",       icon: "building"),
        HomeOption(id: "House",                      icon: "house"),
        HomeOption(id: "Other",                      icon: "questionmark.square")
    ]

    var body: some View {
        OnboardingShell(step: 1, total: 5, onBack: { appRouter.navigate(to: .onboardingName) }) {
            questionHeader
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            optionsList
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            Spacer()
            OnboardingNextButton(isEnabled: selection != nil) {
                if let s = selection {
                    onboardingVM.homeType = s
                    onboardingVM.householdType = "Just me"
                    onboardingVM.isSolo = true
                    appRouter.navigate(to: .onboardingQ3)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What kind of home\ndo you live in?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
            Text("So we know how much there is to keep up with.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options) { option in
                OnboardingChoiceCard(
                    label: option.id,
                    icon: option.icon,
                    isSelected: selection == option.id
                ) { selection = option.id }
            }
        }
    }
}
