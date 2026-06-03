import SwiftUI

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

    private let rooms: [RoomTile] = [
        RoomTile(id: "Kitchen",      label: "Kitchen",     icon: "fork.knife"),
        RoomTile(id: "Bedroom",      label: "Bedroom",     icon: "bed.double"),
        RoomTile(id: "Bathroom",     label: "Bathroom",    icon: "shower"),
        RoomTile(id: "Living room",  label: "Living room", icon: "sofa"),
        RoomTile(id: "Outdoor/yard", label: "Outdoor",     icon: "leaf"),
        RoomTile(id: "Laundry",      label: "Laundry",     icon: "washer")
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        OnboardingShell(step: 5, total: 6, onBack: { appRouter.navigate(to: .cleanlinessGoal) }) {
            questionHeader
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            roomGrid
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            hint
                .padding(.top, 10)
            Spacer()
            OnboardingNextButton(isEnabled: !selected.isEmpty) {
                onboardingVM.selectedRooms = Array(selected)
                appRouter.navigate(to: .onboardingQ5)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Which rooms do you\nwant to take care of?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
            Text("We'll build your starter chore list around these.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
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
        return VStack(spacing: 6) {
            Image(systemName: room.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(on ? .white : CozyTheme.accent)
            Text(room.label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(on ? .white : CozyTheme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
        .background(on ? CozyTheme.accent : CozyTheme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(on ? CozyTheme.accent : CozyTheme.border, lineWidth: on ? 2 : 1)
        )
        .overlay(alignment: .topTrailing) {
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

    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
}
