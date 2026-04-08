import SwiftUI

struct WeekStripView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(weekDates, id: \.self) { date in
                        DayCell(date: date, isSelected: isSameDay(date, appState.selectedDate), choreCount: choreCount(for: date))
                            .id(date)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    appState.selectedDate = date
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                proxy.scrollTo(appState.selectedDate, anchor: .center)
            }
        }
    }

    private var weekDates: [Date] {
        let cal = Calendar.current
        let today = Date()
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }

    private func choreCount(for date: Date) -> Int {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: date)
        return appState.chores.filter { $0.scheduledDate == key }.count
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let choreCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(dayLetter)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? .white : CozyTheme.mutedText)
            Text(dayNumber)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : CozyTheme.primary)
            if choreCount > 0 {
                choreIndicator
            } else {
                Circle().fill(.clear).frame(width: 6, height: 6)
            }
        }
        .frame(width: 48, height: 76)
        .background(isSelected ? CozyTheme.primary : CozyTheme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.clear : CozyTheme.border, lineWidth: 1)
        )
    }

    private var choreIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<min(choreCount, 3), id: \.self) { _ in
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.7) : CozyTheme.accent)
                    .frame(width: 5, height: 5)
            }
        }
    }

    private var dayLetter: String {
        let fmt = DateFormatter(); fmt.dateFormat = "EEE"
        return fmt.string(from: date).uppercased()
    }

    private var dayNumber: String {
        let fmt = DateFormatter(); fmt.dateFormat = "d"
        return fmt.string(from: date)
    }
}
