import SwiftUI

private struct Q2HouseholdOption: Identifiable {
    let id: String
    let label: String
    let icon: String
    let isSolo: Bool
}

struct OnboardingQ2View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil

    private let options: [Q2HouseholdOption] = [
        Q2HouseholdOption(id: "solo",     label: "Just me",          icon: "person",           isSolo: true),
        Q2HouseholdOption(id: "partner",  label: "Me and a partner", icon: "person.2",         isSolo: false),
        Q2HouseholdOption(id: "family",   label: "Family with kids", icon: "house",            isSolo: false),
        Q2HouseholdOption(id: "roommates",label: "Roommates",        icon: "person.3.sequence", isSolo: false)
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                OnboardingProgressBar(step: 2, total: 5)
                    .padding(.bottom, 28)
                questionHeader.padding(.bottom, 24)
                grid
                Spacer()
                nextButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 44)
        }
    }

    private var questionHeader: some View {
        Text("Who shares your home with you?")
            .font(.system(size: 24, weight: .bold, design: .serif))
            .foregroundColor(CozyTheme.primary)
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options) { option in
                iconCard(option)
                    .onTapGesture { selection = option.id }
            }
        }
    }

    private func iconCard(_ option: Q2HouseholdOption) -> some View {
        let selected = selection == option.id
        return VStack(spacing: 10) {
            Image(systemName: option.icon)
                .font(.system(size: 32))
                .foregroundColor(selected ? .white : CozyTheme.accent)
            Text(option.label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selected ? .white : CozyTheme.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(selected ? CozyTheme.primary : Color(hex: "F5EDE4"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(selected ? CozyTheme.accent : Color.clear, lineWidth: 2)
        )
    }

    private var nextButton: some View {
        Button {
            guard let s = selection, let opt = options.first(where: { $0.id == s }) else { return }
            onboardingVM.householdType = opt.label
            onboardingVM.isSolo = opt.isSolo
            appRouter.navigate(to: .onboardingQ3)
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
