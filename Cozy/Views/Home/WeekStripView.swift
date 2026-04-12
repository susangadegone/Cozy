import SwiftUI

struct WeekStripView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    @Binding var weekOffset: Int

    private let colWidth: CGFloat = UIScreen.main.bounds.width / 7

    var body: some View {
        VStack(spacing: 0) {
            weekNavHeader
            ZStack {
                HStack(spacing: 0) {
                    ForEach(Array(weekDates.enumerated()), id: \.offset) { idx, date in
                        DayColumnView(
                            date: date,
                            index: idx,
                            colWidth: colWidth,
                            chores: chores(for: date),
                            isSelected: isSameDay(date, appState.selectedDate),
                            isDragTarget: dragManager.isDragging && dragManager.targetDayIndex == idx,
                            isDragging: dragManager.isDragging
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                appState.selectedDate = date
                            }
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: DayFramePreferenceKey.self,
                                    value: [idx: geo.frame(in: .global)]
                                )
                            }
                        )
                    }
                }
                .onPreferenceChange(DayFramePreferenceKey.self) { frames in
                    DispatchQueue.main.async {
                        dragManager.dayFrames = frames
                        dragManager.weekDates = weekDates
                    }
                }
            }
        }
        .background(CozyTheme.card)
        .onChange(of: weekOffset) {
            dragManager.weekDates = weekDates
        }
    }

    private var weekNavHeader: some View {
        HStack {
            Button { weekOffset -= 1 } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(.leading, 14)
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
                    .padding(.trailing, 14)
            }
        }
        .padding(.vertical, 8)
    }

    var weekDates: [Date] {
        let cal = Calendar.current
        let today = Date()
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let offsetStart = cal.date(byAdding: .weekOfYear, value: weekOffset, to: weekStart) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: offsetStart) }
    }

    private func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }

    private func chores(for date: Date) -> [Chore] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: date)
        return appState.chores.filter { $0.scheduledDate == key }
    }

    private var weekRangeLabel: String {
        let dates = weekDates
        guard let first = dates.first, let last = dates.last else { return "" }
        let fmt = DateFormatter(); fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: first)) – \(fmt.string(from: last))"
    }
}

// MARK: - Day Column
struct DayColumnView: View {
    let date: Date
    let index: Int
    let colWidth: CGFloat
    let chores: [Chore]
    let isSelected: Bool
    let isDragTarget: Bool
    let isDragging: Bool

    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayLabel)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? CozyTheme.primary : CozyTheme.mutedText)
                .textCase(.uppercase)
            dateCircle
            choreChipsStack
            Spacer(minLength: 0)
        }
        .frame(width: colWidth, height: 130)
        .background(columnBackground)
        .overlay(dragTargetOverlay)
    }

    private var dateCircle: some View {
        ZStack {
            if isToday {
                Circle()
                    .fill(CozyTheme.primary)
                    .frame(width: 28, height: 28)
                Text(dayNumber)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            } else {
                Text(dayNumber)
                    .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? CozyTheme.primary : CozyTheme.primary.opacity(0.8))
            }
        }
        .frame(width: 28, height: 28)
    }

    @ViewBuilder
    private var choreChipsStack: some View {
        let visible = Array(chores.prefix(3))
        let overflow = chores.count - visible.count
        VStack(spacing: 2) {
            ForEach(visible) { chore in
                choreChip(chore)
            }
            if overflow > 0 {
                Text("+\(overflow)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
        .padding(.top, 2)
    }

    private func choreChip(_ chore: Chore) -> some View {
        let room = Room.defaults.first { $0.id == chore.roomId }
        let bg = room.map { Color(hex: $0.color) } ?? CozyTheme.card
        return Text(chore.choreName)
            .font(.system(size: 7, weight: .medium))
            .foregroundColor(CozyTheme.primary)
            .lineLimit(1)
            .padding(.horizontal, 4).padding(.vertical, 2)
            .frame(maxWidth: colWidth - 6)
            .background(bg)
            .cornerRadius(3)
    }

    @ViewBuilder
    private var columnBackground: some View {
        if isSelected {
            Color(hex: "FFF0D6")
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var dragTargetOverlay: some View {
        if isDragging {
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(
                    isDragTarget ? CozyTheme.accent : CozyTheme.border.opacity(0.4),
                    style: StrokeStyle(lineWidth: isDragTarget ? 2 : 1, dash: isDragTarget ? [] : [4])
                )
                .background(isDragTarget ? CozyTheme.accent.opacity(0.08) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isDragTarget)
        }
    }

    private var dayLabel: String {
        let fmt = DateFormatter(); fmt.dateFormat = "EEE"
        return fmt.string(from: date)
    }

    private var dayNumber: String {
        let fmt = DateFormatter(); fmt.dateFormat = "d"
        return fmt.string(from: date)
    }
}
