import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showAllHistory = false
    @State private var showBadgeToast = false
    @State private var showAvatarPicker = false

    private let avatarOptions = ["🧑","👩","👨","🧒","👧","👦","🧔","👩‍🦰","👩‍🦱","👩‍🦳","🧓","🧕",
                                  "😊","😎","🥰","🤗","😇","🐶","🐱","🐼","🦊","🦄","🌸","⭐"]

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                CozyTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection
                        statsRow
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
        .onChange(of: appState.newlyEarnedBadge) { badge in
            if badge != nil { withAnimation(.spring()) { showBadgeToast = true } }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 14) {
            avatarCircle.padding(.top, 20)
            if showAvatarPicker { avatarPickerRow }
            if isEditingName {
                nameEditRow
            } else {
                VStack(spacing: 5) {
                    Text(appState.profile?.displayName ?? "You")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CozyTheme.primary)
                    roleBadgeRow
                }
            }
            editButtons
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var avatarCircle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showAvatarPicker.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [CozyTheme.accent, CozyTheme.primary],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 86, height: 86)
                if let emoji = appState.profile?.avatarEmoji {
                    Text(emoji).font(.system(size: 42))
                } else {
                    Text(appState.profile?.initials ?? "??")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
                // camera badge
                Circle()
                    .fill(CozyTheme.accent)
                    .frame(width: 26, height: 26)
                    .overlay(Image(systemName: "pencil").font(.system(size: 11, weight: .semibold)).foregroundColor(.white))
                    .offset(x: 28, y: 28)
            }
        }
        .buttonStyle(.plain)
        .shadow(color: CozyTheme.accent.opacity(0.3), radius: 10, y: 4)
    }

    private var avatarPickerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(avatarOptions, id: \.self) { emoji in
                    let isSelected = appState.profile?.avatarEmoji == emoji
                    Button {
                        guard var p = appState.profile else { return }
                        p.avatarEmoji = emoji
                        appState.profile = p
                        Task { try? await DataService.shared.updateProfile(p) }
                        withAnimation { showAvatarPicker = false }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 46, height: 46)
                            .background(isSelected ? CozyTheme.accent.opacity(0.2) : CozyTheme.card)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: isSelected ? 2 : 1))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    private var editButtons: some View {
        HStack(spacing: 10) {
            Button {
                editedName = appState.profile?.displayName ?? ""
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditingName.toggle()
                    showAvatarPicker = false
                }
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
                Task {
                    await appState.updateProfileName(name)
                    withAnimation { isEditingName = false }
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(CozyTheme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    private var roleBadgeRow: some View {
        HStack(spacing: 8) {
            let admin = appState.profile?.isAdmin == true
            Label(admin ? "Admin" : "Member", systemImage: admin ? "crown.fill" : "person.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CozyTheme.accent)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(CozyTheme.accent.opacity(0.12))
                .cornerRadius(20)

            if let joined = appState.profile?.joinedAt {
                Text("Joined \(formattedJoin(joined))")
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
    }

    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(appState.totalDone)", label: "Total Done", icon: "checkmark.seal.fill", color: .green)
            StatCard(value: "\(appState.currentStreak)", label: "Day Streak", icon: "flame.fill", color: .orange)
            StatCard(value: "\(appState.profile?.members.count ?? 1)", label: "Members", icon: "house.fill", color: CozyTheme.accent)
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
                    .onChange(of: appState.preferences.weekStartsOnSunday) { _ in
                        Task { await appState.savePreferences() }
                    }
                }
                .padding(.vertical, 10)
                Divider().opacity(0.3)
                HStack {
                    Text("Theme")
                        .font(.system(size: 15))
                        .foregroundColor(CozyTheme.primary)
                    Spacer()
                    Text("Cozy 🏡")
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
        PSection(title: "Badges", icon: "rosette") {
            BadgeGridView().environmentObject(appState)
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

    // MARK: - Sign Out
    private var signOutBtn: some View {
        Button {
            Task { try? await authManager.signOut() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.red.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.07))
            .cornerRadius(CozyTheme.cornerRadius)
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
                Text("Badge Earned! 🎉")
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
