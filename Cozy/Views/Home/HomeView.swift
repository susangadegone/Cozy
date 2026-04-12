import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dragManager = DragDropManager()

    @State private var showAddChore = false
    @State private var activeConfetti: ConfettiEvent? = nil
    @State private var toastMessage: String?
    @State private var toastIcon: String?
    @State private var fabPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CozyTheme.background.ignoresSafeArea()
            mainLayout
            confettiLayer
            toastLayer
            fabButton
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .task { await appState.loadData() }
        .onChange(of: appState.pendingConfettiEvent) { event in
            guard let event else { return }
            appState.pendingConfettiEvent = nil
            fireConfetti(event)
        }
        .onChange(of: appState.newlyEarnedBadge) { badge in
            guard let badge else { return }
            showBadgeToast(badge)
        }
    }

    // MARK: - Confetti Layer
    @ViewBuilder
    private var confettiLayer: some View {
        if let event = activeConfetti {
            ConfettiOverlay(event: event)
                .ignoresSafeArea()
                .transition(.opacity)
        }
    }

    // MARK: - Toast Layer
    @ViewBuilder
    private var toastLayer: some View {
        if let msg = toastMessage {
            VStack {
                Spacer()
                toastBanner(msg, icon: toastIcon)
            }
        }
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
                    onChoreComplete: { fireConfetti(.choreDone) }
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

    // MARK: - Confetti & Toast helpers
    private func fireConfetti(_ event: ConfettiEvent) {
        withAnimation { activeConfetti = event }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { activeConfetti = nil }
        }
    }

    private func showBadgeToast(_ badge: BadgeDefinition) {
        withAnimation(.spring()) {
            toastIcon = badge.icon
            toastMessage = "\(badge.name) unlocked!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                toastMessage = nil
                toastIcon = nil
                appState.newlyEarnedBadge = nil
            }
        }
    }

    private func toastBanner(_ message: String, icon: String?) -> some View {
        HStack(spacing: 8) {
            if let icon {
                Text(icon).font(.system(size: 20))
            }
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
        .background(Color(hex: "5C3D2E").opacity(0.94))
        .cornerRadius(25)
        .shadow(color: Color(hex: "5C3D2E").opacity(0.25), radius: 10, y: 4)
        .padding(.bottom, 100)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var greetingLine: String {
        let name = appState.profile?.displayName ?? "Friend"
        return "Hey \(name)! 👋"
    }
}
