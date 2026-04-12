import SwiftUI

struct FloatingDragChip: View {
    @EnvironmentObject var dragManager: DragDropManager

    var body: some View {
        Group {
            if let chore = dragManager.draggingChore {
                chipView(chore)
                    .position(dragManager.dragLocation)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        .animation(.interactiveSpring(), value: dragManager.draggingChore?.id)
    }

    private func chipView(_ chore: Chore) -> some View {
        let room = Room.defaults.first { $0.id == chore.roomId }
        let bg = room.map { Color(hex: $0.color) } ?? CozyTheme.card
        return HStack(spacing: 6) {
            Circle()
                .fill(CozyTheme.accent)
                .frame(width: 8, height: 8)
            Text(chore.choreName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(bg)
        .cornerRadius(20)
        .shadow(color: CozyTheme.primary.opacity(0.25), radius: 12, y: 6)
        .scaleEffect(dragManager.isOverTrash ? 0.85 : 1.05)
        .animation(.spring(response: 0.3), value: dragManager.isOverTrash)
    }
}

// MARK: - Trash Drop Zone
struct TrashDropZone: View {
    @EnvironmentObject var dragManager: DragDropManager

    var body: some View {
        Group {
            if dragManager.isDragging {
                trashBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35), value: dragManager.isDragging)
    }

    private var trashBar: some View {
        HStack(spacing: 12) {
            Image(systemName: dragManager.isOverTrash ? "trash.fill" : "trash")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .scaleEffect(dragManager.isOverTrash ? 1.25 : 1.0)
                .animation(.spring(response: 0.3), value: dragManager.isOverTrash)
            Text(dragManager.isOverTrash ? "Release to delete" : "Drag here to delete")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(dragManager.isOverTrash ? Color.red : Color.red.opacity(0.75))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    dragManager.trashZoneRect = geo.frame(in: .global)
                }
            }
        )
        .animation(.spring(response: 0.3), value: dragManager.isOverTrash)
    }
}
