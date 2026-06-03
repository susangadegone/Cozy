import SwiftUI
import UserNotifications

struct OnboardingQ5View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var appState: AppState

    @State private var selection: String? = nil
    @State private var isBuilding = false
    @State private var appeared = false

    private struct ReminderOption: Identifiable {
        let id: String
        let icon: String
    }

    private let options: [ReminderOption] = [
        ReminderOption(id: "Morning check-in at 8am",     icon: "sunrise"),
        ReminderOption(id: "Evening wrap-up at 7pm",      icon: "moon.stars"),
        ReminderOption(id: "Only when something's overdue", icon: "exclamationmark.circle"),
        ReminderOption(id: "No reminders for now",        icon: "bell.slash")
    ]

    var body: some View {
        OnboardingShell(step: 6, total: 6, onBack: { appRouter.navigate(to: .onboardingQ4) }) {
            questionHeader
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            optionsList
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            hint.padding(.top, 10)
            Spacer()
            OnboardingNextButton(
                label: "Build my schedule",
                isEnabled: selection != nil,
                isLoading: isBuilding
            ) {
                Task { await buildSchedule() }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How do you want\nCozy to remind you?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
            Text("We'll only nudge you the way you choose.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options) { opt in
                OnboardingChoiceCard(
                    label: opt.id,
                    isSelected: selection == opt.id
                ) { selection = opt.id }
            }
        }
    }

    private var hint: some View {
        Text("You can change this anytime in Settings.")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
    }

    private func buildSchedule() async {
        guard let chosen = selection else { return }
        isBuilding = true
        onboardingVM.reminderStyle = chosen

        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        if granted { scheduleNotification(for: chosen, center: center) }

        // Map rooms from onboardingVM (display names) to room IDs used by preset library
        let roomIdMap: [String: String] = [
            "Kitchen": "kitchen",
            "Bedroom": "bedroom",
            "Bathroom": "bathroom",
            "Living room": "living",
            "Outdoor/yard": "outdoor",
            "Laundry": "laundry",
            "Other": "other"
        ]
        let roomIds = onboardingVM.selectedRooms.compactMap { roomIdMap[$0] }

        // Save all onboarding data and seed chores
        appState.completeOnboarding(
            name: onboardingVM.userName,
            homeName: onboardingVM.userName.isEmpty ? "My Home" : "\(onboardingVM.userName)'s Home",
            rooms: roomIds.isEmpty ? Array(onboardingVM.selectedRooms) : roomIds,
            notificationPref: chosen
        )

        onboardingVM.generateSchedule()
        // Persist cleanliness types for dashboard journey badge
        if let ct = onboardingVM.currentType {
            UserDefaults.standard.set(ct.rawValue, forKey: "cozy_currentType")
        }
        if let gt = onboardingVM.goalType {
            UserDefaults.standard.set(gt.rawValue, forKey: "cozy_goalType")
        }
        isBuilding = false
        appRouter.navigate(to: .scheduleReady)
    }

    private func scheduleNotification(for style: String, center: UNUserNotificationCenter) {
        var hour: Int? = nil
        if style == "Morning check-in at 8am" { hour = 8 }
        else if style == "Evening wrap-up at 7pm" { hour = 19 }
        guard let h = hour else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cozy"
        content.body = h == 8
            ? "A few quick wins today. Knock them out before coffee?"
            : "Evening check-in — anything quick before you wind down?"
        content.sound = .default

        var comps = DateComponents()
        comps.hour = h; comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "cozy.daily.\(h)", content: content, trigger: trigger)
        center.add(req)
    }
}
