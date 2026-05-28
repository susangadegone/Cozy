import SwiftUI

struct ScheduleReadyView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var appState: AppState

    @State private var appeared = false

    private var userName: String {
        onboardingVM.userName.isEmpty ? "you" : onboardingVM.userName
    }
    private var choreCount: Int { onboardingVM.generatedSchedule.count }
    private var dayCount: Int { Set(onboardingVM.generatedSchedule.map(\.dayIndex)).count }

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        titleBlock
                            .padding(.bottom, 8)
                        recapCard
                        planCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .padding(.bottom, 24)
                }
                continueButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    // MARK: - Title
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your plan, \(userName).")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("Here's what we put together based on your answers.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Recap: what you told us → what it shapes
    private var recapCard: some View {
        VStack(spacing: 0) {
            recapRow(
                label: "Home",
                value: onboardingVM.homeType.isEmpty ? "—" : onboardingVM.homeType,
                note: "Sets the scale of your chore list."
            )
            divider
            recapRow(
                label: "Rooms",
                value: roomsLine,
                note: "We seeded starter chores from these."
            )
            divider
            recapRow(
                label: "Pace",
                value: onboardingVM.cleaningRhythm.isEmpty ? "—" : onboardingVM.cleaningRhythm,
                note: "Spreads chores across the days that fit you."
            )
            divider
            recapRow(
                label: "Goal",
                value: cleanlinessLine,
                note: "Caps daily load so you don't burn out."
            )
            divider
            recapRow(
                label: "Reminders",
                value: onboardingVM.reminderStyle.isEmpty ? "—" : onboardingVM.reminderStyle,
                note: "When (or if) Cozy will nudge you."
            )
        }
        .padding(.vertical, 4)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                .stroke(CozyTheme.border, lineWidth: 1)
        )
    }

    private var divider: some View {
        Divider().background(CozyTheme.border).opacity(0.6).padding(.horizontal, 16)
    }

    private func recapRow(label: String, value: String, note: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .frame(width: 78, alignment: .leading)
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(note)
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Plan card (numbers)
    private var planCard: some View {
        HStack(spacing: 12) {
            planStat(value: "\(choreCount)", label: "chores / week")
            planStat(value: "\(dayCount)", label: "active days")
        }
    }

    private func planStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(CozyTheme.accent.opacity(0.14))
        .cornerRadius(CozyTheme.cornerRadius)
    }

    // MARK: - CTA
    private var continueButton: some View {
        Button {
            appRouter.navigate(to: .howCozyWorks)
        } label: {
            Text("Continue")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(CozyTheme.accent)
                .cornerRadius(CozyTheme.pillRadius)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Derived strings
    private var roomsLine: String {
        let r = onboardingVM.selectedRooms
        guard !r.isEmpty else { return "—" }
        return r.joined(separator: ", ")
    }

    private var cleanlinessLine: String {
        switch (onboardingVM.currentType, onboardingVM.goalType) {
        case (let c?, let g?) where c.rawValue == g.rawValue:
            return "Stay at \(c.rawValue.capitalized)"
        case (let c?, let g?):
            return "From \(c.rawValue.capitalized) to \(g.rawValue.capitalized)"
        case (let c?, nil):
            return c.rawValue.capitalized
        default:
            return "—"
        }
    }
}
