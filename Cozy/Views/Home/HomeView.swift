import SwiftUI

// MARK: - HomeView · Broadsheet edition
// Masthead header (kicker + serif nameplate) sits above the scrolling Dashboard.
// Square corners, hairline rules, front-page red accents only.
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dragManager = DragDropManager()

    @State private var showAddChore = false
    @State private var showCalendar = false
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
        .sheet(isPresented: $showCalendar) {
            CalendarView()
                .environmentObject(appState)
        }
        .onChange(of: appState.pendingConfettiEvent) { _, newValue in
            guard let event = newValue else { return }
            appState.pendingConfettiEvent = nil
            fireConfetti(event)
        }
        .onChange(of: appState.newlyEarnedBadge) { _, newValue in
            guard let badge = newValue else { return }
            showBadgeToast(badge)
        }
    }

    // MARK: - Main Layout
    private var mainLayout: some View {
        VStack(spacing: 0) {
            masthead
            ScrollView(showsIndicators: false) {
                DashboardView(
                    onChoreComplete: { fireConfetti(.choreDone) }
                )
                .environmentObject(appState)
                .environmentObject(dragManager)
            }
        }
    }

    // MARK: - Masthead (replaces rounded headerBar)
    private var masthead: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("THE COZY DAILY")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(2.8)
                        .foregroundColor(CozyTheme.mutedText)
                    Text(greetingLine)
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundColor(CozyTheme.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                if appState.currentStreak > 0 {
                    streakNameplate
                }
                calendarButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)

            // Double rule — the masthead's tell.
            Rectangle().fill(CozyTheme.primary).frame(height: 2)
            Rectangle().fill(CozyTheme.primary).frame(height: 0.5)
                .padding(.top, 2)
        }
    }

    private var streakNameplate: some View {
        Text("\(appState.currentStreak)-DAY STREAK")
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.4)
            .foregroundColor(CozyTheme.accent)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .overlay(Rectangle().stroke(CozyTheme.accent, lineWidth: 1))
    }

    private var calendarButton: some View {
        Button { showCalendar = true } label: {
            Image(systemName: "calendar")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(CozyTheme.primary)
                .frame(width: 32, height: 32)
                .overlay(Rectangle().stroke(CozyTheme.primary, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - FAB — square ink button, not a circle
    private var fabButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button { showAddChore = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(CozyTheme.background)
                        .frame(width: 56, height: 56)
                        .background(CozyTheme.primary)
                        .overlay(
                            Rectangle()
                                .inset(by: 4)
                                .stroke(CozyTheme.background, lineWidth: 1)
                        )
                        .shadow(color: CozyTheme.primary.opacity(0.22), radius: 0, x: 3, y: 3)
                        .scaleEffect(fabPressed ? 0.94 : 1.0)
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

    private func toastBanner(_ message: String, icon: String?) -> some View {
        HStack(spacing: 10) {
            if let icon {
                Text(icon).font(.system(size: 18))
            }
            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(CozyTheme.background)
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .background(CozyTheme.primary)
        .overlay(Rectangle().stroke(CozyTheme.primary, lineWidth: 1))
        .padding(.bottom, 100)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Helpers
    private func fireConfetti(_ event: ConfettiEvent) {
        withAnimation { activeConfetti = event }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { activeConfetti = nil }
        }
    }

    private func showBadgeToast(_ badge: BadgeDefinition) {
        withAnimation(.spring()) {
            toastIcon = badge.icon
            toastMessage = "\(badge.name) unlocked"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                toastMessage = nil
                toastIcon = nil
                appState.newlyEarnedBadge = nil
            }
        }
    }

    private var greetingLine: String {
        let name = appState.profile?.displayName ?? "Friend"
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Morning, \(name)." }
        if hour < 17 { return "Afternoon, \(name)." }
        return "Evening, \(name)."
    }
}
