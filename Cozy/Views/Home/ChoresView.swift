import SwiftUI

enum ChoresFilter: String, CaseIterable {
    case today = "Today"
    case upcoming = "Upcoming"
    case all = "All"
}

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
                    header
                    Divider().background(CozyTheme.border).opacity(0.5)
                    filterBar
                    libraryRow
                    choreList
                }
                CalFAB { showAddChore = true }
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
            ChoreLibraryView().environmentObject(appState)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("Chores")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var filterBar: some View {
        HStack(spacing: 0) {
            ForEach(ChoresFilter.allCases, id: \.self) { f in
                FilterPill(title: f.rawValue, selected: filter == f) {
                    withAnimation(.easeInOut(duration: 0.18)) { filter = f }
                }
            }
        }
        .padding(4)
        .background(CozyTheme.border.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var libraryRow: some View {
        Button { showLibrary = true } label: {
            HStack(spacing: 6) {
                Text("Browse chore library")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CozyTheme.accent)
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var choreList: some View {
        let grouped = groupedChores
        if grouped.isEmpty {
            EmptyState(filter: filter)
        } else {
            ScrollView {
                LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                    ForEach(grouped, id: \.room.id) { section in
                        Section {
                            ForEach(section.chores) { chore in
                                ChoreRow(chore: chore)
                                    .onTapGesture { selectedChore = chore }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            appState.deleteChore(chore)
                                        } label: { Label("Delete", systemImage: "trash") }
                                    }
                            }
                        } header: {
                            RoomHeader(room: section.room, count: section.chores.count)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
    }

    private var filteredChores: [Chore] {
        let today = appState.todayString
        switch filter {
        case .today:    return appState.chores.filter { $0.scheduledDate == today }
        case .upcoming: return appState.chores.filter { $0.scheduledDate > today }.sorted { $0.scheduledDate < $1.scheduledDate }
        case .all:      return appState.chores.sorted { $0.scheduledDate < $1.scheduledDate }
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
            result.append(RoomSection(
                room: Room(id: "other", name: "Other", icon: "archivebox", color: "EDE6F5"),
                chores: other
            ))
        }
        return result
    }
}

private struct FilterPill: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: selected ? .semibold : .regular))
                .foregroundColor(selected ? .white : CozyTheme.mutedText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(selected ? CozyTheme.accent : Color.clear)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

private struct RoomHeader: View {
    let room: Room
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: room.icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.accent)
            Text(room.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Text("\(count)")
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
        .background(CozyTheme.background)
    }
}

struct ChoreRow: View {
    @EnvironmentObject var appState: AppState
    let chore: Chore

    private var isOverdue: Bool {
        !chore.isDone && chore.scheduledDate < appState.todayString
    }

    var body: some View {
        HStack(spacing: 12) {
            checkBtn
            VStack(alignment: .leading, spacing: 3) {
                Text(chore.choreName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                    .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                    .lineLimit(2)
                if appState.todayString != chore.scheduledDate {
                    Text(isOverdue ? "Overdue" : formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(isOverdue ? CozyTheme.accent : CozyTheme.mutedText)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(CozyTheme.card)
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }

    private var checkBtn: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                appState.toggleChore(chore)
            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(chore.isDone ? CozyTheme.teal : CozyTheme.border, lineWidth: 1.5)
                    .background(Circle().fill(chore.isDone ? CozyTheme.teal : Color.clear))
                    .frame(width: 24, height: 24)
                if chore.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var formattedDate: String {
        guard let d = DateFormatters.yearMonthDay.date(from: chore.scheduledDate) else {
            return chore.scheduledDate
        }
        return DateFormatters.monthDay.string(from: d)
    }
}

private struct EmptyState: View {
    let filter: ChoresFilter
    var body: some View {
        VStack(spacing: 8) {
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
        case .today:    return "Nothing due today"
        case .upcoming: return "Quiet week ahead"
        case .all:      return "No chores yet"
        }
    }

    private var emptySubtitle: String {
        switch filter {
        case .today:    return "Tap the plus to add a new chore."
        case .upcoming: return "Schedule a chore to see it here."
        case .all:      return "Start with the chore library."
        }
    }
}
