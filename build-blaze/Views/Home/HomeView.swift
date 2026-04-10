import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    @StateObject private var dragManager = DragDropManager()

    @State private var showAddChore = false
    @State private var showConfetti = false
    @State private var toastMessage: String?
    @State private var fabPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CozyTheme.background.ignoresSafeArea()
            mainLayout
            if showConfetti { ConfettiOverlay() }
            if let msg = toastMessage { toastBanner(msg) }
            fabButton
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .task { await appState.loadData() }
    }

    // MARK: - FAB
    private var fabButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button { showAddChore = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(CozyTheme.accent)
                        .clipShape(Circle())
                        .shadow(color: CozyTheme.accent.opacity(0.35), radius: 16, x: 0, y: 4)
                        .scaleEffect(fabPressed ? 0.92 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: fabPressed)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in fabPressed = true }
                        .onEnded { _ in fabPressed = false }
                )
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .safeAreaPadding(.bottom)
            }
        }
    }

    // MARK: - Main Layout
    private var mainLayout: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().opacity(0.2)
            ScrollView(showsIndicators: false) {
                DashboardView(
                    onChoreComplete: fireConfetti,
                    onAddChore: { showAddChore = true }
                )
                .environmentObject(appState)
                .environmentObject(dragManager)
            }
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cozy Home")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Text(greetingLine)
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            if appState.currentStreak > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(appState.currentStreak)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(CozyTheme.accent)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(CozyTheme.accent.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: - Toast & Confetti
    private func fireConfetti() {
        showConfetti = true
        showToast("Nice work! 🎉")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfetti = false }
        }
    }

    private func showToast(_ message: String) {
        withAnimation(.spring()) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { toastMessage = nil }
        }
    }

    private func toastBanner(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(CozyTheme.primary.opacity(0.92))
                .cornerRadius(25)
                .shadow(color: CozyTheme.primary.opacity(0.2), radius: 8, y: 4)
                .padding(.bottom, 30)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Helpers
    private var greetingLine: String {
        let name = appState.profile?.displayName ?? "Friend"
        return "Hey \(name)! 👋"
    }
}
