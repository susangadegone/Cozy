import SwiftUI

// MARK: - Chores Tab Filter
enum ChoresFilter: String, CaseIterable {
    case today = "Today"
    case upcoming = "Upcoming"
    case all = "All"
}

// MARK: - ChoresView · Broadsheet edition
// Tabbed index page (filter rules), department headers, hairline rows,
// square check marks, editorial date stamps. No mint green, no pill chips.
struct ChoresView: View {
    @EnvironmentObject var appState: AppState
    @State private var filter: ChoresFilter = .today
    @State private var showAddChore = false
    @State private var selectedChore: Chore? = nil
    @State private var showLibrary = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    sectionHeader
                    filterRule
                    libraryButton
                    choreList
                }
                ChoreFAB { showAddChore = true }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .environmentObject(appState)
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedChore) { chore in
            ChoreDetailView(chore: chore)
                .environmentObject(appState)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLibrary) {
            ChoreLibraryView()
                .environmentObject(appState)
        }
    }

    // MARK: - Section header (replaces large nav title)
    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SECTION B · CHORES")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2.6)
                .foregroundColor(CozyTheme.mutedText)
                .padding(.top, 8)
            Text("The Index")
                .font(.system(size: 32, weight: .regular, design: .serif))
                .tracking(-0.5)
                .foregroundColor(CozyTheme.primary)
                .padding(.top, 2)
            Text("Everything on the docket, by department.")
                .font(.system(size: 14, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(CozyTheme.mutedText)
                .padding(.top, 4)
                .padding(.bottom, 14)
            Rectangle().fill(CozyTheme.primary).frame(height: 2)
            Rectangle().fill(CozyTheme.primary).frame(height: 0.5)
                .padding(.top, 2)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }

    // MARK: - Filter rule (replaces pill bar)
    private var filterRule: some View {
        HStack(spacing: 0) {
            ForEach(ChoresFilter.allCases, id: \.self) { f in
                FilterTab(title: f.rawValue, selected: filter == f) {
                    withAnimation(.easeInOut(duration: 0.18)) { filter = f }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .overlay(
            Rectangle()
                .fill(CozyTheme.border)
                .frame(height: 1)
                .padding(.horizontal, 20),
            alignment: .bottom
        )
    }

    // MARK: - Library row (replaces rounded outline button)
    private var libraryButton: some View {
        Button { showLibrary = true } label: {
            HStack(spacing: 8) {
                Text("Browse the chore library")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                Text("→")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(CozyTheme.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(CozyTheme.background)
            .overlay(
                Rectangle()
                    .fill(CozyTheme.border)
                    .frame(height: 1)
                    .padding(.horizontal, 20),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Chore List
    @ViewBuilder
    private var choreList: some View {
        let grouped = groupedChores
        if grouped.isEmpty {
            ChoresEmptyState(filter: filter)
        } else {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(grouped, id: \.room.id) { section in
                        Section {
                            ForEach(section.chores) { chore in
                                ChoreRow(chore: chore)
                                    .onTapGesture { selectedChore = chore }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            appState.deleteChore(chore)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            DepartmentHeader(room: section.room, count: section.chores.count)
                        }
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - Grouping (unchanged behaviour)
    private var filteredChores: [Chore] {
        let today = appState.todayString
        switch filter {
        case .today:
            return appState.chores.filter { $0.scheduledDate == today }
        case .upcoming:
            return appState.chores.filter { $0.scheduledDate > today }
                .sorted { $0.scheduledDate < $1.scheduledDate }
        case .all:
            return appState.chores.sorted { $0.scheduledDate < $1.scheduledDate }
        }
    }

    private struct RoomSection { let room: Room; let chores: [Chore] }

    private var groupedChores: [RoomSection] {
        let chores = filteredChores
        var result: [RoomSection] = []
        for room in Room.defaults {
            let rc = chores.filter { $0.roomId == room.id }
            if !rc.isEmpty { result.append(RoomSection(room: room, chores: rc)) }
        }
        let knownIds = Set(Room.defaults.map(\.id))
        let other = chores.filter { !knownIds.contains($0.roomId) }
        if !other.isEmpty {
            let r = Room(id: "other", name: "Other", icon: "archivebox", color: "EDE6F5")
            result.append(RoomSection(room: r, chores: other))
        }
        return result
    }
}

// MARK: - Filter Tab (kicker label + heavy rule under selected)
private struct FilterTab: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: selected ? .semibold : .regular))
                    .tracking(2)
                    .foregroundColor(selected ? CozyTheme.primary : CozyTheme.mutedText)
                Rectangle()
                    .fill(selected ? CozyTheme.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Department Header (room banner, broadsheet style)
private struct DepartmentHeader: View {
    let room: Room
    let count: Int

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(roomDot(room.id))
                    .frame(width: 6, height: 6)
                Text(room.name.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(CozyTheme.primary)
            }
            Spacer()
            Text("\(count) ITEM\(count == 1 ? "" : "S")")
                .font(.system(size: 10, weight: .regular))
                .tracking(1.4)
                .foregroundColor(CozyTheme.mutedText)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 6)
        .background(CozyTheme.background)
        .overlay(
            Rectangle()
                .fill(CozyTheme.primary)
                .frame(height: 1.5)
                .padding(.horizontal, 20),
            alignment: .bottom
        )
    }

    private func roomDot(_ id: String) -> Color {
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
}

// MARK: - Chore Row (square mark, hairline divider, editorial date stamp)
struct ChoreRow: View {
    @EnvironmentObject var appState: AppState
    let chore: Chore

    private var isOverdue: Bool {
        !chore.isDone && chore.scheduledDate < appState.todayString
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                checkSquare
                choreInfo
                Spacer(minLength: 4)
                dateStamp
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .background(CozyTheme.background)

            Rectangle()
                .fill(CozyTheme.border)
                .frame(height: 1)
                .padding(.leading, 52)
        }
    }

    private var checkSquare: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                appState.toggleChore(chore)
            }
        } label: {
            ZStack {
                Rectangle()
                    .strokeBorder(chore.isDone ? CozyTheme.teal : CozyTheme.border, lineWidth: 1.5)
                    .background(Rectangle().fill(chore.isDone ? CozyTheme.teal : Color.clear))
                    .frame(width: 22, height: 22)
                if chore.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var choreInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(chore.choreName)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                .lineLimit(2)
            HStack(spacing: 6) {
                let room = Room.defaults.first { $0.id == chore.roomId }
                Text((room?.name ?? chore.roomId).uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.4)
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
    }

    @ViewBuilder
    private var dateStamp: some View {
        if appState.todayString != chore.scheduledDate {
            let label = isOverdue ? "OVERDUE" : formattedDate.uppercased()
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.3)
                .foregroundColor(isOverdue ? CozyTheme.accent : CozyTheme.mutedText)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .overlay(
                    Rectangle()
                        .stroke(isOverdue ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
                )
                .monospacedDigit()
        }
    }

    private var formattedDate: String {
        guard let d = DateFormatters.yearMonthDay.date(from: chore.scheduledDate) else {
            return chore.scheduledDate
        }
        return DateFormatters.monthDay.string(from: d)
    }
}

// MARK: - FAB (square ink button to match HomeView)
private struct ChoreFAB: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(CozyTheme.background)
                .frame(width: 56, height: 56)
                .background(CozyTheme.primary)
                .overlay(
                    Rectangle()
                        .inset(by: 4)
                        .stroke(CozyTheme.background, lineWidth: 1)
                )
                .shadow(color: CozyTheme.primary.opacity(0.22), radius: 0, x: 3, y: 3)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 28)
        .padding(.trailing, 24)
    }
}

// MARK: - Empty State (editorial)
private struct ChoresEmptyState: View {
    let filter: ChoresFilter
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("— NOTHING TO REPORT —")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(CozyTheme.mutedText)
            Text(emptyTitle)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text(emptySubtitle)
                .font(.system(size: 14, design: .serif))
                .italic()
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitle: String {
        switch filter {
        case .today:    return "Nothing due today."
        case .upcoming: return "Quiet week ahead."
        case .all:      return "No chores filed yet."
        }
    }

    private var emptySubtitle: String {
        switch filter {
        case .today:    return "Tap the plus to file a new chore."
        case .upcoming: return "Schedule a chore to see it here."
        case .all:      return "Begin with the chore library, perhaps."
        }
    }
}
