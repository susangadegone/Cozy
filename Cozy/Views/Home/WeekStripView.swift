import SwiftUI

// MARK: - Week Calendar View
struct WeekCalendarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var weekOffset: Int
    @Binding var selectedChore: Chore?

    private var days: [Date] { CalendarHelpers.weekDays(offset: weekOffset) }

    var body: some View {
        VStack(spacing: 0) {
            weekNavBar
            Divider().background(CozyTheme.border).opacity(0.4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
                        WeekDayColumn(
                            day: day,
                            abbrev: CalendarHelpers.dayAbbreviations[idx],
                            chores: chores(for: day),
                            selectedChore: $selectedChore
                        )
                        if idx < 6 {
                            Divider()
                                .background(CozyTheme.border)
                                .opacity(0.4)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }

    private func chores(for date: Date) -> [Chore] {
        let ds = CalendarHelpers.dateString(date)
        return appState.chores.filter { $0.scheduledDate == ds }
            + CalendarHelpers.sampleChores(for: date, existing: appState.chores)
    }

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
            Text(weekOffset == 0 ? "This week" : weekLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
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
        let fmt = DateFormatter(); fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: first)) – \(fmt.string(from: last))"
    }
}

// MARK: - Single Day Column
private struct WeekDayColumn: View {
    @Binding var selectedChore: Chore?
    let day: Date
    let abbrev: String
    let chores: [Chore]

    init(day: Date, abbrev: String, chores: [Chore], selectedChore: Binding<Chore?>) {
        self.day = day
        self.abbrev = abbrev
        self.chores = chores
        self._selectedChore = selectedChore
    }

    private var isToday: Bool { CalendarHelpers.isToday(day) }
    private let col = UIScreen.main.bounds.width / 7

    var body: some View {
        VStack(spacing: 6) {
            dayHeader
            VStack(spacing: 4) {
                ForEach(chores) { chore in
                    WeekChoreChip(chore: chore)
                        .onTapGesture { selectedChore = chore }
                }
            }
            .padding(.horizontal, 3)
            Spacer(minLength: 0)
        }
        .frame(width: col)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(isToday ? Color(hex: "D4A574").opacity(0.06) : Color.clear)
    }

    private var dayHeader: some View {
        VStack(spacing: 3) {
            Text(abbrev)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            let dayNum = Calendar.current.component(.day, from: day)
            Text("\(dayNum)")
                .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                .foregroundColor(isToday ? .white : CozyTheme.primary)
                .frame(width: 26, height: 26)
                .background(isToday ? Color(hex: "D4A574") : Color.clear)
                .cornerRadius(13)
        }
    }
}

// MARK: - Chore Chip
private struct WeekChoreChip: View {
    let chore: Chore
    private var room: Room? { Room.defaults.first { $0.id == chore.roomId } }
    private var borderColor: Color { CalendarHelpers.roomBorderColor(for: chore.roomId) }

    var body: some View {
        let roomName = room?.name ?? chore.roomId.capitalized
        let label = "\(roomName): \(chore.choreName)"

        Text(label)
            .font(.system(size: 10))
            .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CalendarHelpers.roomColor(for: chore.roomId).opacity(chore.isDone ? 0.4 : 1.0))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .fill(borderColor)
                    .frame(width: 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
            .opacity(chore.isDone ? 0.6 : 1.0)
    }
}

// MARK: - Sample Data Fallback
extension CalendarHelpers {
    static func sampleChores(for date: Date, existing: [Chore]) -> [Chore] {
        let ds = dateString(date)
        guard !existing.contains(where: { $0.scheduledDate == ds }) else { return [] }
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let samples: [Int: [(String, String)]] = [
            2: [("kitchen", "Wipe counters"), ("living_room", "Vacuum")],
            3: [("bathroom", "Scrub toilet")],
            5: [("bedroom", "Change sheets"), ("kitchen", "Empty trash")],
            6: [("living_room", "Dust shelves")],
            7: [("outdoor", "Sweep porch")],
        ]
        return (samples[weekday] ?? []).map { roomId, name in
            Chore(
                id: UUID(), userId: UUID(), roomId: roomId, choreName: name,
                dayOfWeek: "", assignedTo: "You", isDone: false,
                scheduledDate: ds, completedAt: nil
            )
        }
    }
}
