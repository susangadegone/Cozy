import Foundation

/// Simple JSON-backed local persistence. Supabase-ready: swap this class later.
final class LocalStore {
    static let shared = LocalStore()
    private let choresKey = "local_chores_v1"
    private let profileKey = "local_profile_v1"

    // MARK: - Chores
    func loadChores() -> [Chore] {
        guard let data = UserDefaults.standard.data(forKey: choresKey),
              let chores = try? JSONDecoder().decode([Chore].self, from: data) else { return [] }
        return chores
    }

    func saveChores(_ chores: [Chore]) {
        if let data = try? JSONEncoder().encode(chores) {
            UserDefaults.standard.set(data, forKey: choresKey)
        }
    }

    // MARK: - Profile
    func loadProfile() -> Profile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(Profile.self, from: data) else { return nil }
        return profile
    }

    func saveProfile(_ profile: Profile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    /// New user default — onboardingCompleted is FALSE so onboarding shows
    func defaultProfile() -> Profile {
        Profile(
            id: UUID(),
            displayName: "You",
            avatarEmoji: "👤",
            homeName: "My Home",
            rooms: [],
            notificationPreference: "in_app",
            onboardingCompleted: false,
            joinedAt: nil,
            preferences: UserPreferences(),
            earnedBadgeIds: []
        )
    }

    // MARK: - Preset Seeding
    /// Seeds from the curated preset library with a smart scheduling strategy:
    /// - Day 0 (today): Always gets 2-3 chores (quick wins to start immediately)
    /// - Days 1-6: Distributes remaining chores evenly
    /// This ensures users can start cleaning their space TODAY, not tomorrow.
    func seedFromPresets(for roomIds: [String], userId: UUID) -> [Chore] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Collect all auto-add chores
        let autoChores: [(name: String, roomId: String)] = roomIds.flatMap { roomId in
            PresetChoreLibrary.defaults(for: roomId).map { ($0.name, roomId) }
        }

        guard !autoChores.isEmpty else { return [] }

        var result: [Chore] = []
        let totalChores = autoChores.count

        // PHASE 1: Seed TODAY (day 0) with 2-3 chores - prioritize quick wins
        let todayCount = min(3, totalChores)
        for i in 0..<todayCount {
            let pair = autoChores[i]
            result.append(makeChore(
                name: pair.name,
                roomId: pair.roomId,
                userId: userId,
                date: today,
                calendar: cal
            ))
        }

        // PHASE 2: Distribute remaining chores across days 1-6 (max 2 per day)
        if totalChores > todayCount {
            let remaining = Array(autoChores[todayCount...])
            let daysToSpread = min(6, remaining.count) // Use days 1-6
            let choresPerDay = max(1, remaining.count / daysToSpread)
            
            var choreIndex = 0
            for dayOffset in 1...daysToSpread {
                guard choreIndex < remaining.count else { break }
                
                // Add 1-2 chores per day
                let count = min(choresPerDay, remaining.count - choreIndex, 2)
                guard let date = cal.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                
                for _ in 0..<count {
                    guard choreIndex < remaining.count else { break }
                    let pair = remaining[choreIndex]
                    result.append(makeChore(
                        name: pair.name,
                        roomId: pair.roomId,
                        userId: userId,
                        date: date,
                        calendar: cal
                    ))
                    choreIndex += 1
                }
            }
        }

        return result
    }

    /// Helper to create a Chore from components
    private func makeChore(name: String, roomId: String, userId: UUID, date: Date, calendar: Calendar) -> Chore {
        Chore(
            id: UUID(),
            userId: userId,
            roomId: roomId,
            choreName: name,
            dayOfWeek: DateFormatters.dayOfWeek.string(from: date),
            isDone: false,
            scheduledDate: DateFormatters.yearMonthDay.string(from: date),
            completedAt: nil
        )
    }
}
