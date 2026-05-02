import SwiftUI

// MARK: - Chores Tab Filter
enum ChoresFilter: String, CaseIterable {
    case today = "Today"
    case upcoming = "Upcoming"
    case all = "All"
}

// MARK: - Main Chores View
struct ChoresView: View {
    @EnvironmentObject var appState: AppState
    @State private var filter: ChoresFilter = .today
    @State private var showAddChore = false
    @State private var selectedChore: Chore? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    filterBar
                    Divider().background(CozyTheme.border).opacity(0.5)
                    choreList
                }
                ChoreFAB { showAddChore = true }
            }
            .navigationTitle("Chores")
            .navigationBarTitleDisplayMode(.large)
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
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 0) {
            ForEach(ChoresFilter.allCases, id: \.self) { f in
                FilterPill(title: f.rawValue, selected: filter == f) {
                    withAnimation(.easeInOut(duration: 0.18)) { filter = f }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
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
                            RoomSectionHeader(room: section.room)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Grouping
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
        // unmatched rooms
        let knownIds = Set(Room.defaults.map(\.id))
        let other = chores.filter { !knownIds.contains($0.roomId) }
        if !other.isEmpty {
            let r = Room(id: "other", name: "Other", icon: "archivebox", color: "F1F8E9")
            result.append(RoomSection(room: r, chores: other))
        }
        return result
    }
}

// MARK: - Filter Pill
private struct FilterPill: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: selected ? .semibold : .regular))
                    .foregroundColor(selected ? CozyTheme.accent : CozyTheme.mutedText)
                Rectangle()
                    .fill(selected ? CozyTheme.accent : Color.clear)
                    .frame(height: 2)
                    .cornerRadius(1)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Room Section Header
private struct RoomSectionHeader: View {
    let room: Room
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: room.icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.accent)
            Text(room.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(CozyTheme.background)
    }
}

// MARK: - Chore Row
struct ChoreRow: View {
    @EnvironmentObject var appState: AppState
    let chore: Chore

    private var isOverdue: Bool {
        !chore.isDone && chore.scheduledDate < appState.todayString
    }

    var body: some View {
        HStack(spacing: 14) {
            checkCircle
            choreInfo
            Spacer(minLength: 4)
            dateBadge
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(CozyTheme.background)
        Divider()
            .padding(.leading, 58)
            .background(CozyTheme.border.opacity(0.4))
    }

    private var checkCircle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                appState.toggleChore(chore)
            }
        } label: {
            ZStack {
                Circle()
                    .stroke(chore.isDone ? Color(hex: "4CAF82") : CozyTheme.border, lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                if chore.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "4CAF82"))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var choreInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(chore.choreName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                .strikethrough(chore.isDone, color: CozyTheme.mutedText)
            HStack(spacing: 6) {
                let room = Room.defaults.first { $0.id == chore.roomId }
                Image(systemName: room?.icon ?? "archivebox")
                    .font(.system(size: 11))
                    .foregroundColor(CozyTheme.mutedText)
                Text(room?.name ?? chore.roomId)
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
    }

    @ViewBuilder
    private var dateBadge: some View {
        if appState.todayString != chore.scheduledDate {
            let label = isOverdue ? "Overdue" : formattedDate
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isOverdue ? .white : CozyTheme.mutedText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isOverdue ? Color(hex: "E57373") : CozyTheme.border.opacity(0.5))
                .cornerRadius(8)
        }
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let d = fmt.date(from: chore.scheduledDate) else { return chore.scheduledDate }
        let out = DateFormatter(); out.dateFormat = "MMM d"
        return out.string(from: d)
    }
}

// MARK: - FAB
private struct ChoreFAB: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(CozyTheme.primary)
                .frame(width: 56, height: 56)
                .background(CozyTheme.accent)
                .cornerRadius(28)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 28)
        .padding(.trailing, 24)
    }
}

// MARK: - Empty State
private struct ChoresEmptyState: View {
    let filter: ChoresFilter
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(emptyTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text(emptySubtitle)
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitle: String {
        switch filter {
        case .today: return "Nothing due today"
        case .upcoming: return "No upcoming chores"
        case .all: return "No chores yet"
        }
    }

    private var emptySubtitle: String {
        switch filter {
        case .today: return "Tap + to add a chore for today."
        case .upcoming: return "Schedule chores to see them here."
        case .all: return "Add your first chore to get started."
        }
    }
}
