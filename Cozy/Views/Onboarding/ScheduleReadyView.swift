import SwiftUI

struct ScheduleReadyView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var headlineVisible = false
    @State private var summaryVisible = false
    @State private var cardVisible = false
    @State private var calendarVisible = false
    @State private var buttonVisible = false

    private var weekDays: [(label: String, index: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let sunday = cal.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: offset, to: sunday)!
            let label = cal.shortWeekdaySymbols[offset].prefix(2).uppercased()
            let dayIndex = offset  // 0 = Sun
            return (String(label), dayIndex)
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
            Color(hex: "FAF7F2").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headlineSection
                    summaryLine
                    firstChoreCard
                    calendarStrip
                    Spacer(minLength: 32)
                    letsGoButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 44)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { animateIn() }
    }

    private var headlineSection: some View {
        let name = onboardingVM.userName.isEmpty ? "friend" : onboardingVM.userName
        return Text("Your Cozy home is ready, \(name).")
            .font(.system(size: 28, weight: .bold, design: .serif))
            .foregroundColor(CozyTheme.primary)
            .opacity(headlineVisible ? 1 : 0)
            .offset(y: headlineVisible ? 0 : 18)
    }

    private var summaryLine: some View {
        let rooms = onboardingVM.selectedRooms.count
        let chores = onboardingVM.generatedSchedule.count
        return Text("We've set up \(rooms) room\(rooms == 1 ? "" : "s") with \(chores) chore\(chores == 1 ? "" : "s") spread across your week.")
            .font(.system(size: 16))
            .foregroundColor(CozyTheme.mutedText)
            .opacity(summaryVisible ? 1 : 0)
            .offset(y: summaryVisible ? 0 : 14)
    }

    private var firstChoreCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your first chore")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            Text(firstChore?.name ?? "Make bed")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            if let room = firstChore?.room {
                Text(room)
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.accent)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "F5EDE4"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CozyTheme.accent.opacity(0.3), lineWidth: 1.5))
        .opacity(cardVisible ? 1 : 0)
        .offset(y: cardVisible ? 0 : 12)
    }

    private var calendarStrip: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.index) { day in
                VStack(spacing: 6) {
                    Text(day.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(CozyTheme.mutedText)
                    Circle()
                        .fill(daysWithChores.contains(day.index) ? CozyTheme.accent : Color.clear)
                        .frame(width: 8, height: 8)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(CozyTheme.card)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CozyTheme.border, lineWidth: 1))
        .opacity(calendarVisible ? 1 : 0)
        .offset(y: calendarVisible ? 0 : 10)
    }

    private var letsGoButton: some View {
        Button { appRouter.navigate(to: .dashboard) } label: {
            Text("Let's go")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(CozyTheme.primary)
                .cornerRadius(CozyTheme.cornerRadius)
        }
        .opacity(buttonVisible ? 1 : 0)
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) { headlineVisible = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) { summaryVisible = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) { cardVisible = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) { calendarVisible = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) { buttonVisible = true }
    }
}
