import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var profile: Profile?
    @Published var chores: [Chore] = []
    @Published var selectedDate: Date = Date()
    @Published var needsOnboarding = false
    @Published var isLoadingData = false

    private let dataService = DataService.shared

    var selectedDateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: selectedDate)
    }

    var todayChores: [Chore] {
        chores.filter { $0.scheduledDate == selectedDateString }
    }

    var completedToday: Int {
        todayChores.filter(\.isDone).count
    }

    var totalToday: Int {
        todayChores.count
    }

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

    func toggleChore(_ chore: Chore) async {
        guard let index = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        chores[index].isDone.toggle()
        do {
            try await dataService.updateChore(chores[index])
        } catch {
            chores[index].isDone.toggle()
            NSLog("Error toggling chore: \(error)")
        }
    }

    func addChore(_ chore: Chore) async {
        do {
            try await dataService.addChore(chore)
            chores.append(chore)
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
        guard let index = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        chores[index].scheduledDate = fmt.string(from: date)
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "EEEE"
        chores[index].dayOfWeek = dayFmt.string(from: date)
        do {
            try await dataService.updateChore(chores[index])
        } catch {
            NSLog("Error rescheduling chore: \(error)")
        }
    }
}
