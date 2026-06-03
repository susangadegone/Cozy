import SwiftUI

// MARK: - BrowseChoresView
// Reusable chore-browse sheet.
// previewMode = true  → read-only, shown during onboarding (no add buttons)
// previewMode = false → interactive, user can add presets to their schedule
struct BrowseChoresView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var previewMode: Bool = false
    /// Filter to specific roomIds. Empty = show all rooms.
    var limitToRooms: [String] = []
    /// Set when opened from Add Chore. Tapping a preset returns it to the caller
    /// (name + default schedule) instead of immediately adding to the schedule.
    var onPick: ((PresetChore) -> Void)? = nil

    @State private var selectedRoomIndex: Int = 0
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var choreToSchedule: PresetChore?

    private var rooms: [RoomSection] {
        let base: [RoomSection] = [
            RoomSection(id: "kitchen",   name: "Kitchen",     icon: "fork.knife",    color: "FFF3DC"),
            RoomSection(id: "bedroom",   name: "Bedroom",     icon: "bed.double",    color: "F0E8E0"),
            RoomSection(id: "bathroom",  name: "Bathroom",    icon: "shower",        color: "E4EEF2"),
            RoomSection(id: "living",    name: "Living Room", icon: "sofa",          color: "FDF3E3"),
            RoomSection(id: "outdoor",   name: "Outdoor",     icon: "leaf",          color: "E5EDDF"),
            RoomSection(id: "laundry",   name: "Laundry",     icon: "washer",        color: "EDE6F5"),
        ]
        if limitToRooms.isEmpty { return base }
        return base.filter { limitToRooms.contains($0.id) }
    }

    private var currentRoom: RoomSection {
        rooms.indices.contains(selectedRoomIndex) ? rooms[selectedRoomIndex] : rooms[0]
    }

    private var currentPresets: [PresetChore] {
        PresetChoreLibrary.all(for: currentRoom.id)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    roomTabStrip
                    choreList
                }
                if showToast { toastBanner }
            }
            .navigationTitle(previewMode ? "Chore ideas" : "Chore library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.accent)
                        .fontWeight(.semibold)
                }
            }
            .sheet(item: $choreToSchedule) { preset in
                QuickScheduleSheet(preset: preset)
                    .environmentObject(appState)
            }
        }
    }

    // MARK: - Room Tab Strip
    private var roomTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(rooms.enumerated()), id: \.element.id) { idx, room in
                    roomTab(room: room, index: idx)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(CozyTheme.card)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private func roomTab(room: RoomSection, index: Int) -> some View {
        let isSelected = selectedRoomIndex == index
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedRoomIndex = index
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: room.icon)
                    .font(.system(size: 13, weight: .medium))
                Text(room.name)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : CozyTheme.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? CozyTheme.accent : Color(hex: room.color))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
            )
        }
    }

    // MARK: - Chore List
    private var choreList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                roomHeaderCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                if currentPresets.isEmpty {
                    emptyRoomState
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(currentPresets) { preset in
                            BrowseChoreRow(
                                preset: preset,
                                isAdded: onPick == nil ? isAdded(preset) : false,
                                isPreviewMode: previewMode,
                                onAdd: { addPreset(preset) }
                            )
                        }
                    }
                    .background(CozyTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(CozyTheme.border, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var roomHeaderCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: currentRoom.color))
                    .frame(width: 44, height: 44)
                Image(systemName: currentRoom.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(CozyTheme.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(currentRoom.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                let count = currentPresets.count
                Text("\(count) chore suggestion\(count == 1 ? "" : "s")")
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
        }
    }

    private var emptyRoomState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundColor(CozyTheme.mutedText.opacity(0.5))
            Text("No suggestions for this room yet.")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Toast
    private var toastBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "4CAF82"))
                .font(.system(size: 16))
            Text(toastMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(CozyTheme.primary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(CozyTheme.card)
        .cornerRadius(12)
        .shadow(color: CozyTheme.primary.opacity(0.12), radius: 10, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
        .padding(.bottom, 32)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Logic
    private func isAdded(_ preset: PresetChore) -> Bool {
        appState.chores.contains { $0.choreName == preset.name && $0.roomId == preset.roomId }
    }

    private func addPreset(_ preset: PresetChore) {
        if let pick = onPick {
            pick(preset)
            dismiss()
            return
        }
        choreToSchedule = preset
    }
}

// MARK: - BrowseChoreRow
struct BrowseChoreRow: View {
    let preset: PresetChore
    let isAdded: Bool
    let isPreviewMode: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isAdded ? CozyTheme.mutedText : CozyTheme.primary)
                    Text(preset.defaultSchedule.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                }
                Spacer()
                if !isPreviewMode {
                    addIndicator
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .opacity(isAdded ? 0.65 : 1.0)
            .contentShape(Rectangle())
            .onTapGesture { if !isPreviewMode && !isAdded { onAdd() } }

            Divider().padding(.leading, 16)
        }
    }

    @ViewBuilder
    private var addIndicator: some View {
        if isAdded {
            HStack(spacing: 4) {
                Text("Added")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "4CAF82"))
            }
        } else {
            Image(systemName: "plus.circle")
                .font(.system(size: 22))
                .foregroundColor(CozyTheme.accent)
        }
    }
}

