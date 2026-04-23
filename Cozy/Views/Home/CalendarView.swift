import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var mode: CalendarMode = .week
    @State private var weekOffset: Int = 0
    @State private var displayMonth: Date = Date()
    @State private var selectedDay: Date? = nil
    @State private var showAddChore = false
    @State private var showDaySheet = false
    @State private var daySheetDate: Date = Date()

    enum CalendarMode { case week, month }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(hex: "FAF7F2").ignoresSafeArea()
                VStack(spacing: 0) {
                    calHeader
                    Divider().opacity(0.2)
                    Group {
                        if mode == .week { weekView }
                        else { monthView }
                    }
                    .animation(.easeInOut(duration: 0.18), value: mode)
                }
                fabButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .environmentObject(appState)
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showDaySheet) {
            DayChoresSheet(date: daySheetDate)
                .environmentObject(appState)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header
    private var calHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
            }
            Spacer()
            Picker("", selection: $mode) {
                Text("Week").tag(CalendarMode.week)
                Text("Month").tag(CalendarMode.month)
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Week View
    private var weekView: some View {
        VStack(spacing: 0) {
            weekNavBar
            weekDayHeaders
            Divider().opacity(0.15)
            weekChoreColumns
            Spacer()
        }
    }

    private var weekNavBar: some View {
        HStack {
            Button { weekOffset -= 1 } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Text(weekRangeLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
            Button { weekOffset += 1 } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var weekDayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { _, date in
                let isToday = Calendar.current.isDateInToday(date)
                VStack(spacing: 2) {
                    Text(shortDay(date))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(CozyTheme.mutedText)
                        .textCase(.uppercase)
                    ZStack {
                        if isToday {
                            Circle().fill(CozyTheme.primary).frame(width: 26, height: 26)
                        }
                        Text(dayNum(date))
                            .font(.system(size: 14, weight: isToday ? .bold : .regular))
                            .foregroundColor(isToday ? .white : CozyTheme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 4)
    }

    private var weekChoreColumns: some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(weekDates.enumerated()), id: \.offset) { _, date in
                    WeekDayChoreColumn(date: date, onTapChore: { _ in })
                        .environmentObject(appState)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Month View
    private var monthView: some View {
        VStack(spacing: 0) {
            monthNavBar
            monthWeekdayRow
            Divider().opacity(0.15)
            monthGridView
            Spacer()
        }
    }

    private var monthNavBar: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Text(monthLabel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var monthWeekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                Text(d)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    private var monthGridView: some View {
        let days = monthDays
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    let hasChores = choresFor(date).count > 0
                    let isToday = Calendar.current.isDateInToday(date)
                    let isSelected = selectedDay.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
                    Button {
                        selectedDay = date
                        daySheetDate = date
                        if hasChores { showDaySheet = true }
                    } label: {
                        VStack(spacing: 3) {
                            ZStack {
                                if isToday {
                                    Circle().fill(CozyTheme.primary).frame(width: 28, height: 28)
                                } else if isSelected {
                                    Circle().fill(CozyTheme.accent.opacity(0.18)).frame(width: 28, height: 28)
                                }
                                Text(dayNum(date))
                                    .font(.system(size: 14, weight: isToday || isSelected ? .bold : .regular))
                                    .foregroundColor(isToday ? .white : CozyTheme.primary)
                            }
                            if hasChores {
                                Circle()
                                    .fill(CozyTheme.accent)
                                    .frame(width: 5, height: 5)
                            } else {
                                Color.clear.frame(width: 5, height: 5)
                            }
                        }
                        .frame(height: 48)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(height: 48)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - FAB
    private var fabButton: some View {
        Button { showAddChore = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 54, height: 54)
                .background(CozyTheme.accent)
                .clipShape(Circle())
                .shadow(color: CozyTheme.accent.opacity(0.35), radius: 14, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 20)
        .padding(.bottom, 36)
    }

    // MARK: - Helpers
    private var headerTitle: String {
        mode == .week ? weekRangeLabel : monthLabel
    }

    var weekDates: [Date] {
        let cal = Calendar.current
        let today = Date()
        guard let ws = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let start = cal.date(byAdding: .weekOfYear, value: weekOffset, to: ws) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private var weekRangeLabel: String {
        guard let f = weekDates.first, let l = weekDates.last else { return "" }
        let fmt = DateFormatter(); fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: f)) – \(fmt.string(from: l))"
    }

    private var monthLabel: String {
        let fmt = DateFormatter(); fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayMonth)
    }

    private var monthDays: [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: displayMonth),
              let first = cal.date(from: cal.dateComponents([.year, .month], from: displayMonth)) else { return [] }
        let offset = cal.component(.weekday, from: first) - 1
        var days: [Date?] = Array(repeating: nil, count: offset)
        for d in range { days.append(cal.date(byAdding: .day, value: d - 1, to: first)) }
        return days
    }

    private func choresFor(_ date: Date) -> [Chore] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: date)
        return appState.chores.filter { $0.scheduledDate == key }
    }

    private func shiftMonth(_ delta: Int) {
        if let d = Calendar.current.date(byAdding: .month, value: delta, to: displayMonth) {
            withAnimation { displayMonth = d }
        }
    }

    private func shortDay(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: d)
    }
    private func dayNum(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: d)
    }
}

// MARK: - Week Day Chore Column
struct WeekDayChoreColumn: View {
    @EnvironmentObject var appState: AppState
    let date: Date
    let onTapChore: (Chore) -> Void

    private var chores: [Chore] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return appState.chores.filter { $0.scheduledDate == fmt.string(from: date) }
    }

    var body: some View {
        VStack(spacing: 4) {
            ForEach(chores) { chore in
                chorePill(chore)
            }
            if chores.isEmpty {
                Spacer().frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.horizontal, 2)
    }

    private func chorePill(_ chore: Chore) -> some View {
        Text(chore.choreName)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(chore.isDone ? CozyTheme.accent.opacity(0.5) : CozyTheme.accent)
            .cornerRadius(6)
            .opacity(chore.isDone ? 0.7 : 1.0)
    }
}

// MARK: - Day Chores Sheet
struct DayChoresSheet: View {
    @EnvironmentObject var appState: AppState
    let date: Date

    private var chores: [Chore] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return appState.chores.filter { $0.scheduledDate == fmt.string(from: date) }
    }

    private var dateLabel: String {
        let fmt = DateFormatter(); fmt.dateFormat = "EEEE, MMM d"
        return fmt.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(CozyTheme.border)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)

            Text(dateLabel)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider().opacity(0.2)

            if chores.isEmpty {
                VStack(spacing: 8) {
                    Text("No chores scheduled.")
                        .font(.system(size: 15))
                        .foregroundColor(CozyTheme.mutedText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(chores) { chore in
                            DaySheetChoreRow(chore: chore)
                            Divider().opacity(0.2).padding(.leading, 20)
                        }
                    }
                }
            }
            Spacer()
        }
        .background(Color(hex: "FAF7F2").ignoresSafeArea())
    }
}

private struct DaySheetChoreRow: View {
    @EnvironmentObject var appState: AppState
    let chore: Chore
    private var room: Room? { Room.defaults.first { $0.id == chore.roomId } }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder(chore.isDone ? Color(hex: "4CAF82") : CozyTheme.border, lineWidth: 2)
                    .frame(width: 24, height: 24)
                if chore.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "4CAF82"))
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(chore.choreName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                    .strikethrough(chore.isDone)
                if let r = room {
                    HStack(spacing: 4) {
                        Image(systemName: r.icon).font(.system(size: 10, weight: .light))
                        Text(r.name).font(.system(size: 12))
                    }
                    .foregroundColor(CozyTheme.mutedText)
                }
            }
            Spacer()
            Button {
                Task { await appState.toggleChore(chore) }
            } label: {
                Text(chore.isDone ? "Undo" : "Done")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.accent)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(CozyTheme.accent.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
