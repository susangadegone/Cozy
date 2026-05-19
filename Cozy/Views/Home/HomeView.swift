import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dragManager = DragDropManager()

    @State private var showAddChore = false
    @State private var showCalendar = false
    @State private var activeConfetti: ConfettiEvent? = nil
    @State private var toastMessage: String?
    @State private var toastIcon: String?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Divider().background(CozyTheme.border).opacity(0.5)
                ScrollView(showsIndicators: false) {
                    DashboardView(onChoreComplete: { fireConfetti(.choreDone) })
                        .environmentObject(appState)
                        .environmentObject(dragManager)
                }
            }
            CalFAB { showAddChore = true }
            confettiLayer
            toastLayer
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCalendar) {
            CalendarView().environmentObject(appState)
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

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                Text(dateLine)
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            if appState.currentStreak > 0 {
                streakChip
            }
            calendarBtn
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var streakChip: some View {
        Text("\(appState.currentStreak)d")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(CozyTheme.accent)
            .cornerRadius(14)
    }

    private var calendarBtn: some View {
        Button { showCalendar = true } label: {
            Image(systemName: "calendar")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(CozyTheme.primary)
                .frame(width: 36, height: 36)
                .background(CozyTheme.border.opacity(0.5))
                .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var confettiLayer: some View {
        if let event = activeConfetti {
            ConfettiOverlay(event: event).ignoresSafeArea().transition(.opacity)
        }
    }

    @ViewBuilder
    private var toastLayer: some View {
        if let msg = toastMessage {
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    if let icon = toastIcon {
                        Text(icon).font(.system(size: 18))
                    }
                    Text(msg)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 18).padding(.vertical, 12)
                .background(CozyTheme.primary)
                .cornerRadius(22)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var greeting: String {
        let name = appState.profile?.displayName ?? "Friend"
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Morning, \(name)" }
        if hour < 17 { return "Afternoon, \(name)" }
        return "Evening, \(name)"
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMM d"
        return f.string(from: Date())
    }

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
}
