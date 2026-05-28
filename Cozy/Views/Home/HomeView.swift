import SwiftUI

enum TodayEnergy: String, CaseIterable {
    case light, normal, big
    var label: String {
        switch self {
        case .light:  return "Tired"
        case .normal: return "So-so"
        case .big:    return "Good to go"
        }
    }
    var cap: Int {
        switch self { case .light: return 1; case .normal: return 2; case .big: return 100 }
    }
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dragManager = DragDropManager()

    @State private var showAddChore = false
    @State private var showCalendar = false
    @State private var activeConfetti: ConfettiEvent? = nil
    @State private var toastMessage: String?
    @State private var toastIcon: String?
    @State private var todayEnergy: TodayEnergy = .normal

    private let energyDateKey = "cozy.todayEnergy.date"
    private let energyValueKey = "cozy.todayEnergy.value"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Divider().background(CozyTheme.border).opacity(0.5)
                energyPicker
                ScrollView(showsIndicators: false) {
                    DashboardView(
                        energy: todayEnergy,
                        onChoreComplete: { fireConfetti(.choreDone) }
                    )
                    .environmentObject(appState)
                    .environmentObject(dragManager)
                }
            }
            CalFAB { showAddChore = true }
            confettiLayer
            toastLayer
        }
        .onAppear(perform: loadEnergy)
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
            calendarBtn
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var energyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How are you feeling?")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            HStack(spacing: 8) {
                ForEach(TodayEnergy.allCases, id: \.self) { e in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { todayEnergy = e }
                        saveEnergy()
                    } label: {
                        Text(e.label)
                            .font(.system(size: 14, weight: .semibold))
                            .minimumScaleFactor(0.85)
                            .lineLimit(1)
                            .foregroundColor(todayEnergy == e ? .white : CozyTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(todayEnergy == e ? CozyTheme.accent : CozyTheme.card)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(todayEnergy == e ? CozyTheme.accent : CozyTheme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(energyHint)
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
                .transition(.opacity)
                .id(todayEnergy)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private var energyHint: String {
        let total = appState.todayChores.count
        switch todayEnergy {
        case .light:
            return total == 0 ? "Nothing due — rest easy." : "Just 1 chore today. Every bit counts."
        case .normal:
            let n = min(2, total)
            return total == 0 ? "Nothing due today." : "We'll show you \(n == 1 ? "1 chore" : "1–2 chores"). See how you feel."
        case .big:
            return total == 0 ? "Nothing due today." : "Let's tackle all \(total) chore\(total == 1 ? "" : "s")."
        }
    }

    private func loadEnergy() {
        let today = DateFormatters.yearMonthDay.string(from: Date())
        let savedDate = UserDefaults.standard.string(forKey: energyDateKey)
        if savedDate == today,
           let raw = UserDefaults.standard.string(forKey: energyValueKey),
           let e = TodayEnergy(rawValue: raw) {
            todayEnergy = e
        } else {
            todayEnergy = .normal
        }
    }

    private func saveEnergy() {
        let today = DateFormatters.yearMonthDay.string(from: Date())
        UserDefaults.standard.set(today, forKey: energyDateKey)
        UserDefaults.standard.set(todayEnergy.rawValue, forKey: energyValueKey)
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
