import SwiftUI

// MARK: - Dashboard
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    var onChoreComplete: () -> Void
    var onAddChore: () -> Void
    var onCalendarTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            statRow
            weekProgressCard
            todaySection
            if !appState.memberBreakdown.isEmpty { householdSection }
            miniCalendarCard
            activityFeedCard
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 120)
    }

    // MARK: Stat Row
    private var statRow: some View {
        HStack(spacing: 8) {
            DashStatCard(label: "Week", value: "\(appState.weekTotal)", icon: "calendar", color: CozyTheme.accent)
            DashStatCard(label: "Done", value: "\(appState.weekDone)", icon: "checkmark.circle.fill", color: Color(hex: "4CAF82"))
            DashStatCard(label: "Left", value: "\(appState.weekRemaining)", icon: "clock.fill", color: Color(hex: "E07B5A"))
            DashStatCard(label: "Streak", value: "\(appState.currentStreak)", icon: "flame.fill", color: Color(hex: "C47C3E"), suffix: "🔥")
        }
    }

    // MARK: Week Progress
    private var weekProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Week Progress")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                Text("\(Int(appState.weekProgress * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(CozyTheme.accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(CozyTheme.border).frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(colors: [CozyTheme.accent, Color(hex: "E09A5A")],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, geo.size.width * appState.weekProgress), height: 10)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appState.weekProgress)
                }
            }
            .frame(height: 10)
        }
        .padding(14)
        .cardStyle()
    }

    // MARK: Today
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today's Chores")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                Button(action: onAddChore) {
                    Label("Add", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(CozyTheme.accent)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(CozyTheme.accent.opacity(0.12))
                        .cornerRadius(20)
                }
            }
            let sorted = appState.todayChores.sorted { !$0.isDone && $1.isDone }
            if sorted.isEmpty {
                emptyTodayState
            } else {
                ForEach(sorted) { chore in
                    DashChoreRow(chore: chore) {
                        Task {
                            let wasDone = chore.isDone
                            await appState.toggleChore(chore)
                            if !wasDone { onChoreComplete() }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) { Task { await appState.deleteChore(chore) } }
                            label: { Label("Delete", systemImage: "trash") }
                    }
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var emptyTodayState: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Text("🎉").font(.system(size: 30))
                Text("Nothing due today!")
                    .font(.system(size: 13)).foregroundColor(CozyTheme.mutedText)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    // MARK: Household
    private var householdSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Household")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            ForEach(appState.memberBreakdown, id: \.name) { m in
                MemberRow(emoji: m.emoji, name: m.name, done: m.done, total: m.total)
            }
        }
        .padding(14)
        .cardStyle()
    }

    // MARK: Mini Calendar
    private var miniCalendarCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("This Month")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                Button("Full view") { onCalendarTap() }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.accent)
            }
            MiniCalendarGrid(onDayTap: { date in
                appState.selectedDate = date
                onCalendarTap()
            })
            .environmentObject(appState)
        }
        .padding(14)
        .cardStyle()
    }

    // MARK: Activity Feed
    private var activityFeedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activity")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            if appState.activityLog.isEmpty {
                Text("No activity yet — complete a chore to get started! 🧹")
                    .font(.system(size: 13)).foregroundColor(CozyTheme.mutedText)
                    .padding(.vertical, 10)
            } else {
                ForEach(appState.activityLog.prefix(10)) { entry in
                    ActivityFeedRow(entry: entry)
                    if entry.id != appState.activityLog.prefix(10).last?.id {
                        Divider().opacity(0.4)
                    }
                }
            }
        }
        .padding(14)
        .cardStyle()
    }
}

