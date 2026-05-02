import SwiftUI

// MARK: - Chore Library View
struct ChoreLibraryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false
    @State private var toastMessage = ""

    private var userRooms: [Room] {
        guard let profile = appState.profile else { return [] }
        return Room.defaults.filter { profile.rooms.contains($0.id) }
    }

    private var groupedPresets: [RoomPresetSection] {
        userRooms.compactMap { room in
            let presets = PresetChoreLibrary.all(for: room.id)
            guard !presets.isEmpty else { return nil }
            return RoomPresetSection(room: room, presets: presets)
        }
    }

    private var allAdded: Bool {
        groupedPresets.allSatisfy { section in
            section.presets.allSatisfy { preset in
                isAdded(preset)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CozyTheme.background.ignoresSafeArea()
                
                if allAdded {
                    emptyState
                } else {
                    libraryContent
                }
                
                if showToast {
                    toastView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Chore library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.accent)
                }
            }
        }
    }

    // MARK: - Library Content
    private var libraryContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                subtextHeader
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(groupedPresets, id: \.room.id) { section in
                        Section {
                            ForEach(section.presets) { preset in
                                PresetChoreRow(
                                    preset: preset,
                                    isAdded: isAdded(preset),
                                    onAdd: { addPreset(preset) }
                                )
                            }
                        } header: {
                            LibraryRoomHeader(room: section.room)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var subtextHeader: some View {
        Text("Tap to add to your rooms.")
            .font(.system(size: 14))
            .foregroundColor(CozyTheme.mutedText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("You've added everything from the library.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
                .multilineTextAlignment(.center)
            Text("Add custom chores from the chores screen.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Toast
    private var toastView: some View {
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
        .shadow(color: CozyTheme.primary.opacity(0.1), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(CozyTheme.border, lineWidth: 1)
        )
        .padding(.bottom, 32)
        .padding(.horizontal, 20)
    }

    // MARK: - Logic
    private func isAdded(_ preset: PresetChore) -> Bool {
        appState.chores.contains { chore in
            chore.choreName == preset.name && chore.roomId == preset.roomId
        }
    }

    private func addPreset(_ preset: PresetChore) {
        guard let userId = appState.profile?.id else { return }
        
        // Find the least loaded day in the next 7 days
        let scheduledDate = findLeastLoadedDay()
        
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let dowFmt = DateFormatter()
        dowFmt.dateFormat = "EEEE"
        
        let newChore = Chore(
            id: UUID(),
            userId: userId,
            roomId: preset.roomId,
            choreName: preset.name,
            dayOfWeek: dowFmt.string(from: scheduledDate),
            isDone: false,
            scheduledDate: fmt.string(from: scheduledDate),
            completedAt: nil
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            appState.addChore(newChore)
        }
        
        // Show toast
        let roomName = Room.defaults.first { $0.id == preset.roomId }?.name ?? "your home"
        toastMessage = "Added to \(roomName)"
        withAnimation(.spring()) {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring()) {
                showToast = false
            }
        }
    }

    /// Find the day in the next 7 days with the fewest scheduled chores
    private func findLeastLoadedDay() -> Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        
        // Count chores per day for next 7 days
        var dayCounts: [(date: Date, count: Int)] = []
        for i in 1...7 {
            guard let date = cal.date(byAdding: .day, value: i, to: today) else { continue }
            let dateStr = fmt.string(from: date)
            let count = appState.chores.filter { $0.scheduledDate == dateStr }.count
            dayCounts.append((date, count))
        }
        
        // Find minimum
        if let min = dayCounts.min(by: { $0.count < $1.count }) {
            return min.date
        }
        
        // Fallback: tomorrow
        return cal.date(byAdding: .day, value: 1, to: today) ?? today
    }
}

// MARK: - Room Preset Section
private struct RoomPresetSection {
    let room: Room
    let presets: [PresetChore]
}

// MARK: - Library Room Header
private struct LibraryRoomHeader: View {
    let room: Room
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: room.icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.accent)
            Text(room.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(CozyTheme.background)
    }
}

// MARK: - Preset Chore Row
private struct PresetChoreRow: View {
    let preset: PresetChore
    let isAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: { if !isAdded { onAdd() } }) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isAdded ? CozyTheme.mutedText : CozyTheme.primary)
                    
                    Text("Weekly")
                        .font(.system(size: 13))
                        .foregroundColor(CozyTheme.mutedText)
                }
                
                Spacer()
                
                if isAdded {
                    HStack(spacing: 6) {
                        Text("Added")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(CozyTheme.mutedText)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "4CAF82"))
                    }
                } else {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundColor(CozyTheme.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .background(CozyTheme.background)
            .opacity(isAdded ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isAdded)
        
        Divider()
            .padding(.leading, 20)
            .background(CozyTheme.border.opacity(0.4))
    }
}
