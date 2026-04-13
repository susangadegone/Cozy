import SwiftUI

struct OnboardingQ3View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil

    private let options = [
        "A little every day",
        "Power session on weekends",
        "Mix of both",
        "Whenever something really needs it"
    ]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                OnboardingProgressBar(step: 3, total: 5)
                    .padding(.bottom, 28)
                questionHeader.padding(.bottom, 24)
                optionsList
                Spacer()
                nextButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 44)
        }
    }

    private var questionHeader: some View {
        Text("How do you prefer to handle chores?")
            .font(.system(size: 24, weight: .bold, design: .serif))
            .foregroundColor(CozyTheme.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                OnboardingChoiceCard(label: option, isSelected: selection == option) {
                    selection = option
                }
            }
        }
    }

    private var nextButton: some View {
        Button {
            guard let s = selection else { return }
            onboardingVM.cleaningRhythm = s
            appRouter.navigate(to: .onboardingQ4)
        } label: {
            Text("Next")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(selection == nil ? CozyTheme.primary.opacity(0.4) : CozyTheme.primary)
                .cornerRadius(CozyTheme.cornerRadius)
        }
        .disabled(selection == nil)
    }
}
