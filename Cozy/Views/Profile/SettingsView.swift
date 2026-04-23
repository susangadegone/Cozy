import SwiftUI
import UserNotifications

// MARK: - SettingsView
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
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
                Task { try? await authManager.signOut() }
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
                Divider().opacity(0.25).padding(.leading, 44)
                settingsToggle(
                    label: "Partner activity",
                    subtitle: "When your partner completes chores",
                    icon: "person.2.fill",
                    iconColor: Color(hex: "7B6EF6"),
                    binding: Binding(
                        get: { appState.preferences.partnerActivity },
                        set: { appState.preferences.partnerActivity = $0; save() }
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
        SettingsCard(title: "Household", icon: "house.fill") {
            VStack(spacing: 0) {
                settingsRow(icon: "person.2.fill", iconColor: CozyTheme.accent,
                            label: "Members",
                            trailing: Text("\(appState.profile?.members.count ?? 1)").font(.system(size: 14, weight: .semibold)).foregroundColor(CozyTheme.mutedText))
                Divider().opacity(0.25).padding(.leading, 44)
                settingsRow(icon: "crown.fill", iconColor: .orange,
                            label: "Your role",
                            trailing: Text(appState.profile?.isAdmin == true ? "Admin" : "Member").font(.system(size: 14, weight: .semibold)).foregroundColor(CozyTheme.mutedText))
                if let code = appState.profile?.inviteCode, !code.isEmpty {
                    Divider().opacity(0.25).padding(.leading, 44)
                    HStack(spacing: 12) {
                        iconCircle("link", color: Color(hex: "7B6EF6"))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Invite code")
                                .font(.system(size: 15))
                                .foregroundColor(CozyTheme.primary)
                            Text(code)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(CozyTheme.accent)
                                .tracking(3)
                        }
                        Spacer()
                        Button {
                            UIPasteboard.general.string = code
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(CozyTheme.mutedText)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 12)
                }
            }
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
            Button {
                Task { try? await authManager.signOut() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.07))
                .cornerRadius(CozyTheme.cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(Color.red.opacity(0.15), lineWidth: 1))
            }
            .buttonStyle(.plain)

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

    // MARK: - Helpers
    private func save() {
        requestNotifPermIfNeeded()
        Task { await appState.savePreferences() }
    }

    private func requestNotifPermIfNeeded() {
        let p = appState.preferences
        guard p.dailyReminders || p.overdueAlerts || p.streakReminders || p.partnerActivity else { return }
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
