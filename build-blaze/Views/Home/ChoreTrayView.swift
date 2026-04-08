import SwiftUI

struct ChoreTrayView: View {
    @EnvironmentObject var appState: AppState
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            if appState.todayChores.isEmpty {
                EmptyChoreState()
            } else {
                choreList
            }
        }
        .padding(.horizontal, 20)
    }

    private var sectionHeader: some View {
        HStack {
            Text("Today's Chores")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Text("\(appState.todayChores.count) tasks")
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var choreList: some View {
        ForEach(appState.todayChores) { chore in
            ChoreRowView(chore: chore) {
                Task {
                    await appState.toggleChore(chore)
                    if !chore.isDone { onComplete() }
                }
            }
        }
    }
}

struct ChoreRowView: View {
    let chore: Chore
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            toggleButton
            choreDetails
            Spacer()
            assignedAvatar
        }
        .padding(14)
        .background(roomColor.opacity(0.5))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CozyTheme.border.opacity(0.5), lineWidth: 1))
    }

    private var toggleButton: some View {
        Button(action: onToggle) {
            Image(systemName: chore.isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(chore.isDone ? .green : CozyTheme.mutedText)
        }
    }

    private var choreDetails: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(chore.choreName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(CozyTheme.primary)
                .strikethrough(chore.isDone, color: CozyTheme.mutedText)
            Text(roomName)
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var assignedAvatar: some View {
        Group {
            if !chore.assignedTo.isEmpty {
                Text(chore.assignedTo)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(CozyTheme.card)
                    .cornerRadius(8)
            }
        }
    }

    private var roomColor: Color {
        let room = Room.defaults.first { $0.id == chore.roomId }
        return room.map { Color(hex: $0.color) } ?? CozyTheme.card
    }

    private var roomName: String {
        Room.defaults.first { $0.id == chore.roomId }?.name ?? chore.roomId
    }
}

struct EmptyChoreState: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("✨")
                .font(.system(size: 48))
            Text("All clear for today!")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Tap the + button to add a chore\nor relax — you've earned it!")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                .stroke(CozyTheme.border, lineWidth: 1)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
        )
    }
}
