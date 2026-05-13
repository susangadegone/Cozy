import SwiftUI
import UserNotifications

// MARK: - SettingsView
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false
    @State private var appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAF7F2").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        notificationsSection
                        calendarSection
                        householdSection
                        aboutSection
                        dangerZone
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
        }
        .confirmationDialog("Delete Account?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete my account", role: .destructive) {
                appState.devResetAll()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All your data will be permanently removed. This cannot be undone.")
        }
    }

    // MARK: - Notification Toggles
    private var notificationsSection: some View {
        SettingsCard(title: "Notifications", icon: "bell.fill") {
            VStack(spacing: 0) {
                settingsToggle(
                    label: "Daily reminders",
                    subtitle: "Nudge you each morning",
                    icon: "sun.max.fill",
                    iconColor: .orange,
                    binding: Binding(
                        get: { appState.preferences.dailyReminders },
                        set: { appState.preferences.dailyReminders = $0; save() }
                    )
                )
                Divider().opacity(0.25).padding(.leading, 44)
                settingsToggle(
                    label: "Overdue alerts",
                    subtitle: "Warn when chores are missed",
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .red,
                    binding: Binding(
                        get: { appState.preferences.overdueAlerts },
                        set: { appState.preferences.overdueAlerts = $0; save() }
                    )
                )
                Divider().opacity(0.25).padding(.leading, 44)
                settingsToggle(
                    label: "Streak reminders",
                    subtitle: "Keep your streak alive",
                    icon: "flame.fill",
                    iconColor: CozyTheme.accent,
                    binding: Binding(
                        get: { appState.preferences.streakReminders },
                        set: { appState.preferences.streakReminders = $0; save() }
                    )
                )
            }
        }
    }

    // MARK: - Calendar / Week Prefs
    private var calendarSection: some View {
        SettingsCard(title: "Calendar", icon: "calendar") {
            HStack(spacing: 12) {
                iconCircle("calendar.badge.clock", color: CozyTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Week starts on")
                        .font(.system(size: 15))
                        .foregroundColor(CozyTheme.primary)
                    Text("Affects calendar and weekly stats")
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                }
                Spacer()
                Picker("", selection: Binding(
                    get: { appState.preferences.weekStartsOnSunday },
                    set: { appState.preferences.weekStartsOnSunday = $0; save() }
                )) {
                    Text("Sun").tag(true)
                    Text("Mon").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
            .padding(.vertical, 12)
        }
    }

    // MARK: - Household Info
    private var householdSection: some View {
        SettingsCard(title: "Home", icon: "house.fill") {
            settingsRow(icon: "house.fill", iconColor: CozyTheme.accent,
                        label: "Home name",
                        trailing: Text(appState.profile?.homeName ?? "My Home")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(CozyTheme.mutedText))
        }
    }

    // MARK: - About
    private var aboutSection: some View {
        SettingsCard(title: "About", icon: "info.circle.fill") {
            VStack(spacing: 0) {
                settingsRow(icon: "app.badge.fill", iconColor: CozyTheme.accent,
                            label: "Version",
                            trailing: Text(appVersion).font(.system(size: 14)).foregroundColor(CozyTheme.mutedText))
                Divider().opacity(0.25).padding(.leading, 44)
                settingsRow(icon: "heart.fill", iconColor: .red,
                            label: "Made with love",
                            trailing: Text("🏡").font(.system(size: 16)))
            }
        }
    }

    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(spacing: 10) {
            #if targetEnvironment(simulator)
            devResetSection
            #endif

            Button { showDeleteConfirm = true } label: {
                Text("Delete Account")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.red.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    #if targetEnvironment(simulator)
    private var devResetSection: some View {
        SettingsCard(title: "Developer", icon: "wrench.and.screwdriver.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Only visible in Simulator builds")
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(.top, 8)
                Button {
                    appState.devResetAll()
                    appRouter.navigate(to: .onboardingName)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Restart Onboarding")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(CozyTheme.cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
    }
    #endif

    // MARK: - Helpers
    private func save() {
        requestNotifPermIfNeeded()
        Task { appState.savePreferences() }
    }

    private func requestNotifPermIfNeeded() {
        let p = appState.preferences
        guard p.dailyReminders || p.overdueAlerts || p.streakReminders else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func settingsToggle(label: String, subtitle: String, icon: String, iconColor: Color, binding: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            iconCircle(icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(CozyTheme.primary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(CozyTheme.accent)
        }
        .padding(.vertical, 10)
    }

    private func settingsRow<T: View>(icon: String, iconColor: Color, label: String, trailing: T) -> some View {
        HStack(spacing: 12) {
            iconCircle(icon, color: iconColor)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            trailing
        }
        .padding(.vertical, 12)
    }

    private func iconCircle(_ icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.14))
                .frame(width: 32, height: 32)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - SettingsCard
struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.accent)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            Divider().opacity(0.25)
            content()
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
        }
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        .shadow(color: CozyTheme.primary.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
