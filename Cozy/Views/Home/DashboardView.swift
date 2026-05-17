import SwiftUI

// MARK: - Dashboard · Morning Paper Today screen
// Masthead date + italic lead + chores grouped by Smart Departments.
// Capped at 5 chores per day so nothing feels overwhelming.
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    var onChoreComplete: () -> Void

    @State private var selectedChore: Chore? = nil

    private let dayChoreCap = 5

    // MARK: Data helpers

    /// Today's chores, capped, undone first.
    private var capped: [Chore] {
        let all = appState.todayChores
        let undone = all.filter { !$0.isDone }
            .sorted { $0.choreName.count < $1.choreName.count }
        let done = all.filter { $0.isDone }
        return Array((undone + done).prefix(dayChoreCap))
    }

    private var allDone: Bool {
        !capped.isEmpty && capped.allSatisfy { $0.isDone }
    }

    /// Group chores by room. Rooms with 2+ chores get their own department;
    /// single-chore rooms collapse into "Loose ends".
    private struct Department: Identifiable {
        let id: String
        let name: String
        let chores: [Chore]
        let isLooseEnds: Bool
    }

    private var departments: [Department] {
        let grouped = Dictionary(grouping: capped, by: { $0.roomId })
        let multi = grouped.filter { $0.value.count >= 2 }
        let singles = grouped.filter { $0.value.count == 1 }.flatMap { $0.value }

        var out: [Department] = []
        for (roomId, items) in multi.sorted(by: { roomName($0.key) < roomName($1.key) }) {
            out.append(Department(id: roomId, name: roomName(roomId), chores: items, isLooseEnds: false))
        }
        if !singles.isEmpty {
            out.append(Department(id: "__loose", name: "Loose ends", chores: singles, isLooseEnds: true))
        }
        return out
    }

    private func roomName(_ id: String) -> String {
        Room.defaults.first(where: { $0.id == id })?.name ?? id.capitalized
    }

    private func roomDot(_ id: String) -> Color {
        // Editorial dots — saturated room colors tuned for newsprint grey.
        switch id {
        case "kitchen":  return Color(hex: "D49758")
        case "bedroom":  return Color(hex: "B084A8")
        case "bathroom": return Color(hex: "7BA3B6")
        case "living":   return Color(hex: "C58163")
        case "outdoor":  return Color(hex: "85A56F")
        case "laundry":  return Color(hex: "B8A172")
        default:         return Color(hex: "8E8675")
        }
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            masthead
            if capped.isEmpty {
                emptyState
            } else {
                departmentsList
            }
            footer
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 120)
        .sheet(item: $selectedChore) { chore in
            ChoreDetailView(chore: chore)
                .environmentObject(appState)
        }
    }

    // MARK: Masthead

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("The morning edition")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2.5)
                    .textCase(.uppercase)
                    .foregroundColor(CozyTheme.mutedText)
                Spacer()
                if appState.currentStreak > 0 {
                    HStack(spacing: 5) {
                        Text("\(appState.currentStreak)-day streak")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.4)
                            .textCase(.uppercase)
                    }
                    .foregroundColor(CozyTheme.accent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .overlay(Rectangle().stroke(CozyTheme.accent, lineWidth: 1))
                }
            }
            .padding(.top, 4)

            Text(DateFormatters.fullDate.string(from: Date()))
                .font(.system(size: 38, weight: .regular, design: .serif))
                .tracking(-0.8)
                .foregroundColor(CozyTheme.primary)
                .padding(.top, 6)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(leadSentence)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(CozyTheme.mutedText)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(CozyTheme.border)
                .frame(height: 1)
                .padding(.top, 16)
                .padding(.bottom, 18)
            journeyBadge
        }
    }

    /// One short editorial sentence summarising today.
    private var leadSentence: String {
        let undone = capped.filter { !$0.isDone }.count
        if allDone {
            return "Closing edition. The paper goes to bed."
        }
        if undone == 0 {
            return "Nothing scheduled. A quiet morning."
        }
        let roomCount = Set(capped.map { $0.roomId }).count
        if undone == 1 {
            return "One thing this morning. Won't take long."
        }
        if roomCount == 1 {
            let only = roomName(capped.first!.roomId).lowercased()
            return "\(undone) chores this morning, all in the \(only)."
        }
        return "\(undone) chores this morning, across \(roomCount) rooms."
    }

    @ViewBuilder
    private var journeyBadge: some View {
        let goalRaw = UserDefaults.standard.string(forKey: "cozy_goalType") ?? ""
        let currentRaw = UserDefaults.standard.string(forKey: "cozy_currentType") ?? ""
        let goal = CleanlinessType(rawValue: goalRaw)
        let current = CleanlinessType(rawValue: currentRaw)
        if let goal = goal {
            let weekNum = max(1, appState.currentStreak / 7 + 1)
            let sameType = current == goal
            let label = sameType
                ? "Maintaining your \(goal.rawValue) home \(goal.icon)"
                : "Week \(weekNum) toward \(goal.rawValue) \(goal.icon)"
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 11))
                    .foregroundColor(goal.accentColor)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(goal.accentColor)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(goal.accentColor.opacity(0.1))
            .cornerRadius(8)
            .padding(.bottom, 12)
        }
    }

    // MARK: Departments list

    private var departmentsList: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(departments) { dept in
                VStack(alignment: .leading, spacing: 0) {
                    departmentHeader(dept)
                    ForEach(dept.chores) { chore in
                        choreRow(chore)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { appState.deleteChore(chore) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }

    private func departmentHeader(_ dept: Department) -> some View {
        HStack {
            Text(dept.name)
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundColor(CozyTheme.primary)
            Spacer()
            let done = dept.chores.filter { $0.isDone }.count
            Text("\(done) / \(dept.chores.count)")
                .font(.system(size: 11))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundColor(CozyTheme.mutedText)
                .monospacedDigit()
        }
        .padding(.bottom, 6)
        .overlay(
            Rectangle()
                .fill(CozyTheme.primary)
                .frame(height: 1.5)
                .padding(.top, 6),
            alignment: .bottom
        )
    }

    @ViewBuilder
    private func choreRow(_ chore: Chore) -> some View {
        HStack(spacing: 12) {
            Button {
                let wasDone = chore.isDone
                appState.toggleChore(chore)
                if !wasDone { onChoreComplete() }
            } label: {
                squareMark(done: chore.isDone)
            }
            .buttonStyle(.plain)

            Button {
                selectedChore = chore
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(chore.choreName)
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                        .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(roomDot(chore.roomId))
                            .frame(width: 6, height: 6)
                        Text(roomName(chore.roomId))
                            .font(.system(size: 10, weight: .medium))
                            .tracking(1.4)
                            .textCase(.uppercase)
                            .foregroundColor(CozyTheme.mutedText)
                        if let line = lastDoneText(chore) {
                            Text("·")
                                .font(.system(size: 10))
                                .foregroundColor(CozyTheme.mutedText)
                            Text(line)
                                .font(.system(size: 10, weight: .medium))
                                .tracking(1.2)
                                .textCase(.uppercase)
                                .foregroundColor(CozyTheme.mutedText)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(CozyTheme.border)
                .frame(height: 1)
                .padding(.top, 0.5),
            alignment: .bottom
        )
    }

    private func squareMark(done: Bool) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(done ? CozyTheme.teal : CozyTheme.border, lineWidth: 1.5)
                .background(Rectangle().fill(done ? CozyTheme.teal : Color.clear))
                .frame(width: 22, height: 22)
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: done)
    }

    private func lastDoneText(_ chore: Chore) -> String? {
        guard let cat = chore.completedAt,
              let parsed = DateFormatters.iso8601.date(from: cat) else { return nil }
        let days = Calendar.current.dateComponents([.day], from: parsed, to: Date()).day ?? 0
        if days <= 0 { return nil }
        if days > 7 { return "overdue \(days)d" }
        return "last \(days)d ago"
    }

    // MARK: Empty + Footer

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No edition today.")
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Add a chore to begin your week.")
                .font(.system(size: 14, design: .serif))
                .italic()
                .foregroundColor(CozyTheme.mutedText)
        }
        .padding(.vertical, 40)
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(CozyTheme.border)
                .frame(height: 1)
                .padding(.top, 28)
            Text(footerText)
                .font(.system(size: 11, design: .serif))
                .italic()
                .foregroundColor(CozyTheme.mutedText)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var footerText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "— filed at half past eight —" }
        if hour < 17 { return "— afternoon edition —" }
        return "— evening edition, lamp lit —"
    }
}
