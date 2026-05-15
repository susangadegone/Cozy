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

    @State private var selectedRoomIndex: Int = 0
    @State private var showToast = false
    @State private var toastMessage = ""

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
                                isAdded: isAdded(preset),
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
        guard let userId = appState.profile?.id else { return }
        let scheduledDate = findLeastLoadedDay()
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let dow = DateFormatter(); dow.dateFormat = "EEEE"
        let chore = Chore(
            id: UUID(), userId: userId,
            roomId: preset.roomId, choreName: preset.name,
            dayOfWeek: dow.string(from: scheduledDate),
            isDone: false,
            scheduledDate: fmt.string(from: scheduledDate),
            completedAt: nil
        )
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            appState.addChore(chore)
        }
        toastMessage = "\"\(preset.name)\" added"
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring()) { showToast = false }
        }
    }

    private func findLeastLoadedDay() -> Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        var best = cal.date(byAdding: .day, value: 1, to: today) ?? today
        var bestCount = Int.max
        for i in 1...7 {
            guard let d = cal.date(byAdding: .day, value: i, to: today) else { continue }
            let c = appState.chores.filter { $0.scheduledDate == fmt.string(from: d) }.count
            if c < bestCount { bestCount = c; best = d }
        }
        return best
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
