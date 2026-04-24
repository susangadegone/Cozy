import SwiftUI

private struct Q2Option: Identifiable {
    let id: String
    let label: String
    let icon: String
    let isSolo: Bool
}

struct OnboardingQ2View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil
    @State private var appeared = false

    private let options: [Q2Option] = [
        Q2Option(id: "solo",      label: "Just me",          icon: "person",            isSolo: true),
        Q2Option(id: "partner",   label: "Me & a partner",   icon: "person.2",          isSolo: false),
        Q2Option(id: "family",    label: "Family with kids", icon: "figure.and.child.holdinghands", isSolo: false),
        Q2Option(id: "roommates", label: "Roommates",        icon: "person.3.sequence",  isSolo: false)
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        OnboardingShell(step: 2, total: 5, onBack: { appRouter.navigate(to: .onboardingQ1) }) {
            questionHeader
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            iconGrid
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            Spacer()
            OnboardingNextButton(isEnabled: selection != nil) {
                guard let s = selection, let opt = options.first(where: { $0.id == s }) else { return }
                onboardingVM.householdType = opt.label
                onboardingVM.isSolo = opt.isSolo
                appRouter.navigate(to: .onboardingQ3)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("👥")
                .font(.system(size: 36))
            Text("Who shares your\nhome with you?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
        }
    }

    private var iconGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options) { opt in
                iconCard(opt)
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.18)) { selection = opt.id } }
            }
        }
    }

    private func iconCard(_ opt: Q2Option) -> some View {
        let selected = selection == opt.id
        return VStack(spacing: 12) {
            Image(systemName: opt.icon)
                .font(.system(size: 30))
                .foregroundColor(selected ? .white : CozyTheme.accent)
            Text(opt.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selected ? .white : CozyTheme.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 115)
        .background(selected ? CozyTheme.accent : CozyTheme.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(selected ? CozyTheme.accent : CozyTheme.border, lineWidth: selected ? 2 : 1)
        )
    }
}
