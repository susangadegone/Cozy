import SwiftUI

// MARK: - Week Calendar View (Date Strip + Vertical List)
struct WeekCalendarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var weekOffset: Int
    @Binding var selectedChore: Chore?

    private var days: [Date] { CalendarHelpers.weekDays(offset: weekOffset) }

    var body: some View {
        VStack(spacing: 0) {
            weekNavBar
            DateStrip(
                days: days,
                selectedDate: appState.selectedDate,
                choresDates: Set(appState.chores.map(\.scheduledDate))
            ) { date in
                withAnimation(.easeInOut(duration: 0.15)) {
                    appState.selectedDate = date
                }
            }
            Divider().background(CozyTheme.border).opacity(0.4)
            dayChoreList
        }
    }

    // MARK: - Nav bar
    private var weekNavBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { weekOffset -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    weekOffset = 0
                    appState.selectedDate = Date()
                }
            } label: {
                Text(weekOffset == 0 ? "This week" : weekLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { weekOffset += 1 }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var weekLabel: String {
        guard let first = days.first, let last = days.last else { return "" }
        return "\(DateFormatters.monthDay.string(from: first)) – \(DateFormatters.monthDay.string(from: last))"
    }

    // MARK: - Day chore list
    @ViewBuilder
    private var dayChoreList: some View {
        let grouped = groupedByRoom
        if grouped.isEmpty {
            dayEmptyState
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
                            CalRoomHeader(room: section.room, count: section.chores.count)
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
        }
    }

    private struct RoomGroup { let room: Room; let chores: [Chore] }

    private var groupedByRoom: [RoomGroup] {
        let chores = appState.selectedDateChores
        var result: [RoomGroup] = []
        for room in Room.defaults {
            let rc = chores.filter { $0.roomId == room.id }
            if !rc.isEmpty { result.append(RoomGroup(room: room, chores: rc)) }
        }
        let knownIds = Set(Room.defaults.map(\.id))
        let other = chores.filter { !knownIds.contains($0.roomId) }
        if !other.isEmpty {
            result.append(RoomGroup(
                room: Room(id: "other", name: "Other", icon: "archivebox", color: "EDE6F5"),
                chores: other
            ))
        }
        return result
    }

    private var dayEmptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("Nothing scheduled")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("Tap + to add a chore for this day.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Cal Room Header
private struct CalRoomHeader: View {
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

// MARK: - Date Strip
private struct DateStrip: View {
    let days: [Date]
    let selectedDate: Date
    let choresDates: Set<String>
    let onSelect: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
                DateCell(
                    day: day,
                    abbrev: dayAbbrev(for: day),
                    isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                    isToday: CalendarHelpers.isToday(day),
                    hasDot: choresDates.contains(CalendarHelpers.dateString(day))
                ) {
                    onSelect(day)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func dayAbbrev(for date: Date) -> String {
        let abbrevs = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        return abbrevs[weekday]
    }
}

// MARK: - Date Cell
private struct DateCell: View {
    let day: Date
    let abbrev: String
    let isSelected: Bool
    let isToday: Bool
    let hasDot: Bool
    let onTap: () -> Void

    private var dayNum: Int { Calendar.current.component(.day, from: day) }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Text(abbrev)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(labelColor)
                ZStack {
                    Circle()
                        .fill(circleFill)
                        .frame(width: 34, height: 34)
                    Text("\(dayNum)")
                        .font(.system(size: 15, weight: isSelected || isToday ? .semibold : .regular))
                        .foregroundColor(numColor)
                }
                Circle()
                    .fill(hasDot ? dotColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var circleFill: Color {
        if isSelected { return CozyTheme.accent }
        return Color.clear
    }

    private var numColor: Color {
        if isSelected { return .white }
        if isToday { return CozyTheme.accent }
        return CozyTheme.primary
    }

    private var labelColor: Color {
        if isSelected { return CozyTheme.accent }
        if isToday { return CozyTheme.accent }
        return CozyTheme.mutedText
    }

    private var dotColor: Color {
        isSelected ? .white.opacity(0.7) : CozyTheme.accent.opacity(0.6)
    }
}
