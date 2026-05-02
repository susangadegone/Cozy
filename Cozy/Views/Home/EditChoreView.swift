import SwiftUI

struct EditChoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let chore: Chore

    @State private var choreName: String
    @State private var selectedRoom: String
    @State private var selectedFrequency: String
    @State private var selectedDays: Set<String>

    private let frequencies = ["Daily", "2–3 times/week", "Weekly", "Every 2 weeks", "Monthly"]
    private let dayPills = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    // Map full day name → pill abbreviation
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
        _selectedFrequency = State(initialValue: "Weekly")
        let abbrev = Self.dayNameToAbbrev[chore.dayOfWeek] ?? String(chore.dayOfWeek.prefix(2)).uppercased()
        _selectedDays = State(initialValue: [abbrev])
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
                        daysSection
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

    // MARK: - Name
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chore name")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .textCase(.uppercase)
                .tracking(0.5)
            TextField("e.g. Vacuum living room", text: $choreName)
                .font(.system(size: 16))
                .foregroundColor(CozyTheme.primary)
                .padding(14)
                .background(CozyTheme.card)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Room
    private var roomSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Room")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .textCase(.uppercase)
                .tracking(0.5)
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
            VStack(spacing: 6) {
                Image(systemName: room.icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(isOn ? CozyTheme.accent : CozyTheme.primary)
                Text(room.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isOn ? CozyTheme.accent : Color(hex: "8B6B5A"))
            }
            .frame(maxWidth: .infinity).frame(height: 76)
            .background(isOn ? CozyTheme.accent.opacity(0.12) : Color(hex: room.color))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isOn ? CozyTheme.accent.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Frequency
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How often")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .textCase(.uppercase)
                .tracking(0.5)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(frequencies, id: \.self) { freq in
                    frequencyPill(freq)
                }
            }
        }
    }

    private func frequencyPill(_ freq: String) -> some View {
        let isOn = selectedFrequency == freq
        return Button { selectedFrequency = freq } label: {
            Text(freq)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isOn ? .white : CozyTheme.primary)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isOn ? CozyTheme.accent : Color(hex: "F0EBE5"))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Days
    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Which days")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
                .textCase(.uppercase)
                .tracking(0.5)
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
                .background(isOn ? CozyTheme.accent : Color(hex: "F0EBE5"))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save
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

    // MARK: - Logic
    private func save() {
        let trimmed = choreName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !selectedRoom.isEmpty else { return }

        var updated = chore
        updated.choreName = trimmed
        updated.roomId = selectedRoom

        let scheduled = nextDate(for: selectedDays.first)
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let dayFmt = DateFormatter(); dayFmt.dateFormat = "EEEE"
        updated.scheduledDate = fmt.string(from: scheduled)
        updated.dayOfWeek = dayFmt.string(from: scheduled)

        appState.updateChore(updated)
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
