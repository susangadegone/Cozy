import SwiftUI

// MARK: - Calendar Mode
enum CalendarMode { case week, month }

// MARK: - Main Calendar View
struct CalendarView: View {
    @EnvironmentObject var appState: AppState

    @State private var mode: CalendarMode = .week
    @State private var weekOffset: Int = 0
    @State private var displayMonth: Date = Date()
    @State private var showAddChore = false
    @State private var selectedChore: Chore? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    calHeader
                    Divider().background(CozyTheme.border).opacity(0.5)
                    Group {
                        if mode == .week {
                            WeekCalendarView(
                                weekOffset: $weekOffset,
                                selectedChore: $selectedChore
                            )
                        } else {
                            MonthCalendarView(
                                displayMonth: $displayMonth
                            )
                        }
                    }
                    .animation(.easeInOut(duration: 0.18), value: mode)
                }
                CalFAB { showAddChore = true }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView(initialDate: appState.selectedDate)
                .environmentObject(appState)
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedChore) { chore in
            NavigationStack {
                ChoreDetailView(chore: chore)
                    .environmentObject(appState)
            }
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header
    private var calHeader: some View {
        HStack(spacing: 12) {
            Text(headerTitle)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            CalModeToggle(mode: $mode)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var headerTitle: String {
        if mode == .week {
            let days = CalendarHelpers.weekDays(offset: weekOffset)
            guard let first = days.first, let last = days.last else { return "Calendar" }
            let m1 = DateFormatters.monthOnly.string(from: first)
            let m2 = DateFormatters.monthOnly.string(from: last)
            return m1 == m2 ? m1 : "\(m1) – \(m2)"
        } else {
            return DateFormatters.monthYear.string(from: displayMonth)
        }
    }
}

// MARK: - Mode Toggle
private struct CalModeToggle: View {
    @Binding var mode: CalendarMode
    var body: some View {
        HStack(spacing: 0) {
            toggleBtn("Week", selected: mode == .week) { mode = .week }
            toggleBtn("Month", selected: mode == .month) { mode = .month }
        }
        .background(CozyTheme.border.opacity(0.5))
        .cornerRadius(20)
    }

    @ViewBuilder
    private func toggleBtn(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: selected ? .semibold : .regular))
                .foregroundColor(selected ? .white : CozyTheme.mutedText)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? CozyTheme.accent : Color.clear)
                .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FAB
struct CalFAB: View {
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
