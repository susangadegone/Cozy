import SwiftUI

struct ChoreDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let chore: Chore

    @State private var showDeleteConfirm = false
    @State private var showReschedule = false
    @State private var rescheduleDate = Date()
    @State private var showEdit = false

    private var room: Room? { Room.defaults.first { $0.id == chore.roomId } }

    private var history: [Chore] {
        appState.chores.filter { $0.choreName == chore.choreName && $0.roomId == chore.roomId && $0.isDone }
            .sorted { ($0.completedAt ?? "") > ($1.completedAt ?? "") }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAF7F2").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        choreHeader
                        Divider().opacity(0.2).padding(.horizontal, 20)
                        thisWeekSection
                        Divider().opacity(0.2).padding(.horizontal, 20)
                        historySection
                        actionsSection
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                        .font(.system(size: 15))
                }
            }
        }
        .confirmationDialog("Delete \(chore.choreName)?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete chore", role: .destructive) {
                appState.deleteChore(chore)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .sheet(isPresented: $showReschedule) {
            rescheduleSheet
        }
        .sheet(isPresented: $showEdit) {
            EditChoreView(chore: chore)
                .environmentObject(appState)
        }
    }

    // MARK: - Header
    private var choreHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let room = room {
                HStack(spacing: 6) {
                    Image(systemName: room.icon)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(CozyTheme.mutedText)
                    Text(room.name)
                        .font(.system(size: 13))
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
            Text(chore.choreName)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)

            HStack(spacing: 8) {
                StatusPill(isDone: chore.isDone)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    // MARK: - This Week
    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .textCase(.uppercase)
                .tracking(0.5)

            DetailRow(label: "Assigned", value: chore.dayOfWeek)
            DetailRow(label: "Date", value: formattedScheduledDate)
            DetailRow(label: "Status", value: chore.isDone ? "Completed" : "Pending")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    // MARK: - History
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your history")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .textCase(.uppercase)
                .tracking(0.5)

            if history.isEmpty {
                Text("Not done yet.")
                    .font(.system(size: 14))
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(history.prefix(10).enumerated()), id: \.element.id) { idx, entry in
                        HistoryEntryRow(chore: entry, userName: appState.profile?.displayName ?? "You")
                        if idx < min(9, history.count - 1) {
                            Divider().opacity(0.25).padding(.leading, 0)
                        }
                    }
                }
                .background(Color(hex: "FBF5ED"))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    // MARK: - Actions
    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button { showEdit = true } label: {
                Text("Edit chore")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(CozyTheme.card)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button { showReschedule = true } label: {
                Text("Reschedule")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(CozyTheme.card)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button { showDeleteConfirm = true } label: {
                Text("Delete chore")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "C0392B").opacity(0.85))
                    .frame(maxWidth: .infinity).frame(height: 44)
                    .background(Color(hex: "C0392B").opacity(0.06))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    // MARK: - Reschedule Sheet
    private var rescheduleSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Move this chore")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                    .padding(.top, 12)
                DatePicker("Select date", selection: $rescheduleDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(CozyTheme.accent)
                    .padding(.horizontal, 16)
                Button {
                    appState.rescheduleChore(chore, to: rescheduleDate)
                    showReschedule = false
                } label: {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(CozyTheme.accent)
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .background(Color(hex: "FAF7F2").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showReschedule = false }
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
        }
    }

    private var formattedScheduledDate: String {
        guard let d = DateFormatters.yearMonthDay.date(from: chore.scheduledDate) else { 
            return chore.scheduledDate 
        }
        return DateFormatters.monthDayYear.string(from: d)
    }
}

// MARK: - Supporting Views

private struct StatusPill: View {
    let isDone: Bool
    var body: some View {
        Text(isDone ? "Done" : "Pending")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(isDone ? Color(hex: "3A7D5E") : CozyTheme.accent)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(isDone ? Color(hex: "3A7D5E").opacity(0.1) : CozyTheme.accent.opacity(0.1))
            .cornerRadius(20)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(CozyTheme.primary)
        }
        .padding(.vertical, 2)
    }
}

private struct HistoryEntryRow: View {
    let chore: Chore
    let userName: String

    private var formattedDate: String {
        let date: Date?
        if let ct = chore.completedAt { 
            date = DateFormatters.iso8601.date(from: ct) ?? DateFormatters.yearMonthDay.date(from: ct)
        } else { 
            date = DateFormatters.yearMonthDay.date(from: chore.scheduledDate) 
        }
        guard let d = date else { return chore.scheduledDate }
        return DateFormatters.monthDay.string(from: d)
    }

    private var formattedTime: String {
        guard let ct = chore.completedAt else { return "" }
        guard let d = DateFormatters.iso8601.date(from: ct) else { return "" }
        return DateFormatters.timeOnly.string(from: d)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(formattedDate)
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.primary)
                .frame(width: 56, alignment: .leading)
            Text(userName)
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
            if !formattedTime.isEmpty {
                Text(formattedTime)
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
