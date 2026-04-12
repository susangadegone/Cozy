import SwiftUI
import UserNotifications

struct NotificationPrefsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            toggleRow(
                label: "Daily reminders",
                icon: "sun.max.fill",
                color: .orange,
                binding: Binding(
                    get: { appState.preferences.dailyReminders },
                    set: { appState.preferences.dailyReminders = $0; save() }
                )
            )
            divider
            toggleRow(
                label: "Overdue chore alerts",
                icon: "exclamationmark.triangle.fill",
                color: .red,
                binding: Binding(
                    get: { appState.preferences.overdueAlerts },
                    set: { appState.preferences.overdueAlerts = $0; save() }
                )
            )
            divider
            toggleRow(
                label: "Partner activity",
                icon: "person.2.fill",
                color: CozyTheme.accent,
                binding: Binding(
                    get: { appState.preferences.partnerActivity },
                    set: { appState.preferences.partnerActivity = $0; save() }
                )
            )
            divider
            toggleRow(
                label: "Streak reminders",
                icon: "flame.fill",
                color: .orange,
                binding: Binding(
                    get: { appState.preferences.streakReminders },
                    set: { appState.preferences.streakReminders = $0; save() }
                )
            )
        }
    }

    private var divider: some View {
        Divider().opacity(0.3).padding(.leading, 44)
    }

    private func toggleRow(label: String, icon: String, color: Color, binding: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .cornerRadius(8)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(CozyTheme.accent)
        }
        .padding(.vertical, 10)
    }

    private func save() {
        requestPermissionIfNeeded()
        Task { await appState.savePreferences() }
    }

    private func requestPermissionIfNeeded() {
        let prefs = appState.preferences
        let anyOn = prefs.dailyReminders || prefs.overdueAlerts || prefs.partnerActivity || prefs.streakReminders
        guard anyOn else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, err in
            if let err = err { NSLog("Notification permission error: \(err)") }
            NSLog("Notification permission granted: \(granted)")
        }
    }
}