// MARK: - Stat Card
struct DashStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    var suffix: String = ""

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)
            HStack(spacing: 1) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                if !suffix.isEmpty {
                    Text(suffix).font(.system(size: 12))
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        .shadow(color: CozyTheme.primary.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Chore Row
struct DashChoreRow: View {
    let chore: Chore
    let onToggle: () -> Void
    @State private var bouncing = false

    private var room: Room? { Room.defaults.first { $0.id == chore.roomId } }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bouncing = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { bouncing = false; onToggle() }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(chore.isDone ? Color(hex: "4CAF82") : CozyTheme.border, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if chore.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "4CAF82"))
                    }
                }
                .scaleEffect(bouncing ? 1.25 : 1.0)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(chore.choreName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                    .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                if let r = room {
                    Text("\(r.icon) \(r.name)")
                        .font(.system(size: 11))
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
            Spacer()
            if !chore.assignedTo.isEmpty {
                Text(chore.assignedTo.prefix(1).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(CozyTheme.accent)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 3)
        .opacity(chore.isDone ? 0.55 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: chore.isDone)
    }
}

// MARK: - Member Row
struct MemberRow: View {
    let emoji: String
    let name: String
    let done: Int
    let total: Int
    var progress: Double { total > 0 ? Double(done) / Double(total) : 0 }

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji).font(.system(size: 22))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(CozyTheme.primary)
                    Spacer()
                    Text("\(done)/\(total)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(CozyTheme.mutedText)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(CozyTheme.border).frame(height: 5)
                        Capsule().fill(Color(hex: "4CAF82"))
                            .frame(width: max(0, geo.size.width * progress), height: 5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Mini Calendar
struct MiniCalendarGrid: View {
    @EnvironmentObject var appState: AppState
    var onDayTap: (Date) -> Void
    private let cal = Calendar.current
    private let letters = ["S", "M", "T", "W", "T", "F", "S"]

    private var today: Date { cal.startOfDay(for: Date()) }

    private var monthDays: [Date?] {
        let comps = cal.dateComponents([.year, .month], from: today)
        guard let first = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: first) else { return [] }
        let offset = cal.component(.weekday, from: first) - 1
        var days: [Date?] = Array(repeating: nil, count: offset)
        for d in range { days.append(cal.date(byAdding: .day, value: d - 1, to: first)) }
        return days
    }

    private func dots(for date: Date) -> [Color] {
        let ds = appState.dateString(from: date)
        return appState.chores.filter { $0.scheduledDate == ds }.prefix(3).compactMap { chore -> Color? in
            guard let room = Room.defaults.first(where: { $0.id == chore.roomId }) else { return nil }
            return Color(hex: room.color)
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                ForEach(letters, id: \.self) { l in
                    Text(l).font(.system(size: 10, weight: .semibold))
                        .foregroundColor(CozyTheme.mutedText).frame(maxWidth: .infinity)
                }
            }
            let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
            LazyVGrid(columns: cols, spacing: 4) {
                ForEach(0..<monthDays.count, id: \.self) { i in
                    if let date = monthDays[i] {
                        calDayCell(date: date)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func calDayCell(date: Date) -> some View {
        let isToday = cal.isDate(date, inSameDayAs: today)
        let isSelected = cal.isDate(date, inSameDayAs: appState.selectedDate)
        let dotColors = dots(for: date)
        Button { onDayTap(date) } label: {
            VStack(spacing: 2) {
                Text("\(cal.component(.day, from: date))")
                    .font(.system(size: 12, weight: isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : isToday ? CozyTheme.accent : CozyTheme.primary)
                    .frame(width: 26, height: 26)
                    .background(
                        Circle().fill(isSelected ? CozyTheme.primary : isToday ? CozyTheme.accent.opacity(0.15) : Color.clear)
                    )
                HStack(spacing: 2) {
                    ForEach(0..<dotColors.count, id: \.self) { di in
                        Circle().fill(dotColors[di]).frame(width: 4, height: 4)
                    }
                }
                .frame(height: 5)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Feed Row
struct ActivityFeedRow: View {
    let entry: ActivityLog

    private var icon: String {
        switch entry.type {
        case .choreDone: return "checkmark.circle.fill"
        case .choreAdded: return "plus.circle.fill"
        case .streakMilestone: return "flame.fill"
        }
    }
    private var iconColor: Color {
        switch entry.type {
        case .choreDone: return Color(hex: "4CAF82")
        case .choreAdded: return CozyTheme.accent
        case .streakMilestone: return Color(hex: "E07B5A")
        }
    }
    private var timeAgo: String {
        let s = Int(Date().timeIntervalSince(entry.timestamp))
        if s < 60 { return "just now" }
        if s < 3600 { return "\(s/60)m ago" }
        return "\(s/3600)h ago"
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 15)).foregroundColor(iconColor).frame(width: 22)
            Text(entry.text).font(.system(size: 13)).foregroundColor(CozyTheme.primary)
            Spacer()
            Text(timeAgo).font(.system(size: 11)).foregroundColor(CozyTheme.mutedText)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Card Style Modifier
private extension View {
    func cardStyle() -> some View {
        self
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cardCornerRadius)
            .overlay(RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius).stroke(CozyTheme.border, lineWidth: 1))
            .shadow(color: CozyTheme.primary.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
