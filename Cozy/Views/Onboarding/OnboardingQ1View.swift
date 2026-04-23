import SwiftUI

struct OnboardingQ1View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil

    private let options = [
        "Studio or 1-bed apartment",
        "2+ bedroom apartment",
        "House",
        "Other"
    ]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                OnboardingProgressBar(step: 1, total: 5)
                    .padding(.bottom, 28)
                questionHeader
                    .padding(.bottom, 24)
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
        Text("What kind of home do you live in?")
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
            onboardingVM.homeType = s
            appRouter.navigate(to: .onboardingQ2)
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
