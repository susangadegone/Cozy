import SwiftUI

struct ChoreHistoryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var page = 1
    private let pageSize = 20

    private var allHistory: [Chore] { appState.choreHistory }
    private var displayed: [Chore] { Array(allHistory.prefix(page * pageSize)) }
    private var hasMore: Bool { displayed.count < allHistory.count }

    var body: some View {
        NavigationView {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                if allHistory.isEmpty {
                    emptyState
                } else {
                    listView
                }
            }
            .navigationTitle("Chore History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.accent)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🧺")
                .font(.system(size: 56))
            Text("No completed chores yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("Start checking off chores to see your history here.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(displayed.enumerated()), id: \.element.id) { idx, chore in
                    HistoryRow(chore: chore)
                    if idx < displayed.count - 1 {
                        Divider().opacity(0.3).padding(.leading, 60).padding(.horizontal, 16)
                    }
                }
                if hasMore {
                    Button {
                        withAnimation { page += 1 }
                    } label: {
                        Text("Load more")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(CozyTheme.accent)
                            .padding(.vertical, 14)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                    .stroke(CozyTheme.border, lineWidth: 1)
            )
            .padding(16)
        }
    }
}

struct HistoryRow: View {
    let chore: Chore

    var body: some View {
        HStack(spacing: 12) {
            let room = Room.defaults.first { $0.id == chore.roomId }
            ZStack {
                Circle()
                    .fill(Color(hex: room?.color ?? "F0EBF5"))
                    .frame(width: 40, height: 40)
                Text(room?.icon ?? "📦")
                    .font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(chore.choreName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                HStack(spacing: 6) {
                    Text(room?.name ?? "Other")
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                    Text("·")
                        .foregroundColor(CozyTheme.mutedText)
                    Text(formattedDate(chore.completedAt ?? chore.scheduledDate))
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private func formattedDate(_ raw: String) -> String {
        let tryFormats = ["yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"]
        for fmt in tryFormats {
            let df = DateFormatter(); df.dateFormat = fmt
            if let d = df.date(from: raw) {
                let out = DateFormatter()
                out.dateStyle = .medium
                out.timeStyle = raw.contains("T") ? .short : .none
                return out.string(from: d)
            }
        }
        return raw
    }
}
