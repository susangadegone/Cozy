import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var selectedRoom: String = ""
    @State private var selectedChore: String = ""
    @State private var selectedDate: Date = Date()
    @State private var assignedTo: String = ""

    // Pre-populate assignedTo with current user's name
    private func defaultAssignedTo() -> String {
        appState.profile?.displayName ?? "Me"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    stepIndicator
                    ScrollView { stepContent.padding(20) }
                    confirmButton
                }
            }
            .navigationTitle("Add Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
        }
    }

    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? CozyTheme.accent : CozyTheme.border)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: roomPicker
        case 1: chorePicker
        case 2: datePicker
        case 3: memberPicker
        default: EmptyView()
        }
    }

    private var roomPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pick a room")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Room.defaults) { room in
                    roomCard(room)
                }
            }
        }
    }

    private func roomCard(_ room: Room) -> some View {
        let isOn = selectedRoom == room.id
        return Button {
            selectedRoom = room.id
            withAnimation { step = 1 }
        } label: {
            VStack(spacing: 8) {
                Text(room.icon).font(.system(size: 32))
                Text(room.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
            }
            .frame(maxWidth: .infinity).frame(height: 100)
            .background(isOn ? CozyTheme.accent.opacity(0.15) : Color(hex: room.color))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: isOn ? 2 : 1)
            )
        }
    }

    private var chorePicker: some View {
        let chores = Room.defaultChores[selectedRoom] ?? []
        return VStack(alignment: .leading, spacing: 16) {
            Text("Pick a chore")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            ForEach(chores, id: \.self) { name in
                choreOption(name)
            }
        }
    }

    private func choreOption(_ name: String) -> some View {
        let isOn = selectedChore == name
        return Button {
            selectedChore = name
            withAnimation { step = 2 }
        } label: {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                if isOn {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CozyTheme.accent)
                }
            }
            .padding(16)
            .background(isOn ? CozyTheme.accent.opacity(0.1) : CozyTheme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
            )
        }
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When?")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(CozyTheme.accent)
            Button {
                // Always pre-select the current user when advancing to assign step
                if assignedTo.isEmpty {
                    assignedTo = defaultAssignedTo()
                }
                withAnimation { step = 3 }
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(CozyTheme.primary)
                    .cornerRadius(14)
            }
        }
    }

    private var memberPicker: some View {
        // Resolve a clean display name — never "Me" or empty
        let rawName = appState.profile?.displayName ?? ""
        let trimmed = rawName.trimmingCharacters(in: .whitespaces)
        let myName = (trimmed.isEmpty || trimmed.lowercased() == "me") ? "You" : trimmed
        let myEmoji = appState.profile?.avatarEmoji ?? "🙋"
        let householdMembers = appState.profile?.members ?? []
        let currentAssigned = assignedTo.isEmpty ? myName : assignedTo
        // Label shows real name + "(Me)" so it's always clear who "Me" is
        let myLabel = "\(myName) (Me)"
        return VStack(alignment: .leading, spacing: 16) {
            Text("Assign to")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            assignOption(name: myName, displayLabel: myLabel, emoji: myEmoji, currentValue: currentAssigned)
            ForEach(householdMembers) { member in
                assignOption(name: member.name, displayLabel: member.name, emoji: member.emoji, currentValue: currentAssigned)
            }
            if householdMembers.isEmpty {
                Text("Add household members in Profile → Household to assign chores to others.")
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .onAppear {
            if assignedTo.isEmpty { assignedTo = myName }
        }
    }

    private func assignOption(name: String, displayLabel: String, emoji: String, currentValue: String) -> some View {
        let isOn = currentValue == name
        return Button { assignedTo = name } label: {
            HStack(spacing: 12) {
                Text(emoji).font(.system(size: 24))
                Text(displayLabel)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                Spacer()
                if isOn {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(CozyTheme.accent)
                }
            }
            .padding(16)
            .background(isOn ? CozyTheme.accent.opacity(0.1) : CozyTheme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
            )
        }
    }

    // MARK: - Confirm Button
    private var confirmButton: some View {
        Group {
            if step == 3 {
                Button(action: saveChore) {
                    Text("Add Chore ✨")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(canSave ? CozyTheme.primary : CozyTheme.border)
                        .cornerRadius(CozyTheme.cornerRadius)
                }
                .disabled(!canSave)
                .padding(20)
            }
        }
    }

    private var canSave: Bool {
        !selectedRoom.isEmpty && !selectedChore.isEmpty
    }

    private func saveChore() {
        guard let userId = AuthManager.shared.currentUserId else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "EEEE"
        let finalAssignedTo = assignedTo.isEmpty ? defaultAssignedTo() : assignedTo
        let chore = Chore(
            id: UUID(),
            userId: userId,
            roomId: selectedRoom,
            choreName: selectedChore,
            dayOfWeek: dayFmt.string(from: selectedDate),
            assignedTo: finalAssignedTo,
            isDone: false,
            scheduledDate: fmt.string(from: selectedDate)
        )
        Task {
            await appState.addChore(chore)
            dismiss()
        }
    }
}
