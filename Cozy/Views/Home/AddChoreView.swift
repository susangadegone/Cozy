import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var selectedRoom: String = ""
    @State private var selectedChore: String = ""
    @State private var choreNameInput: String = ""
    @State private var selectedFrequency: String = "Weekly"
    @State private var selectedDays: Set<String> = []
    @State private var selectedDate: Date = Date()
    @State private var showNameError: Bool = false

    private let frequencies = ["Daily", "2–3 times/week", "Weekly", "Every 2 weeks", "Monthly"]
    private let dayPills = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

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
            ForEach(0..<3, id: \.self) { i in
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
        case 1: choreDetails
        case 2: schedulePicker
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
            withAnimation(.easeInOut(duration: 0.15)) { step = 1 }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: room.icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(isOn ? CozyTheme.accent : CozyTheme.primary)
                Text(room.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isOn ? CozyTheme.accent : Color(hex: "8B6B5A"))
            }
            .frame(maxWidth: .infinity).frame(height: 100)
            .background(isOn ? CozyTheme.accent.opacity(0.12) : Color(hex: room.color))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn ? CozyTheme.accent : CozyTheme.border, lineWidth: isOn ? 2 : 1)
            )
        }
    }

    // MARK: - Step 2: Chore Details
    private var choreDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What needs doing?")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)

            VStack(alignment: .leading, spacing: 6) {
                TextField("Chore name", text: $choreNameInput)
                    .font(.system(size: 16))
                    .foregroundColor(CozyTheme.primary)
                    .padding(14)
                    .background(CozyTheme.card)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(showNameError ? Color.red.opacity(0.6) : CozyTheme.border, lineWidth: 1))
                    .onChange(of: choreNameInput) {
                        if showNameError && !choreNameInput.isEmpty { showNameError = false }
                    }
                if showNameError {
                    Text("Name is required.")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.leading, 4)
                }
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

            Button {
                let name = choreNameInput.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { showNameError = true; return }
                selectedChore = name
                withAnimation(.easeInOut(duration: 0.15)) { step = 2 }
            } label: {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(choreNameInput.trimmingCharacters(in: .whitespaces).isEmpty
                        ? CozyTheme.border : CozyTheme.accent)
                    .cornerRadius(14)
            }
            .disabled(choreNameInput.trimmingCharacters(in: .whitespaces).isEmpty)
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

    // MARK: - Step 3: Schedule
    private var schedulePicker: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Which days?")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("You can change this anytime.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)

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
    }

    // MARK: - Confirm Button
    private var confirmButton: some View {
        Group {
            if step == 2 {
                Button(action: saveChore) {
                    Text("Add Chore")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(canSave ? CozyTheme.accent : CozyTheme.border)
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
        let scheduledDate = nextDate(for: selectedDays.first)
        let scheduledDayName = DateFormatters.dayOfWeek.string(from: scheduledDate)
        let chore = Chore(
            id: UUID(),
            userId: UUID(),
            roomId: selectedRoom,
            choreName: selectedChore,
            dayOfWeek: scheduledDayName,
            isDone: false,
            scheduledDate: DateFormatters.yearMonthDay.string(from: scheduledDate)
        )
        appState.addChore(chore)
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
