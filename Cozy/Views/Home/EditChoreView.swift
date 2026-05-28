import SwiftUI

struct EditChoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let chore: Chore

    @State private var choreName: String
    @State private var selectedRoom: String
    @State private var selectedFrequency: String
    @State private var selectedDays: Set<String>
    @State private var preferredTime: Date

    private let frequencies = ["Daily", "2–3 times/week", "Weekly", "Every 2 weeks", "Monthly"]
    private let dayPills = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    private static let dayNameToAbbrev: [String: String] = [
        "Sunday": "SU", "Monday": "MO", "Tuesday": "TU",
        "Wednesday": "WE", "Thursday": "TH", "Friday": "FR", "Saturday": "SA"
    ]
    private static let abbrevToDayName: [String: String] = [
        "SU": "Sunday", "MO": "Monday", "TU": "Tuesday",
        "WE": "Wednesday", "TH": "Thursday", "FR": "Friday", "SA": "Saturday"
    ]

    init(chore: Chore) {
        self.chore = chore
        _choreName = State(initialValue: chore.choreName)
        _selectedRoom = State(initialValue: chore.roomId)
        _selectedFrequency = State(initialValue: chore.frequency ?? "Weekly")
        let abbrev = Self.dayNameToAbbrev[chore.dayOfWeek] ?? String(chore.dayOfWeek.prefix(2)).uppercased()
        _selectedDays = State(initialValue: [abbrev])

        // Default preferred time: stored value, or 9:00 AM
        let cal = Calendar.current
        let baseDate: Date = {
            var c = DateComponents(); c.hour = 9; c.minute = 0
            return cal.date(from: c) ?? Date()
        }()
        if let mins = chore.preferredTimeMinutes {
            var c = DateComponents(); c.hour = mins / 60; c.minute = mins % 60
            _preferredTime = State(initialValue: cal.date(from: c) ?? baseDate)
        } else {
            _preferredTime = State(initialValue: baseDate)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        nameField
                        roomSection
                        frequencySection
                        if selectedFrequency == "Daily" {
                            timeSection
                        } else {
                            daysSection
                        }
                        saveButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(CozyTheme.primary)
                        .font(.system(size: 15))
                }
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Chore name")
            TextField("e.g. Vacuum living room", text: $choreName)
                .font(.system(size: 16))
                .foregroundColor(CozyTheme.primary)
                .padding(14)
                .background(CozyTheme.card)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
        }
    }

    private var roomSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Room")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Room.defaults) { room in
                    roomCard(room)
                }
            }
        }
    }

    private func roomCard(_ room: Room) -> some View {
        let isOn = selectedRoom == room.id
        return Button { selectedRoom = room.id } label: {
            Text(room.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isOn ? .white : CozyTheme.primary)
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(isOn ? CozyTheme.accent : CozyTheme.card)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("How often")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(frequencies, id: \.self) { freq in
                    frequencyPill(freq)
                }
            }
        }
    }

    private func frequencyPill(_ freq: String) -> some View {
        let isOn = selectedFrequency == freq
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) { selectedFrequency = freq }
        } label: {
            Text(freq)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isOn ? .white : CozyTheme.primary)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isOn ? CozyTheme.accent : CozyTheme.card)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Time of day")
            HStack {
                Text("Do it at")
                    .font(.system(size: 14))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                DatePicker("", selection: $preferredTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .tint(CozyTheme.accent)
            }
            .padding(14)
            .background(CozyTheme.card)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
        }
    }

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Which days")
            HStack(spacing: 6) {
                ForEach(dayPills, id: \.self) { day in
                    dayPill(day)
                }
            }
        }
    }

    private func dayPill(_ day: String) -> some View {
        let isOn = selectedDays.contains(day)
        return Button {
            if isOn { selectedDays.remove(day) } else { selectedDays.insert(day) }
        } label: {
            Text(day)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isOn ? .white : CozyTheme.primary)
                .frame(maxWidth: .infinity).frame(height: 36)
                .background(isOn ? CozyTheme.accent : CozyTheme.card)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(CozyTheme.mutedText)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private var saveButton: some View {
        let trimmed = choreName.trimmingCharacters(in: .whitespaces)
        let enabled = !trimmed.isEmpty && !selectedRoom.isEmpty
        return Button { save() } label: {
            Text("Save")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(enabled ? CozyTheme.accent : CozyTheme.border)
                .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .padding(.top, 8)
    }

    private func save() {
        let trimmed = choreName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !selectedRoom.isEmpty else { return }

        var updated = chore
        updated.choreName = trimmed
        updated.roomId = selectedRoom
        updated.frequency = selectedFrequency

        if selectedFrequency == "Daily" {
            let cal = Calendar.current
            let comps = cal.dateComponents([.hour, .minute], from: preferredTime)
            let timeMinutes = (comps.hour ?? 9) * 60 + (comps.minute ?? 0)
            updated.preferredTimeMinutes = timeMinutes

            let today = Date()
            updated.scheduledDate = DateFormatters.yearMonthDay.string(from: today)
            updated.dayOfWeek = DateFormatters.dayOfWeek.string(from: today)
            appState.updateChore(updated)

            // Generate next 29 days as a single batch to avoid 29 separate disk writes.
            let existingDates = Set(appState.chores
                .filter { $0.choreName == trimmed && $0.roomId == selectedRoom }
                .map { $0.scheduledDate })
            let newInstances: [Chore] = (1...29).compactMap { offset in
                guard let date = cal.date(byAdding: .day, value: offset, to: today) else { return nil }
                let ds = DateFormatters.yearMonthDay.string(from: date)
                guard !existingDates.contains(ds) else { return nil }
                return Chore(
                    userId: chore.userId,
                    roomId: selectedRoom,
                    choreName: trimmed,
                    dayOfWeek: DateFormatters.dayOfWeek.string(from: date),
                    isDone: false,
                    scheduledDate: ds,
                    frequency: "Daily",
                    preferredTimeMinutes: timeMinutes
                )
            }
            if !newInstances.isEmpty { appState.addChores(newInstances) }
        } else {
            updated.preferredTimeMinutes = nil
            let scheduled = nextDate(for: selectedDays.first)
            updated.scheduledDate = DateFormatters.yearMonthDay.string(from: scheduled)
            updated.dayOfWeek = DateFormatters.dayOfWeek.string(from: scheduled)
            appState.updateChore(updated)
        }

        dismiss()
    }

    private func nextDate(for dayAbbrev: String?) -> Date {
        let map = ["SU": 1, "MO": 2, "TU": 3, "WE": 4, "TH": 5, "FR": 6, "SA": 7]
        guard let abbrev = dayAbbrev, let target = map[abbrev] else { return Date() }
        let cal = Calendar.current
        var check = cal.startOfDay(for: Date())
        for _ in 0..<8 {
            if cal.component(.weekday, from: check) == target { return check }
            check = cal.date(byAdding: .day, value: 1, to: check) ?? check
        }
        return Date()
    }
}
