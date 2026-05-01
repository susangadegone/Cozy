import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var profile: Profile?
    @Published var chores: [Chore] = []
    @Published var selectedDate: Date = Date()
    @Published var isLoadingData = false
    @Published var activityLog: [ActivityLog] = []
    @Published var newlyEarnedBadge: BadgeDefinition?
    @Published var preferences: UserPreferences = UserPreferences()
    @Published var pendingConfettiEvent: ConfettiEvent? = nil

    private let store = LocalStore.shared
    private let prefsKey = "userPreferences_v1"

    init() {
        loadLocalPreferences()
        loadData()
    }

    // MARK: - Date helpers
    func dateString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    var todayString: String { dateString(from: Date()) }
    var selectedDateString: String { dateString(from: selectedDate) }

    /// Always shows today's chores regardless of selected calendar date
    var todayChores: [Chore] {
        chores.filter { $0.scheduledDate == todayString }
    }
    var completedToday: Int { todayChores.filter(\.isDone).count }
    var totalToday: Int { todayChores.count }

    /// Chores for the currently selected calendar date
    var selectedDateChores: [Chore] {
        chores.filter { $0.scheduledDate == selectedDateString }
    }

    // MARK: - Week stats
    var weekChores: [Chore] {
        let cal = Calendar.current
        guard let interval = cal.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        let dates = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) }
        let strings = Set(dates.map { dateString(from: $0) })
        return chores.filter { strings.contains($0.scheduledDate) }
    }
    var weekDone: Int { weekChores.filter(\.isDone).count }
    var weekTotal: Int { weekChores.count }
    var weekRemaining: Int { weekTotal - weekDone }
    var weekProgress: Double { weekTotal > 0 ? Double(weekDone) / Double(weekTotal) : 0 }

    // MARK: - Streak
    var currentStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var check = cal.startOfDay(for: Date())
        while true {
            let ds = dateString(from: check)
            let hasAnyDone = chores.contains { $0.scheduledDate == ds && $0.isDone }
            guard hasAnyDone else { break }
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: check) else { break }
            check = prev
        }
        return streak
    }

    // MARK: - Household breakdown
    var memberBreakdown: [(name: String, emoji: String, done: Int, total: Int)] {
        guard let members = profile?.members else { return [] }
        return members.map { m in
            let mc = weekChores.filter { $0.assignedTo == m.name }
            return (m.name, m.emoji, mc.filter(\.isDone).count, mc.count)
        }
    }

    // MARK: - Chore history
    var choreHistory: [Chore] {
        chores.filter(\.isDone).sorted {
            let a = $0.completedAt ?? $0.scheduledDate
            let b = $1.completedAt ?? $1.scheduledDate
            return a > b
        }
    }

    var totalDone: Int { chores.filter(\.isDone).count }

    // MARK: - Load (local)
    func loadData() {
        isLoadingData = true
        let loaded = store.loadProfile()
        if loaded == nil {
            // Brand new user — create default profile (onboardingCompleted = false)
            let fresh = store.defaultProfile()
            store.saveProfile(fresh)
            profile = fresh
        } else {
            profile = loaded
        }
        chores = store.loadChores()
        if let p = profile?.preferences { preferences = p }
        isLoadingData = false
    }

    /// Called by OnboardingView finale — saves profile + seeds chores
    func completeOnboarding(name: String, householdType: String, members: [HouseholdMember],
                            rooms: [String], notificationPref: String) {
        guard var p = profile else { return }
        p.displayName = name
        p.householdType = householdType
        p.members = members
        p.rooms = rooms
        p.notificationPreference = notificationPref
        p.onboardingCompleted = true
        profile = p
        store.saveProfile(p)

        // Seed preset chores for selected rooms
        chores = store.seedChoresIfNeeded(for: rooms, userId: p.id)

        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }

    // MARK: - Mutations
    func toggleChore(_ chore: Chore) {
        guard let i = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        chores[i].isDone.toggle()
        let nowDone = chores[i].isDone
        if nowDone {
            let fmt = ISO8601DateFormatter()
            chores[i].completedAt = fmt.string(from: Date())
            logActivity(.choreDone, "\(chore.choreName) marked done")
            let s = currentStreak
            if s > 0 && s % 7 == 0 { logActivity(.streakMilestone, "\(s)-day streak!") }
            pendingConfettiEvent = .choreDone
            checkBadges()
        } else {
            chores[i].completedAt = nil
        }
        store.saveChores(chores)
    }

    func addChore(_ chore: Chore) {
        chores.append(chore)
        logActivity(.choreAdded, "\(chore.choreName) added")
        pendingConfettiEvent = .choreAdded
        store.saveChores(chores)
    }

    func deleteChore(_ chore: Chore) {
        chores.removeAll { $0.id == chore.id }
        store.saveChores(chores)
    }

    func rescheduleChore(_ chore: Chore, to date: Date) {
        guard let i = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        chores[i].scheduledDate = fmt.string(from: date)
        let df = DateFormatter(); df.dateFormat = "EEEE"
        chores[i].dayOfWeek = df.string(from: date)
        store.saveChores(chores)
    }

    func updateProfileName(_ name: String) {
        guard var p = profile else { return }
        p.displayName = name
        profile = p
        store.saveProfile(p)
    }

    func updateAvatarEmoji(_ emoji: String) {
        guard var p = profile else { return }
        p.avatarEmoji = emoji
        profile = p
        store.saveProfile(p)
    }

    func addHouseholdMember(_ member: HouseholdMember) {
        guard var p = profile else { return }
        guard !p.members.contains(where: { $0.name.lowercased() == member.name.lowercased() }) else { return }
        p.members.append(member)
        profile = p
        store.saveProfile(p)
    }

    func removeMember(_ member: HouseholdMember) {
        guard var p = profile else { return }
        p.members.removeAll { $0.name == member.name }
        profile = p
        store.saveProfile(p)
    }

    func refreshProfile() {
        profile = store.loadProfile() ?? profile
    }

    func savePreferences() {
        saveLocalPreferences()
        guard var p = profile else { return }
        p.preferences = preferences
        profile = p
        store.saveProfile(p)
    }

    // MARK: - Badge Check
    func checkBadges() {
        guard let p = profile else { return }
        let newBadges = BadgeService.evaluateNewlyEarned(profile: p, chores: chores, streak: currentStreak)
        guard !newBadges.isEmpty else { return }
        var updated = p
        var ids = updated.earnedBadgeIds ?? []
        newBadges.forEach { ids.append($0.id) }
        updated.earnedBadgeIds = ids
        profile = updated
        newlyEarnedBadge = newBadges.first
        pendingConfettiEvent = .badgeUnlock
        logActivity(.badgeEarned, "\(newBadges.first!.name) earned!")
        store.saveProfile(updated)
    }

    // MARK: - Local Preferences
    private func saveLocalPreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: prefsKey)
        }
    }
    private func loadLocalPreferences() {
        guard let data = UserDefaults.standard.data(forKey: prefsKey),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else { return }
        preferences = prefs
    }

    // MARK: - Activity log
    func logActivity(_ type: ActivityLog.ActivityType, _ text: String) {
        let entry = ActivityLog(id: UUID(), type: type, text: text, timestamp: Date(), userId: "local")
        activityLog.insert(entry, at: 0)
        if activityLog.count > 20 { activityLog = Array(activityLog.prefix(20)) }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("cozy.onboardingCompleted")
}
