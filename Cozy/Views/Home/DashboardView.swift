import SwiftUI

// MARK: - Dashboard
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    var onChoreComplete: () -> Void

    @State private var selectedChore: Chore? = nil
    @State private var selectedMood: String = ""
    @State private var showAllChores: Bool = false
    @State private var snoozeConfirmed: Bool = false

    // MARK: - Mood Logic
    private enum Mood: String {
        case allGood = "Fine"
        case manageable = "Manageable"
        case overwhelming = "Too much"
        case none = ""
    }
    private var mood: Mood { Mood(rawValue: selectedMood) ?? .none }

    /// Sort undone chores by name length (shorter = quicker wins) then append done chores
    private var prioritizedChores: [Chore] {
        let undone = appState.todayChores.filter { !$0.isDone }
            .sorted { $0.choreName.count < $1.choreName.count }
        let done = appState.todayChores.filter { $0.isDone }
        return undone + done
    }

    /// Chores shown based on mood — overwhelming = 1 quick win, manageable = top 3
    private var visibleChores: [Chore] {
        let sorted = prioritizedChores
        switch mood {
        case .overwhelming: return showAllChores ? sorted : Array(sorted.prefix(1))
        case .manageable:   return showAllChores ? sorted : Array(sorted.prefix(3))
        default:            return sorted
        }
    }

    private var hiddenCount: Int {
        let undone = appState.todayChores.filter { !$0.isDone }.count
        switch mood {
        case .overwhelming: return showAllChores ? 0 : max(0, undone - 1)
        case .manageable:   return showAllChores ? 0 : max(0, undone - 3)
        default:            return 0
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            greetingHeader
            moodRow
            moodBanner
            if mood != .overwhelming { weekProgressCard }
            todaySection
            if !upcomingChores.isEmpty && mood != .overwhelming { upcomingCard }
            if !appState.memberBreakdown.isEmpty && mood == .none { householdSection }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 120)
        .sheet(item: $selectedChore) { chore in
            ChoreDetailView(chore: chore)
                .environmentObject(appState)
        }
    }

    // MARK: Greeting Header
    private var greetingHeader: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return Text(formatter.string(from: Date()))
            .font(.system(size: 22, weight: .bold, design: .serif))
            .foregroundColor(CozyTheme.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }

    // MARK: Mood Row — word pills
    private var moodRow: some View {
        HStack(spacing: 8) {
            ForEach(["Fine", "Manageable", "Too much"], id: \.self) { m in
                let isOn = selectedMood == m
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMood = isOn ? "" : m
                        showAllChores = false
                        snoozeConfirmed = false
                    }
                } label: {
                    Text(m)
                        .font(.system(size: 12, weight: isOn ? .semibold : .regular))
                        .foregroundColor(isOn ? .white : CozyTheme.primary)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(isOn ? moodColor(m) : Color.clear)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isOn ? moodColor(m) : CozyTheme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
            }
            Spacer()
            if !selectedMood.isEmpty {
                Button {
                    withAnimation { selectedMood = ""; showAllChores = false; snoozeConfirmed = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(CozyTheme.mutedText).font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func moodColor(_ m: String) -> Color {
        switch m {
        case "Fine":     return Color(hex: "4CAF82")
        case "Manageable":   return CozyTheme.accent
        case "Too much": return Color(hex: "E57373")
        default:             return CozyTheme.accent
        }
    }

    // MARK: Mood Banner — empathetic, functional
    @ViewBuilder
    private var moodBanner: some View {
        switch mood {
        case .allGood:
            HStack(spacing: 8) {
                Circle().fill(moodColor("Fine")).frame(width: 7, height: 7)
                Text("\(appState.todayChores.count) chores today. That's it.")
                    .font(.system(size: 12)).foregroundColor(CozyTheme.mutedText)
                Spacer()
            }
            .transition(.opacity)
        case .manageable:
            let total = appState.todayChores.filter { !$0.isDone }.count
            HStack(spacing: 8) {
                Circle().fill(moodColor("Manageable")).frame(width: 7, height: 7)
                Text(total <= 3 ? "\(total) left today. You're close." : "Showing your top 3 of \(total) remaining.")
                    .font(.system(size: 12)).foregroundColor(CozyTheme.mutedText)
                Spacer()
            }
            .transition(.opacity)
        case .overwhelming:
            VStack(alignment: .leading, spacing: 8) {
                let total = appState.todayChores.filter { !$0.isDone }.count
                HStack(spacing: 8) {
                    Circle().fill(moodColor("Too much")).frame(width: 7, height: 7)
                    Text(total <= 1 ? "Just one thing. You can do this." : "Pick one. The rest waits.")
                        .font(.system(size: 12)).foregroundColor(CozyTheme.mutedText)
                    Spacer()
                }
                if !snoozeConfirmed && hiddenCount > 0 {
                    Button {
                        withAnimation { snoozeChores(); snoozeConfirmed = true }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "moon.zzz.fill").font(.system(size: 12))
                            Text("Push \(hiddenCount) to tomorrow")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "E57373"))
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "E57373").opacity(0.08))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "E57373").opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                } else if snoozeConfirmed {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "4CAF82")).font(.system(size: 13))
                        Text("\(hiddenCount) chore\(hiddenCount == 1 ? "" : "s") moved to tomorrow — take it easy.")
                            .font(.system(size: 12)).foregroundColor(CozyTheme.mutedText)
                    }
                }
            }
            .transition(.opacity)
        default:
            EmptyView()
        }
    }

    private func snoozeChores() {
        let all = appState.todayChores.filter { !$0.isDone }
        let toSnooze = mood == .overwhelming ? Array(all.dropFirst(1)) : Array(all.dropFirst(3))
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        for chore in toSnooze {
            appState.rescheduleChore(chore, to: tomorrow)
        }
    }

    // MARK: Week Progress
    private var weekProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("This week")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                if appState.currentStreak > 0 {
                    Text("\(appState.currentStreak)-day streak")
                        .font(.system(size: 11))
                        .foregroundColor(CozyTheme.accent)
                }
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
                let title: String = {
                    switch mood {
                    case .overwhelming: return "Start here"
                    case .manageable: return "Today"
                    default: return "Today's Chores"
                    }
                }()
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                if mood == .manageable && appState.todayChores.filter({ !$0.isDone }).count > 3 {
                    Text("\(appState.totalToday) total")
                        .font(.system(size: 11))
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
            let shown = visibleChores
            if shown.isEmpty {
                emptyTodayState
            } else {
                ForEach(shown) { chore in
                    DashChoreRow(chore: chore) { appState.toggleChore(chore) }
                        .contentShape(Rectangle())
                        .onTapGesture { selectedChore = chore }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { appState.deleteChore(chore) }
                                label: { Label("Delete", systemImage: "trash") }
                        }
                }
                if hiddenCount > 0 && !showAllChores {
                    Button { withAnimation(.spring()) { showAllChores = true } } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.down.circle")
                                .font(.system(size: 12))
                            Text("+ \(hiddenCount) more chore\(hiddenCount == 1 ? "" : "s")")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(CozyTheme.mutedText)
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
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
                Text("Nothing due today.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                Text("Set up your first chore to get started.")
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    // MARK: Upcoming Chores
    private var upcomingChores: [Chore] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return appState.chores.filter { !$0.isDone }.filter {
            guard let d = fmt.date(from: $0.scheduledDate) else { return false }
            let diff = cal.dateComponents([.day], from: today, to: cal.startOfDay(for: d)).day ?? 0
            return diff > 0 && diff <= 3
        }
    }

    private var upcomingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Coming up")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(upcomingChores) { chore in
                        upcomingChip(chore)
                    }
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private func upcomingChip(_ chore: Chore) -> some View {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let dayLabel: String = {
            guard let d = fmt.date(from: chore.scheduledDate) else { return chore.dayOfWeek }
            let diff = cal.dateComponents([.day], from: today, to: cal.startOfDay(for: d)).day ?? 0
            if diff == 1 { return "Tomorrow" }
            let df = DateFormatter()
            df.dateFormat = "EEE"
            return df.string(from: d)
        }()
        return VStack(alignment: .leading, spacing: 3) {
            Text(chore.choreName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(CozyTheme.primary)
                .lineLimit(1)
            Text(dayLabel)
                .font(.system(size: 10))
                .foregroundColor(CozyTheme.mutedText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(CozyTheme.card)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(CozyTheme.border, lineWidth: 1))
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

    // MARK: Activity Feed (retained, not shown in body per spec)
    private var activityFeedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activity")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            if appState.activityLog.isEmpty {
                Text("No activity yet.")
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
            checkButton
            choreInfo
            Spacer()
            assigneeAvatar
        }
        .padding(.vertical, 3)
        .opacity(chore.isDone ? 0.55 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: chore.isDone)
    }

    private var checkButton: some View {
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
    }

    private var choreInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(chore.choreName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                .strikethrough(chore.isDone, color: CozyTheme.mutedText)
            if let r = room {
                HStack(spacing: 4) {
                    Image(systemName: r.icon)
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(CozyTheme.mutedText)
                    Text(r.name)
                        .font(.system(size: 11))
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
            lastDoneLine
        }
    }

    @ViewBuilder
    private var lastDoneLine: some View {
        if let cat = chore.completedAt,
           let parsed = ISO8601DateFormatter().date(from: cat) {
            let days = Calendar.current.dateComponents([.day], from: parsed, to: Date()).day ?? 0
            Text("Last done \(days) days ago")
                .font(.system(size: 11))
                .foregroundColor(days > 7 ? Color(hex: "A03A1A") : CozyTheme.mutedText)
        }
    }

    @ViewBuilder
    private var assigneeAvatar: some View {
        if !chore.assignedTo.isEmpty {
            Text(chore.assignedTo.prefix(1).uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(CozyTheme.accent)
                .clipShape(Circle())
        }
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

// MARK: - Activity Feed Row
struct ActivityFeedRow: View {
    let entry: ActivityLog

    private var trailingEmoji: String {
        switch entry.type {
        case .choreDone: return "✅"
        case .choreAdded: return "➕"
        case .streakMilestone: return "🔥"
        case .badgeEarned: return "🏅"
        }
    }
    private var timeAgo: String {
        let s = Int(Date().timeIntervalSince(entry.timestamp))
        if s < 60 { return "just now" }
        if s < 3600 { return "\(s/60)m ago" }
        return "\(s/3600)h ago"
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(entry.text)
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.primary)
            Text(trailingEmoji)
                .font(.system(size: 13))
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