// MARK: - RoomSection model (local)
struct RoomSection: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
}

// MARK: - QuickScheduleSheet
struct QuickScheduleSheet: View {
    let preset: PresetChore
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let frequencies = ["Daily", "2\u{2013}3 times/week", "Weekly", "Every 2 weeks", "Monthly"]
    private let dayPills = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    @State private var selectedFrequency = "Weekly"
    @State private var selectedDays: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(preset.name)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(CozyTheme.primary)
                        Text("When do you want to do this?")
                            .font(.system(size: 15))
                            .foregroundColor(CozyTheme.mutedText)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("How often?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(CozyTheme.primary)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(frequencies, id: \.self) { freq in
                                frequencyPill(freq)
                            }
                        }
                    }

                    if selectedFrequency != "Daily" && selectedFrequency != "Monthly" {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(selectedFrequency == "2\u{2013}3 times/week" ? "Which days? (pick 2–3)" : "Which day?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(CozyTheme.primary)
                            HStack(spacing: 6) {
                                ForEach(dayPills, id: \.self) { day in
                                    dayPill(day)
                                }
                            }
                        }
                    }

                    Spacer()

                    Button(action: save) {
                        let n = generatedDates.count
                        Text(n <= 1 ? "Add to my schedule" : "Add \(n) to my schedule")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(CozyTheme.accent)
                            .cornerRadius(CozyTheme.cornerRadius)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Schedule it")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
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
    }

    private var generatedDates: [Date] {
        let anchor = Calendar.current.startOfDay(for: Date())
        let cal = Calendar.current
        switch selectedFrequency {
        case "Daily":
            return (0..<28).compactMap { cal.date(byAdding: .day, value: $0, to: anchor) }
        case "2\u{2013}3 times/week":
            let days = selectedDays.isEmpty ? ["MO", "WE"] : Array(selectedDays)
            return days.flatMap { day -> [Date] in
                let first = nextDate(for: day, from: anchor)
                return (0..<4).compactMap { cal.date(byAdding: .weekOfYear, value: $0, to: first) }
            }.sorted()
        case "Every 2 weeks":
            let first = nextDate(for: selectedDays.first, from: anchor)
            return (0..<4).compactMap { cal.date(byAdding: .weekOfYear, value: $0 * 2, to: first) }
        case "Monthly":
            return (0..<3).compactMap { cal.date(byAdding: .month, value: $0, to: anchor) }
        default:
            let first = nextDate(for: selectedDays.first, from: anchor)
            return (0..<8).compactMap { cal.date(byAdding: .weekOfYear, value: $0, to: first) }
        }
    }

    private func nextDate(for dayAbbrev: String?, from anchor: Date) -> Date {
        guard let abbrev = dayAbbrev else { return anchor }
        let map = ["SU": 1, "MO": 2, "TU": 3, "WE": 4, "TH": 5, "FR": 6, "SA": 7]
        guard let target = map[abbrev] else { return anchor }
        let cal = Calendar.current
        var check = anchor
        for _ in 0..<8 {
            if cal.component(.weekday, from: check) == target { return check }
            check = cal.date(byAdding: .day, value: 1, to: check) ?? check
        }
        return anchor
    }

    private func save() {
        guard let userId = appState.profile?.id else { return }
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let dow = DateFormatter(); dow.dateFormat = "EEEE"
        let chores = generatedDates.map { date in
            Chore(
                id: UUID(), userId: userId,
                roomId: preset.roomId, choreName: preset.name,
                dayOfWeek: dow.string(from: date),
                isDone: false,
                scheduledDate: fmt.string(from: date),
                completedAt: nil
            )
        }
        appState.addChores(chores)
        dismiss()
    }
}
