import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
    @State private var showAddChore = false
    @State private var showMonthView = false
    @State private var showConfetti = false
    @State private var toastMessage: String?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CozyTheme.background.ignoresSafeArea()
            mainContent
            fabButton
            if showConfetti { ConfettiOverlay() }
            if let msg = toastMessage { toastView(msg) }
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.visible)
        }
        .task { await appState.loadData() }
    }

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerBar
                greetingCard
                WeekStripView()
                choresSummary
                ChoreTrayView(onComplete: handleChoreComplete)
            }
            .padding(.bottom, 100)
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cozy")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Text(formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Button { showMonthView.toggle() } label: {
                Image(systemName: showMonthView ? "list.bullet" : "calendar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                    .frame(width: 40, height: 40)
                    .background(CozyTheme.card)
                    .cornerRadius(12)
            }
            Menu {
                Button("Sign Out", role: .destructive) {
                    Task { try? await authManager.signOut() }
                }
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(CozyTheme.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var greetingCard: some View {
        let name = appState.profile?.displayName ?? "Friend"
        let done = appState.completedToday
        let total = appState.totalToday
        VStack(alignment: .leading, spacing: 12) {
            Text("Hey, \(name)! 👋")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            progressSection(done: done, total: total)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [CozyTheme.card, CozyTheme.accent.opacity(0.08)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(CozyTheme.cardCornerRadius)
        .padding(.horizontal, 20)
    }

    private func progressSection(done: Int, total: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            let progress: Double = total > 0 ? Double(done) / Double(total) : 0
            HStack {
                Text("\(done)/\(total) tasks done")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(CozyTheme.accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(CozyTheme.border).frame(height: 8)
                    Capsule().fill(CozyTheme.accent)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
    }

    private var choresSummary: some View {
        HStack(spacing: 12) {
            StatChip(icon: "checkmark.circle", value: "\(appState.completedToday)", label: "Done", color: .green)
            StatChip(icon: "circle", value: "\(appState.totalToday - appState.completedToday)", label: "Remaining", color: CozyTheme.accent)
            StatChip(icon: "house", value: "\(appState.profile?.rooms.count ?? 0)", label: "Rooms", color: CozyTheme.primary)
        }
        .padding(.horizontal, 20)
    }

    private var fabButton: some View {
        Button { showAddChore = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(CozyTheme.primary)
                .cornerRadius(28)
                .shadow(color: CozyTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }

    private func toastView(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(CozyTheme.primary.opacity(0.9))
                .cornerRadius(25)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func handleChoreComplete() {
        showConfetti = true
        toastMessage = "Nice work! ✨"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfetti = false; toastMessage = nil }
        }
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d"
        return fmt.string(from: appState.selectedDate)
    }
}

struct StatChip: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(CozyTheme.card)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CozyTheme.border, lineWidth: 1))
    }
}
