import SwiftUI

struct OnboardingStep4: View {
    @Binding var selectedRooms: Set<String>
    @State private var customRoomName = ""
    @State private var customRooms: [Room] = []

    var allRooms: [Room] { Room.defaults + customRooms }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            roomsGrid
            if selectedRooms.count < 8 { addCustomSection }
            Spacer()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🗺️")
                .font(.system(size: 64))
                .padding(.top, 8)
            Text("Your Rooms")
                .font(.custom("Fraunces-Regular", size: 28))
                .foregroundColor(CozyTheme.primary)
            Text("Select the spaces you'd like to track.\nYou can add custom rooms too.")
                .font(.custom("DMSans-Regular", size: 16))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.bottom, 28)
    }

    private var roomsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(allRooms) { room in
                RoomToggleCard(room: room, isSelected: selectedRooms.contains(room.id)) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        if selectedRooms.contains(room.id) {
                            selectedRooms.remove(room.id)
                        } else {
                            selectedRooms.insert(room.id)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    private var addCustomSection: some View {
        HStack(spacing: 10) {
            TextField("Add custom room…", text: $customRoomName)
                .font(.custom("DMSans-Regular", size: 15))
                .foregroundColor(CozyTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(CozyTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                        .stroke(CozyTheme.border, lineWidth: 1)
                )
                .cornerRadius(CozyTheme.cornerRadius)
                .autocorrectionDisabled()

            Button(action: addCustomRoom) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(customRoomName.trimmingCharacters(in: .whitespaces).isEmpty ? CozyTheme.border : CozyTheme.accent)
                    .cornerRadius(14)
            }
            .disabled(customRoomName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 24)
    }

    private func addCustomRoom() {
        let trimmed = customRoomName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let newRoom = Room(id: "custom_\(trimmed.lowercased().replacingOccurrences(of: " ", with: "_"))",
                          name: trimmed, icon: "📍", color: "F0EBF5")
        customRooms.append(newRoom)
        selectedRooms.insert(newRoom.id)
        customRoomName = ""
    }
}

struct RoomToggleCard: View {
    let room: Room
    let isSelected: Bool
    let onTap: () -> Void

    private var bgColor: Color {
        Color(hex: room.color)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: room.icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(isSelected ? .white : CozyTheme.accent)
                Text(room.name)
                    .font(.custom("DMSans-Medium", size: 14))
                    .foregroundColor(CozyTheme.primary)
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CozyTheme.accent)
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(isSelected ? bgColor : CozyTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(CozyTheme.cornerRadius)
            .scaleEffect(isSelected ? 1.01 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
