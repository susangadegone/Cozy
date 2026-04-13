import SwiftUI

private struct RoomTile: Identifiable {
    let id: String
    let label: String
    let icon: String
}

struct OnboardingQ4View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selected: Set<String> = []

    private let rooms: [RoomTile] = [
        RoomTile(id: "Kitchen",       label: "Kitchen",      icon: "fork.knife"),
        RoomTile(id: "Bedroom",       label: "Bedroom",      icon: "bed.double"),
        RoomTile(id: "Bathroom",      label: "Bathroom",     icon: "shower"),
        RoomTile(id: "Living room",   label: "Living room",  icon: "sofa"),
        RoomTile(id: "Outdoor/yard",  label: "Outdoor",      icon: "leaf"),
        RoomTile(id: "Home office",   label: "Home office",  icon: "desktopcomputer"),
        RoomTile(id: "Other",         label: "Other",        icon: "plus.circle")
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                OnboardingProgressBar(step: 4, total: 5)
                    .padding(.bottom, 28)
                questionHeader.padding(.bottom, 24)
                roomGrid
                captionLine.padding(.top, 12)
                Spacer()
                nextButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 44)
        }
    }

    private var questionHeader: some View {
        Text("Which rooms do you want to keep on top of?")
            .font(.system(size: 24, weight: .bold, design: .serif))
            .foregroundColor(CozyTheme.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var roomGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(rooms) { room in
                roomTile(room)
                    .onTapGesture { toggle(room.id) }
            }
        }
    }

    private func roomTile(_ room: RoomTile) -> some View {
        let isSelected = selected.contains(room.id)
        return ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Image(systemName: room.icon)
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? .white : CozyTheme.accent)
                Text(room.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : CozyTheme.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(isSelected ? CozyTheme.primary : Color(hex: "F5EDE4"))
            .cornerRadius(14)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(6)
            }
        }
    }

    private var captionLine: some View {
        Text("You can always add more later")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
    }

    private var nextButton: some View {
        Button {
            onboardingVM.selectedRooms = Array(selected)
            appRouter.navigate(to: .onboardingQ5)
        } label: {
            Text("Next")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(selected.isEmpty ? CozyTheme.primary.opacity(0.4) : CozyTheme.primary)
                .cornerRadius(CozyTheme.cornerRadius)
        }
        .disabled(selected.isEmpty)
    }

    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
}
