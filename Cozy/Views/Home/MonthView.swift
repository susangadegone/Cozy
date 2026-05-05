import SwiftUI

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var displayMonth: Date
    @Binding var selectedChore: Chore?

    @State private var selectedDay: Date? = nil
    @State private var showDaySheet = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let dayHeaders = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    var body: some View {
        VStack(spacing: 0) {
            monthNavBar
            Divider().background(CozyTheme.border).opacity(0.4)
            dayHeaderRow
            Divider().background(CozyTheme.border).opacity(0.4)
            ScrollView(showsIndicators: false) {
                monthGrid
                    .padding(.bottom, 80)
            }
        }
        .sheet(isPresented: $showDaySheet) {
            if let day = selectedDay {
                DayChoresSheet(date: day, selectedChore: $selectedChore)
                    .environmentObject(appState)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Nav Bar
    private var monthNavBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    displayMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayMonth) ?? displayMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Button {
                withAnimation { displayMonth = Date() }
            } label: {
                Text("Today")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    displayMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
                }
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

    // MARK: - Day Header Row
    private var dayHeaderRow: some View {
        HStack(spacing: 0) {
            ForEach(dayHeaders, id: \.self) { d in
                Text(d)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Month Grid
    private var monthGrid: some View {
        let grid = CalendarHelpers.monthGrid(for: displayMonth)
        let allChores = appState.chores
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(grid.enumerated()), id: \.offset) { _, date in
                if let date {
                    MonthDayCell(
                        date: date,
                        chores: allChores.filter { $0.scheduledDate == CalendarHelpers.dateString(date) }
                    ) {
                        selectedDay = date
                        showDaySheet = true
                    }
                } else {
                    Color.clear.frame(height: 60)
                }
            }
        }
    }
}

// MARK: - Month Day Cell
private struct MonthDayCell: View {
    let date: Date
    let chores: [Chore]
    let onTap: () -> Void

    private var isToday: Bool { CalendarHelpers.isToday(date) }
    private var dayNum: Int { Calendar.current.component(.day, from: date) }
    private var roomDots: [String] {
        let roomIds = Array(Set(chores.map(\.roomId))).sorted()
        return Array(roomIds.prefix(3))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(dayNum)")
                    .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                    .foregroundColor(isToday ? .white : CozyTheme.primary)
                    .frame(width: 28, height: 28)
                    .background(isToday ? Color(hex: "D4A574") : Color.clear)
                    .cornerRadius(14)

                HStack(spacing: 3) {
                    if roomDots.isEmpty {
                        Color.clear.frame(height: 6)
                    } else {
                        ForEach(roomDots, id: \.self) { roomId in
                            Circle()
                                .fill(CalendarHelpers.roomBorderColor(for: roomId))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(height: 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(chores.isEmpty ? Color.clear : Color(hex: "D4A574").opacity(0.04))
            .overlay(
                Rectangle()
                    .stroke(CozyTheme.border.opacity(0.4), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Day Chores Sheet
struct DayChoresSheet: View {
    @EnvironmentObject var appState: AppState
    let date: Date
    @Binding var selectedChore: Chore?
    @Environment(\.dismiss) private var dismiss

    private var dateLabel: String {
        DateFormatters.fullDate.string(from: date)
    }

    private var chores: [Chore] {
        let ds = CalendarHelpers.dateString(date)
        return appState.chores.filter { $0.scheduledDate == ds }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    Text(dateLabel)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(CozyTheme.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                    if chores.isEmpty {
                        Spacer()
                        Text("Nothing scheduled")
                            .font(.system(size: 15))
                            .foregroundColor(CozyTheme.mutedText)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(Array(chores.enumerated()), id: \.element.id) { idx, chore in
                                    DaySheetChoreRow(chore: chore)
                                        .onTapGesture {
                                            dismiss()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                selectedChore = chore
                                            }
                                        }
                                    if idx < chores.count - 1 {
                                        Divider()
                                            .padding(.leading, 20)
                                            .opacity(0.4)
                                    }
                                }
                            }
                            .background(CozyTheme.card)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
                            .padding(.horizontal, 20)
                        }
                    }
                    Spacer(minLength: 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                        .font(.system(size: 15))
                }
            }
        }
    }
}

private struct DaySheetChoreRow: View {
    let chore: Chore
    private var room: Room? { Room.defaults.first { $0.id == chore.roomId } }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(CalendarHelpers.roomBorderColor(for: chore.roomId))
                .frame(width: 3, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(chore.choreName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                Text(room?.name ?? chore.roomId.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            if chore.isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "5C9B8D"))
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
