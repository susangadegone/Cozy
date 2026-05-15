import SwiftUI

struct ScheduleReadyView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var appState: AppState

    @State private var checkVisible  = false
    @State private var titleVisible  = false
    @State private var cardVisible   = false
    @State private var statsVisible  = false
    @State private var buttonVisible = false

    private var userName: String {
        onboardingVM.userName.isEmpty ? "you" : onboardingVM.userName
    }
    private var choreCount: Int { onboardingVM.generatedSchedule.count }
    private var estMinutes: Int { choreCount * 4 }

    private var daysWithChores: Set<Int> {
        Set(onboardingVM.generatedSchedule.map(\.dayIndex))
    }
    private let dayLabels = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    checkmarkSection
                    titleSection
                    weekCard
                    statChips
                    ctaButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear { animateIn() }
    }

    // MARK: - Checkmark
    private var checkmarkSection: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "E8F9F7"))
                .frame(width: 96, height: 96)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4ECDC4"), Color(hex: "3BB8B0")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
        }
        .scaleEffect(checkVisible ? 1 : 0.4)
        .opacity(checkVisible ? 1 : 0)
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Your plan is ready!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text("We built a realistic schedule just for \(userName).")
                .font(.system(size: 16))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
        }
        .opacity(titleVisible ? 1 : 0)
        .offset(y: titleVisible ? 0 : 12)
    }

    // MARK: - Week Card
    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your week at a glance")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .padding(.horizontal, 4)
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { idx in
                    weekDayPill(idx: idx)
                }
            }
        }
        .padding(20)
        .background(CozyTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(CozyTheme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        .opacity(cardVisible ? 1 : 0)
        .offset(y: cardVisible ? 0 : 18)
    }

    private func weekDayPill(idx: Int) -> some View {
        let active = daysWithChores.contains(idx)
        let choresOnDay = onboardingVM.generatedSchedule.filter { $0.dayIndex == idx }.count
        return VStack(spacing: 5) {
            Text(dayLabels[idx])
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(active ? Color(hex: "4ECDC4") : CozyTheme.mutedText)
            ZStack {
                Circle()
                    .fill(active ? Color(hex: "E8F9F7") : Color(hex: "F3F3F3"))
                    .frame(width: 32, height: 32)
                if active {
                    Text("\(choresOnDay)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "4ECDC4"))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stat chips
    private var statChips: some View {
        HStack(spacing: 12) {
            statChip(icon: "checklist", value: "\(choreCount) chores", sub: "per week")
            statChip(icon: "clock", value: "~\(estMinutes) min", sub: "per week")
        }
        .opacity(statsVisible ? 1 : 0)
        .offset(y: statsVisible ? 0 : 10)
    }

    private func statChip(icon: String, value: String, sub: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "4ECDC4"))
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CozyTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CozyTheme.border, lineWidth: 1))
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button {
            if var p = appState.profile {
                p.onboardingCompleted = true
                appState.profile = p
                LocalStore.shared.saveProfile(p)
            }
        } label: {
            HStack(spacing: 10) {
                Text("Start keeping it cozy")
                    .font(.system(size: 17, weight: .bold))
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: [Color(hex: "4ECDC4"), Color(hex: "3BB8B0")],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "4ECDC4").opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .opacity(buttonVisible ? 1 : 0)
        .scaleEffect(buttonVisible ? 1 : 0.94)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6).delay(0.1))  { checkVisible  = true }
        withAnimation(.easeOut(duration: 0.45).delay(0.4))                        { titleVisible  = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.6))  { cardVisible   = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.8))                         { statsVisible  = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0))   { buttonVisible = true }
    }
}
