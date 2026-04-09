import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var profile: Profile?
    @Published var chores: [Chore] = []
    @Published var selectedDate: Date = Date()
    @Published var needsOnboarding = false
    @Published var isLoadingData = false
    @Published var activityLog: [ActivityLog] = []

    private let dataService = DataService.shared

    // MARK: - Date helpers
    func dateString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    var selectedDateString: String { dateString(from: selectedDate) }

    var todayChores: [Chore] {
        chores.filter { $0.scheduledDate == selectedDateString }
    }
    var completedToday: Int { todayChores.filter(\.isDone).count }
    var totalToday: Int { todayChores.count }

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
            let day = chores.filter { $0.scheduledDate == ds }
            guard !day.isEmpty, day.allSatisfy(\.isDone) else { break }
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

    // MARK: - Load
    func loadData() async {
        guard let userId = AuthManager.shared.currentUserId else { return }
        isLoadingData = true
        do {
            profile = try await dataService.fetchProfile(userId: userId)
            chores = try await dataService.fetchChores(userId: userId)
            needsOnboarding = !(profile?.onboardingCompleted ?? false)
        } catch {
            NSLog("Error loading data: \(error)")
        }
        isLoadingData = false
    }

    // MARK: - Mutations
    func toggleChore(_ chore: Chore) async {
        guard let i = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        chores[i].isDone.toggle()
        let nowDone = chores[i].isDone
        if nowDone {
            logActivity(.choreDone, "✅ \(chore.choreName) marked done")
            let s = currentStreak
            if s > 0 && s % 7 == 0 { logActivity(.streakMilestone, "🔥 \(s)-day streak achieved!") }
        }
        do {
            try await dataService.updateChore(chores[i])
        } catch {
            chores[i].isDone.toggle()
            NSLog("Error toggling chore: \(error)")
        }
    }

    func addChore(_ chore: Chore) async {
        do {
            try await dataService.addChore(chore)
            chores.append(chore)
            logActivity(.choreAdded, "➕ \(chore.choreName) added")
        } catch {
            NSLog("Error adding chore: \(error)")
        }
    }

    func deleteChore(_ chore: Chore) async {
        chores.removeAll { $0.id == chore.id }
        do {
            try await dataService.deleteChore(id: chore.id)
        } catch {
            NSLog("Error deleting chore: \(error)")
        }
    }

    func rescheduleChore(_ chore: Chore, to date: Date) async {
        guard let i = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        chores[i].scheduledDate = fmt.string(from: date)
        let df = DateFormatter(); df.dateFormat = "EEEE"
        chores[i].dayOfWeek = df.string(from: date)
        do {
            try await dataService.updateChore(chores[i])
        } catch {
            NSLog("Error rescheduling chore: \(error)")
        }
    }

    // MARK: - Activity log
    func logActivity(_ type: ActivityLog.ActivityType, _ text: String) {
        let entry = ActivityLog(
            id: UUID(), type: type, text: text, timestamp: Date(),
            userId: AuthManager.shared.currentUserId?.uuidString ?? ""
        )
        activityLog.insert(entry, at: 0)
        if activityLog.count > 10 { activityLog = Array(activityLog.prefix(10)) }
    }
}
