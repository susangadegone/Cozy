import SwiftUI
import UserNotifications

struct NotificationOption: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String
    let requiresPermission: Bool
}

struct OnboardingStep5: View {
    @Binding var selected: String

    let options: [NotificationOption] = [
        NotificationOption(id: "morning_digest", emoji: "☀️", title: "Morning Digest",
                           subtitle: "A summary every day at 9 AM", requiresPermission: true),
        NotificationOption(id: "day_of", emoji: "⏰", title: "Day-of Reminder",
                           subtitle: "1 hour before each chore", requiresPermission: true),
        NotificationOption(id: "in_app", emoji: "📱", title: "In-App Only",
                           subtitle: "Reminders inside the app only", requiresPermission: false),
        NotificationOption(id: "none", emoji: "🔕", title: "No Thanks",
                           subtitle: "I'll check in on my own time", requiresPermission: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            optionsList
            Spacer()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🔔")
                .font(.system(size: 64))
                .padding(.top, 8)
            Text("Stay on Track")
                .font(.custom("Fraunces-Regular", size: 28))
                .foregroundColor(CozyTheme.primary)
            Text("How would you like to be reminded\nabout your chores?")
                .font(.custom("DMSans-Regular", size: 16))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.bottom, 28)
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options) { option in
                NotificationOptionRow(option: option, isSelected: selected == option.id) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = option.id
                    }
                    if option.requiresPermission {
                        requestNotificationPermission()
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                NSLog("Notification permission error: \(error)")
            }
            NSLog("Notification permission granted: \(granted)")
        }
    }
}

struct NotificationOptionRow: View {
    let option: NotificationOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(option.emoji)
                    .font(.system(size: 30))
                    .frame(width: 48, height: 48)
                    .background(isSelected ? CozyTheme.accent.opacity(0.15) : CozyTheme.border.opacity(0.4))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.custom("Fraunces-Regular", size: 16))
                        .foregroundColor(CozyTheme.primary)
                    Text(option.subtitle)
                        .font(.custom("DMSans-Regular", size: 13))
                        .foregroundColor(CozyTheme.mutedText)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(CozyTheme.accent)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? CozyTheme.accent.opacity(0.07) : CozyTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(CozyTheme.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}
