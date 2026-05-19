import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showAllHistory = false
    @State private var showBadgeToast = false
    @State private var showInsights = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    Divider().background(CozyTheme.border).opacity(0.5)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            profileBlock
                            statsRow
                            quickActionsRow
                            notifSection
                            prefsSection
                            badgesSection
                            historySection
                            signOutBtn
                        }
                        .padding(.horizontal, CozyTheme.padding)
                        .padding(.top, 14)
                        .padding(.bottom, 50)
                    }
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
        .onChange(of: appState.newlyEarnedBadge) { _, newValue in
            if newValue != nil { withAnimation(.spring()) { showBadgeToast = true } }
        }
    }

    // MARK: - Page header (matches Calendar / Home / Chores)
    private var header: some View {
        HStack(spacing: 12) {
            Text("Profile")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Profile identity block
    private var profileBlock: some View {
        VStack(spacing: 12) {
            avatarCircle
            if isEditingName {
                nameEditRow
            } else {
                VStack(spacing: 4) {
                    Text(appState.profile?.displayName ?? "You")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(CozyTheme.primary)
                    if let joined = appState.profile?.joinedAt {
                        Text("Joined \(formattedJoin(joined))")
                            .font(.system(size: 12))
                            .foregroundColor(CozyTheme.mutedText)
                    }
                }
            }
            editButton
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(CozyTheme.accent)
                .frame(width: 80, height: 80)
            Text(String(appState.profile?.displayName.prefix(1) ?? "?").uppercased())
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    private var editButton: some View {
        Button {
            editedName = appState.profile?.displayName ?? ""
            withAnimation(.easeInOut(duration: 0.2)) { isEditingName.toggle() }
        } label: {
            Text(isEditingName ? "Cancel" : "Edit name")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(CozyTheme.border.opacity(0.5))
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    private var nameEditRow: some View {
        HStack(spacing: 10) {
            TextField("Your name", text: $editedName)
                .font(.system(size: 17, weight: .medium))
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
                    .font(.system(size: 28))
                    .foregroundColor(CozyTheme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(appState.totalDone)", label: "Total done", icon: "checkmark.seal.fill", color: CozyTheme.teal)
            StatCard(value: "\(appState.currentStreak)", label: "Day streak", icon: "flame.fill", color: CozyTheme.accent)
        }
    }

    // MARK: - Quick actions
    private var quickActionsRow: some View {
        HStack(spacing: 10) {
            quickActionBtn(icon: "chart.bar.fill", label: "Insights") { showInsights = true }
            quickActionBtn(icon: "gearshape.fill", label: "Settings") { showSettings = true }
        }
    }

    private func quickActionBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CozyTheme.accent.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(CozyTheme.accent)
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
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
                    .onChange(of: appState.preferences.weekStartsOnSunday) { _, _ in
                        appState.savePreferences()
                    }
                }
                .padding(.vertical, 10)
            }
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
        PSection(title: "Recent chores", icon: "clock.arrow.circlepath") {
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

    private var signOutBtn: some View {
        Button { showSettings = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                Text("More settings")
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
            Image(systemName: "rosette")
                .font(.system(size: 26))
                .foregroundColor(CozyTheme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Badge earned")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(CozyTheme.accent)
                Text(badge.name)
                    .font(.system(size: 15, weight: .semibold))
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
        .shadow(color: .black.opacity(0.12), radius: 14, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { onDismiss() }
        }
    }
}
