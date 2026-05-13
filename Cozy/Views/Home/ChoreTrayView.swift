import SwiftUI

struct ChoreTrayView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    var onComplete: () -> Void
    var onAddChore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            trayHeader
            if appState.todayChores.isEmpty {
                EmptyChoreState()
            } else {
                choreList
            }
        }
        .padding(.horizontal, 16)
    }

    private var trayHeader: some View {
        HStack {
            Text(trayTitle)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Button(action: onAddChore) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Add chore")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(CozyTheme.accent)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(CozyTheme.accent.opacity(0.1))
                .cornerRadius(20)
            }
        }
    }

    private var choreList: some View {
        ForEach(appState.todayChores) { chore in
            TrayChoreRow(chore: chore, onToggle: {
                appState.toggleChore(chore)
                if !chore.isDone { onComplete() }
            }, onDragStart: { loc in
                dragManager.startDrag(chore: chore, at: loc)
            })
        }
    }

    private var trayTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d"
        return fmt.string(from: appState.selectedDate)
    }
}

// MARK: - Tray Chore Row
struct TrayChoreRow: View {
    let chore: Chore
    let onToggle: () -> Void
    let onDragStart: (CGPoint) -> Void

    @State private var isLongPressing = false
    @GestureState private var isDragging = false

    var body: some View {
        HStack(spacing: 12) {
            dragHandle
            colorDot
            choreInfo
            Spacer()
            assigneeBadge
            doneButton
        }
        .padding(14)
        .background(rowBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(CozyTheme.border.opacity(0.5), lineWidth: 1)
        )
        .scaleEffect(isLongPressing ? 1.02 : 1.0)
        .opacity(isLongPressing ? 0.6 : 1.0)
        .animation(.spring(response: 0.3), value: isLongPressing)
        .gesture(dragGesture)
    }

    private var dragHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isLongPressing ? CozyTheme.accent : CozyTheme.mutedText.opacity(0.4))
            .animation(.easeInOut(duration: 0.2), value: isLongPressing)
    }

    private var colorDot: some View {
        Circle()
            .fill(roomColor)
            .frame(width: 10, height: 10)
    }

    private var choreInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(chore.choreName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(CozyTheme.primary)
                .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                .opacity(chore.isDone ? 0.5 : 1.0)
            Text(roomName)
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    @ViewBuilder
    private var assigneeBadge: some View {
        EmptyView()
    }

    private var doneButton: some View {
        Button(action: onToggle) {
            Image(systemName: chore.isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundColor(chore.isDone ? .green : CozyTheme.mutedText)
        }
    }

    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.45)
            .onChanged { _ in }
            .onEnded { _ in isLongPressing = true }
            .sequenced(before:
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        if isLongPressing {
                            onDragStart(value.location)
                        }
                    }
                    .onEnded { _ in isLongPressing = false }
            )
    }

    private var rowBackground: Color {
        roomColor.opacity(chore.isDone ? 0.25 : 0.45)
    }

    private var roomColor: Color {
        let room = Room.defaults.first { $0.id == chore.roomId }
        return room.map { Color(hex: $0.color) } ?? CozyTheme.card
    }

    private var roomName: String {
        Room.defaults.first { $0.id == chore.roomId }?.name ?? chore.roomId
    }
}

// MARK: - Empty State
struct EmptyChoreState: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🌿")
                .font(.system(size: 40))
            Text("Nothing here yet.")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Tap + to add a chore")
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundColor(CozyTheme.border)
        )
    }
}
