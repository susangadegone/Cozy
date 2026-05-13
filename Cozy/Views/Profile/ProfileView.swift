import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showAllHistory = false
    @State private var showBadgeToast = false
    @State private var showAvatarPicker = false
    @State private var showInsights = false
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                CozyTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection
                        statsRow
                        quickActionsRow
                        notifSection
                        prefsSection
                        householdSection
                        badgesSection
                        historySection
                        signOutBtn
                    }
                    .padding(.horizontal, CozyTheme.padding)
                    .padding(.top, 8)
                    .padding(.bottom, 50)
                }
                if showBadgeToast, let badge = appState.newlyEarnedBadge {
                    BadgeToast(badge: badge) {
                        withAnimation { showBadgeToast = false }
                        appState.newlyEarnedBadge = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAllHistory) {
            ChoreHistoryView().environmentObject(appState)
        }
        .sheet(isPresented: $showInsights) {
            InsightsView().environmentObject(appState)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(appState).environmentObject(appRouter)
        }
        .onChange(of: appState.newlyEarnedBadge) { oldValue, newValue in
            if newValue != nil { withAnimation(.spring()) { showBadgeToast = true } }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 14) {
            avatarCircle.padding(.top, 20)
            if isEditingName {
                nameEditRow
            } else {
                VStack(spacing: 5) {
                    Text(appState.profile?.displayName ?? "You")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CozyTheme.primary)
                    if let joined = appState.profile?.joinedAt {
                        Text("Joined \(formattedJoin(joined))")
                            .font(.system(size: 12))
                            .foregroundColor(CozyTheme.mutedText)
                    }
                }
            }
            editButtons
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(CozyTheme.primary)
                .frame(width: 86, height: 86)
            Text(String(appState.profile?.displayName.prefix(1) ?? "?").uppercased())
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color(hex: "FAF7F2"))
        }
        .shadow(color: CozyTheme.primary.opacity(0.2), radius: 10, y: 4)
    }

    private var editButtons: some View {
        HStack(spacing: 10) {
            Button {
                editedName = appState.profile?.displayName ?? ""
                withAnimation(.easeInOut(duration: 0.2)) { isEditingName.toggle() }
            } label: {
                Label(isEditingName ? "Cancel" : "Edit Name",
                      systemImage: isEditingName ? "xmark" : "pencil")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(CozyTheme.border.opacity(0.6))
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
        }
    }

    private var nameEditRow: some View {
        HStack(spacing: 10) {
            TextField("Your name", text: $editedName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(CozyTheme.card)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
            Button {
                let name = editedName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                appState.updateProfileName(name)
                withAnimation { isEditingName = false }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(CozyTheme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Quick Actions (2 tiles)
    private var quickActionsRow: some View {
        HStack(spacing: 10) {
            quickActionBtn(icon: "chart.bar.fill", label: "Insights", color: Color(hex: "7B6EF6")) {
                showInsights = true
            }
            quickActionBtn(icon: "gearshape.fill", label: "Settings", color: CozyTheme.primary) {
                showSettings = true
            }
        }
    }

    private func quickActionBtn(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats (2 cards)
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(appState.totalDone)", label: "Total Done", icon: "checkmark.seal.fill", color: .green)
            StatCard(value: "\(appState.currentStreak)", label: "Day Streak", icon: "flame.fill", color: .orange)
        }
    }

    // MARK: - Sections
    private var notifSection: some View {
        PSection(title: "Notifications", icon: "bell.fill") {
            NotificationPrefsView().environmentObject(appState)
        }
    }

    private var prefsSection: some View {
        PSection(title: "Preferences", icon: "slider.horizontal.3") {
            VStack(spacing: 0) {
                HStack {
                    Text("Week starts on")
                        .font(.system(size: 15))
                        .foregroundColor(CozyTheme.primary)
                    Spacer()
                    Picker("", selection: $appState.preferences.weekStartsOnSunday) {
                        Text("Sunday").tag(true)
                        Text("Monday").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    .onChange(of: appState.preferences.weekStartsOnSunday) { oldValue, newValue in
                        appState.savePreferences()
                    }
                }
                .padding(.vertical, 10)
                Divider().opacity(0.3)
                HStack {
                    Text("Theme")
                        .font(.system(size: 15))
                        .foregroundColor(CozyTheme.primary)
                    Spacer()
                    Text("Cozy")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(CozyTheme.accent)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(CozyTheme.accent.opacity(0.1))
                        .cornerRadius(20)
                }
                .padding(.vertical, 10)
            }
        }
    }

    private var householdSection: some View {
        PSection(title: "Household", icon: "house.fill") {
            HouseholdPanelView().environmentObject(appState)
        }
    }

    private var badgesSection: some View {
        VStack(spacing: 14) {
            NextBadgeCard().environmentObject(appState)
            PSection(title: "Badges", icon: "rosette") {
                BadgeGridView().environmentObject(appState)
            }
        }
    }

    private var historySection: some View {
        PSection(title: "Recent Chores", icon: "clock.arrow.circlepath") {
            VStack(spacing: 0) {
                let history = Array(appState.choreHistory.prefix(5))
                if history.isEmpty {
                    Text("No completed chores yet")
                        .font(.system(size: 14))
                        .foregroundColor(CozyTheme.mutedText)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(Array(history.enumerated()), id: \.element.id) { idx, chore in
                        HistoryRow(chore: chore)
                        if idx < history.count - 1 {
                            Divider().opacity(0.3).padding(.leading, 52)
                        }
                    }
                    if appState.choreHistory.count > 5 {
                        Button { showAllHistory = true } label: {
                            HStack(spacing: 4) {
                                Text("View all \(appState.choreHistory.count) completed")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(CozyTheme.accent)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundColor(CozyTheme.accent)
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Sign Out / Settings
    private var signOutBtn: some View {
        Button { showSettings = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                Text("More Settings")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(CozyTheme.mutedText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func formattedJoin(_ raw: String) -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        if let d = df.date(from: raw) {
            let out = DateFormatter(); out.dateFormat = "MMM yyyy"
            return out.string(from: d)
        }
        return raw
    }
}

// MARK: - StatCard
struct StatCard: View {
    let value: String; let label: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            Text(value).font(.system(size: 22, weight: .bold)).foregroundColor(CozyTheme.primary)
            Text(label).font(.system(size: 11)).foregroundColor(CozyTheme.mutedText).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
    }
}

// MARK: - PSection (Profile Section Card)
struct PSection<Content: View>: View {
    let title: String; let icon: String
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
            .padding(.horizontal, CozyTheme.padding)
            .padding(.vertical, 12)
            Divider().opacity(0.3)
            content()
                .padding(.horizontal, CozyTheme.padding)
                .padding(.bottom, 10)
        }
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius).stroke(CozyTheme.border, lineWidth: 1))
    }
}

// MARK: - BadgeToast
struct BadgeToast: View {
    let badge: BadgeDefinition
    let onDismiss: () -> Void
    var body: some View {
        HStack(spacing: 14) {
            Text(badge.icon).font(.system(size: 30))
            VStack(alignment: .leading, spacing: 2) {
                Text("Badge Earned!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(CozyTheme.accent)
                Text(badge.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                Text(badge.description)
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.mutedText)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(CozyTheme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.14), radius: 14, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { onDismiss() }
        }
    }
}
