import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    var onChoreComplete: () -> Void

    @State private var selectedChore: Chore? = nil

    private let dayChoreCap = 5

    private var capped: [Chore] {
        let all = appState.todayChores
        let undone = all.filter { !$0.isDone }
        let done = all.filter { $0.isDone }
        return Array((undone + done).prefix(dayChoreCap))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle
            if capped.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 120)
        .sheet(item: $selectedChore) { chore in
            ChoreDetailView(chore: chore).environmentObject(appState)
        }
    }

    private var sectionTitle: some View {
        HStack {
            Text("Today")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Text("\(capped.filter { !$0.isDone }.count) left")
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var list: some View {
        VStack(spacing: 8) {
            ForEach(capped) { chore in
                DashChoreRow(chore: chore, onToggle: handleToggle)
                    .onTapGesture { selectedChore = chore }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Text("Nothing due today")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("A quiet morning. Enjoy it.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func handleToggle(_ chore: Chore) {
        let wasUndone = !chore.isDone
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            appState.toggleChore(chore)
        }
        if wasUndone { onChoreComplete() }
    }
}

private struct DashChoreRow: View {
    @EnvironmentObject var appState: AppState
    let chore: Chore
    let onToggle: (Chore) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button { onToggle(chore) } label: {
                ZStack {
                    Circle()
                        .strokeBorder(chore.isDone ? CozyTheme.teal : CozyTheme.border, lineWidth: 1.5)
                        .background(Circle().fill(chore.isDone ? CozyTheme.teal : Color.clear))
                        .frame(width: 24, height: 24)
                    if chore.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 3) {
                Text(chore.choreName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                    .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                    .lineLimit(2)
                Text(roomName)
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(CozyTheme.card)
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }

    private var roomName: String {
        Room.defaults.first(where: { $0.id == chore.roomId })?.name ?? chore.roomId.capitalized
    }
}
