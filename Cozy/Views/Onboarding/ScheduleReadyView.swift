import SwiftUI

struct ScheduleReadyView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var headlineVisible = false
    @State private var summaryVisible  = false
    @State private var cardVisible     = false
    @State private var calendarVisible = false
    @State private var buttonVisible   = false

    private var weekDays: [(label: String, index: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let sunday = cal.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: offset, to: sunday)!
            let label = cal.shortWeekdaySymbols[offset].prefix(2).uppercased()
            _ = day
            return (String(label), offset)
        }
    }

    private var daysWithChores: Set<Int> {
        Set(onboardingVM.generatedSchedule.map(\.dayIndex))
    }

    private var firstChore: ScheduledChore? {
        onboardingVM.generatedSchedule.first
    }

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    checkmarkBadge
                    headlineSection
                    summaryLine
                    firstChoreCard
                    calendarStrip
                    Spacer(minLength: 32)
                    letsGoButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear { animateIn() }
    }

    // MARK: - Subviews

    private var checkmarkBadge: some View {
        ZStack {
            Circle()
                .fill(CozyTheme.teal.opacity(0.15))
                .frame(width: 68, height: 68)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(CozyTheme.teal)
        }
        .opacity(headlineVisible ? 1 : 0)
        .scaleEffect(headlineVisible ? 1 : 0.6)
    }

    private var headlineSection: some View {
        let name = onboardingVM.userName.isEmpty ? "friend" : onboardingVM.userName
        return VStack(alignment: .leading, spacing: 6) {
            Text("Your schedule is ready,")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text(name + " 🎉")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(CozyTheme.accent)
        }
        .opacity(headlineVisible ? 1 : 0)
        .offset(y: headlineVisible ? 0 : 16)
    }

    private var summaryLine: some View {
        let rooms = onboardingVM.selectedRooms.count
        let chores = onboardingVM.generatedSchedule.count
        return Text("We've set up **\(rooms) room\(rooms == 1 ? "" : "s")** with **\(chores) chore\(chores == 1 ? "" : "s")** spread across your week.")
            .font(.system(size: 16))
            .foregroundColor(CozyTheme.mutedText)
            .opacity(summaryVisible ? 1 : 0)
            .offset(y: summaryVisible ? 0 : 12)
    }

    private var firstChoreCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(CozyTheme.accent.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CozyTheme.accent)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("First chore")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                Text(firstChore?.name ?? "Make bed")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                if let room = firstChore?.room {
                    Text(room)
                        .font(.system(size: 13))
                        .foregroundColor(CozyTheme.accent)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                .stroke(CozyTheme.border, lineWidth: 1)
        )
        .opacity(cardVisible ? 1 : 0)
        .offset(y: cardVisible ? 0 : 10)
    }

    private var calendarStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your week at a glance")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.index) { day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(CozyTheme.mutedText)
                        Circle()
                            .fill(daysWithChores.contains(day.index) ? CozyTheme.accent : CozyTheme.border)
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(CozyTheme.border, lineWidth: 1)
            )
        }
        .opacity(calendarVisible ? 1 : 0)
        .offset(y: calendarVisible ? 0 : 10)
    }

    private var letsGoButton: some View {
        Button { appRouter.navigate(to: .dashboard) } label: {
            RoundedRectangle(cornerRadius: CozyTheme.pillRadius)
                .fill(CozyTheme.accent)
                .frame(height: 54)
                .overlay(
                    Text("Let's go →")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                )
        }
        .opacity(buttonVisible ? 1 : 0)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7))          { headlineVisible = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.2))                    { summaryVisible  = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.4))                    { cardVisible     = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.6))                    { calendarVisible = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.8))                    { buttonVisible   = true }
    }
}
