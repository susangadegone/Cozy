import SwiftUI

struct MonthView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    @State private var displayMonth: Date = Date()

    var body: some View {
        VStack(spacing: 0) {
            handle
            monthNavHeader
            weekdayLabels
            Divider().opacity(0.2)
            monthGrid
            Spacer()
        }
        .background(CozyTheme.background)
        .cornerRadius(24)
    }

    private var handle: some View {
        Capsule()
            .fill(CozyTheme.border)
            .frame(width: 36, height: 4)
            .padding(.top, 12)
    }

    private var monthNavHeader: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(10)
            }
            Spacer()
            Text(monthLabel)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(10)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var weekdayLabels: some View {
        HStack(spacing: 0) {
            ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                Text(d)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
    }

    private var monthGrid: some View {
        let days = monthDays
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    MonthDayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: appState.selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        dots: dotColors(for: date)
                    )
                    .onTapGesture {
                        appState.selectedDate = date
                        isPresented = false
                    }
                } else {
                    Color.clear.frame(height: 50)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private var monthDays: [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: displayMonth),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: displayMonth)) else { return [] }
        let weekday = cal.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: firstDay))
        }
        return days
    }

    private func dotColors(for date: Date) -> [Color] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: date)
        let dayChores = appState.chores.filter { $0.scheduledDate == key }
        let roomIds = Array(Set(dayChores.map { $0.roomId })).prefix(3)
        return roomIds.compactMap { rid in
            Room.defaults.first { $0.id == rid }.map { Color(hex: $0.color) }
        }
    }

    private var monthLabel: String {
        let fmt = DateFormatter(); fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayMonth)
    }

    private func shiftMonth(_ delta: Int) {
        let cal = Calendar.current
        if let newDate = cal.date(byAdding: .month, value: delta, to: displayMonth) {
            withAnimation { displayMonth = newDate }
        }
    }
}

struct MonthDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let dots: [Color]

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isToday {
                    Circle().fill(CozyTheme.primary).frame(width: 28, height: 28)
                } else if isSelected {
                    Circle().fill(CozyTheme.accent.opacity(0.2)).frame(width: 28, height: 28)
                }
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday || isSelected ? .bold : .regular))
                    .foregroundColor(isToday ? .white : CozyTheme.primary)
            }
            HStack(spacing: 2) {
                ForEach(Array(dots.enumerated()), id: \.offset) { _, color in
                    Circle().fill(color).frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 50)
    }

    private var dayNumber: String {
        let fmt = DateFormatter(); fmt.dateFormat = "d"
        return fmt.string(from: date)
    }
}
