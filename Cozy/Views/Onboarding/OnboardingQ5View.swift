import SwiftUI
import UserNotifications

struct OnboardingQ5View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil
    @State private var isBuilding = false

    private let options = [
        "Morning check-in at 8am",
        "Evening wrap-up at 7pm",
        "Only when something's overdue",
        "No reminders for now"
    ]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                OnboardingProgressBar(step: 5, total: 5)
                    .padding(.bottom, 28)
                questionHeader.padding(.bottom, 24)
                optionsList
                captionLine.padding(.top, 12)
                Spacer()
                buildButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 44)
        }
    }

    private var questionHeader: some View {
        Text("How do you want Cozy to remind you?")
            .font(.system(size: 24, weight: .bold, design: .serif))
            .foregroundColor(CozyTheme.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                OnboardingChoiceCard(label: option, isSelected: selection == option) {
                    selection = option
                }
            }
        }
    }

    private var captionLine: some View {
        Text("You can change this anytime in settings.")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
    }

    private var buildButton: some View {
        Button { Task { await buildSchedule() } } label: {
            ZStack {
                Text("Build my schedule")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isBuilding ? 0 : 1)
                if isBuilding { ProgressView().tint(.white) }
            }
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(selection == nil ? CozyTheme.primary.opacity(0.4) : CozyTheme.primary)
            .cornerRadius(CozyTheme.cornerRadius)
        }
        .disabled(selection == nil || isBuilding)
    }

    private func buildSchedule() async {
        guard let chosen = selection else { return }
        isBuilding = true
        onboardingVM.reminderStyle = chosen

        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false

        if granted {
            scheduleNotification(for: chosen, center: center)
        }

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
        content.body = h == 8 ? "Good morning! Your chores for today are ready." : "Evening check-in — see what's left today."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = h
        comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: "cozy.daily.\(h)", content: content, trigger: trigger)
        center.add(request)
    }
}
