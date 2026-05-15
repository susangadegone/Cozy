import SwiftUI

// MARK: - Chore Preview Sheet (onboarding, read-only)
struct ChorePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let selectedRooms: [String]

    // Map onboarding display names → PresetChoreLibrary roomIds
    private let roomIdMap: [String: String] = [
        "Kitchen": "kitchen",
        "Bedroom": "bedroom",
        "Bathroom": "bathroom",
        "Living room": "living",
        "Outdoor/yard": "outdoor",
        "Home office": "laundry",
        "Other": "laundry"
    ]

    private var roomIds: [String] {
        let mapped = selectedRooms.compactMap { roomIdMap[$0] }
        return mapped.isEmpty ? [] : Array(Set(mapped))
    }

    private let allRooms: [RoomSection] = [
        RoomSection(id: "kitchen",  name: "Kitchen",     icon: "fork.knife", color: "FFF3DC"),
        RoomSection(id: "bedroom",  name: "Bedroom",     icon: "bed.double", color: "F0E8E0"),
        RoomSection(id: "bathroom", name: "Bathroom",    icon: "shower",     color: "E4EEF2"),
        RoomSection(id: "living",   name: "Living Room", icon: "sofa",       color: "FDF3E3"),
        RoomSection(id: "outdoor",  name: "Outdoor",     icon: "leaf",       color: "E5EDDF"),
        RoomSection(id: "laundry",  name: "Laundry",     icon: "washer",     color: "EDE6F5"),
    ]

    private var visibleRooms: [RoomSection] {
        allRooms.filter { roomIds.contains($0.id) }
    }

    @State private var selectedRoomIndex = 0

    private var currentRoom: RoomSection {
        visibleRooms.indices.contains(selectedRoomIndex) ? visibleRooms[selectedRoomIndex] : (visibleRooms.first ?? allRooms[0])
    }

    private var currentPresets: [PresetChore] {
        PresetChoreLibrary.all(for: currentRoom.id)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    if visibleRooms.count > 1 { previewTabStrip }
                    previewList
                }
            }
            .navigationTitle("Chore ideas")
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

    private var previewTabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(visibleRooms.enumerated()), id: \.element.id) { idx, room in
                    let isSelected = selectedRoomIndex == idx
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedRoomIndex = idx
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: room.icon).font(.system(size: 13, weight: .medium))
                            Text(room.name).font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        }
                        .foregroundColor(isSelected ? .white : CozyTheme.primary)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(isSelected ? CozyTheme.accent : Color(hex: room.color))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(CozyTheme.card)
        .overlay(alignment: .bottom) { Divider() }
    }

    private var previewList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                roomHeaderCard.padding(.horizontal, 16).padding(.vertical, 16)
                LazyVStack(spacing: 0) {
                    ForEach(currentPresets) { preset in
                        previewRow(preset)
                    }
                }
                .background(CozyTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(CozyTheme.border, lineWidth: 1))
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
    }

    private var roomHeaderCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: currentRoom.color)).frame(width: 44, height: 44)
                Image(systemName: currentRoom.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(CozyTheme.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(currentRoom.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                let c = currentPresets.count
                Text("\(c) idea\(c == 1 ? "" : "s") — you'll be able to add these after setup")
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
        }
    }

    private func previewRow(_ preset: PresetChore) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(CozyTheme.primary)
                    Text(preset.defaultSchedule.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                }
                Spacer()
                Image(systemName: preset.isDefaultAdded ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundColor(preset.isDefaultAdded ? CozyTheme.accent : CozyTheme.border)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            Divider().padding(.leading, 16)
        }
    }
}

// MARK: - RoomTile
private struct RoomTile: Identifiable {
    let id: String
    let label: String
    let icon: String
}

struct OnboardingQ4View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selected: Set<String> = []
    @State private var appeared = false
    @State private var showChorePreview = false

    private let rooms: [RoomTile] = [
        RoomTile(id: "Kitchen",      label: "Kitchen",     icon: "fork.knife"),
        RoomTile(id: "Bedroom",      label: "Bedroom",     icon: "bed.double"),
        RoomTile(id: "Bathroom",     label: "Bathroom",    icon: "shower"),
        RoomTile(id: "Living room",  label: "Living room", icon: "sofa"),
        RoomTile(id: "Outdoor/yard", label: "Outdoor",     icon: "leaf"),
        RoomTile(id: "Home office",  label: "Office",      icon: "desktopcomputer"),
        RoomTile(id: "Other",        label: "Other",       icon: "plus.circle")
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        OnboardingShell(step: 4, total: 6, onBack: { appRouter.navigate(to: .onboardingQ3) }) {
            questionHeader
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            roomGrid
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            hint
                .padding(.top, 10)
            if !selected.isEmpty {
                chorePreviewButton
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            Spacer()
            OnboardingNextButton(isEnabled: !selected.isEmpty) {
                onboardingVM.selectedRooms = Array(selected)
                appRouter.navigate(to: .onboardingQ5)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
        .sheet(isPresented: $showChorePreview) {
            ChorePreviewSheet(selectedRooms: Array(selected))
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🛋️")
                .font(.system(size: 36))
            Text("Which rooms do you\nwant to keep on top of?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
        }
    }

    private var roomGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(rooms) { room in
                roomTile(room)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.18)) { toggle(room.id) }
                    }
            }
        }
    }

    private func roomTile(_ room: RoomTile) -> some View {
        let on = selected.contains(room.id)
        return ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Image(systemName: room.icon)
                    .font(.system(size: 26))
                    .foregroundColor(on ? .white : CozyTheme.accent)
                Text(room.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(on ? .white : CozyTheme.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 86)
            .background(on ? CozyTheme.accent : CozyTheme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(on ? CozyTheme.accent : CozyTheme.border, lineWidth: on ? 2 : 1)
            )
            if on {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .padding(5)
            }
        }
    }

    private var hint: some View {
        Text("Select all that apply — you can add more later")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
    }

    private var chorePreviewButton: some View {
        Button {
            showChorePreview = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 13))
                Text("See chore ideas for these rooms")
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(CozyTheme.accent)
        }
    }

    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
}
