import SwiftUI
import UserNotifications

struct OnboardingQ5View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

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
        OnboardingShell(step: 5, total: 5, onBack: { appRouter.navigate(to: .onboardingQ4) }) {
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
        VStack(alignment: .leading, spacing: 6) {
            Text("🔔")
                .font(.system(size: 36))
            Text("How do you want\nCozy to remind you?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
        }
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options) { opt in
                OnboardingChoiceCard(
                    label: opt.id,
                    icon: opt.icon,
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

        onboardingVM.generateSchedule()
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
            ? "Good morning! Your chores for today are ready."
            : "Evening check-in — see what's left today."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = h; comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "cozy.daily.\(h)", content: content, trigger: trigger)
        center.add(req)
    }
}
