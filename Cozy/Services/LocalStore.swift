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
            homeName: "My Home",
            rooms: [],
            notificationPreference: "in_app",
            onboardingCompleted: false,
            joinedAt: nil,
            earnedBadgeIds: [],
            preferences: UserPreferences(),
            avatarEmoji: nil
        )
    }

    // MARK: - Chore Seeding
    /// Seeds preset chores across the next 7 days for the given rooms. Skips if chores already exist.
    func seedChoresIfNeeded(for rooms: [String], userId: UUID) -> [Chore] {
        let existing = loadChores()
        guard existing.isEmpty else { return existing }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let dowFmt = DateFormatter(); dowFmt.dateFormat = "EEEE"

        let dayOffsets: [Int] = [0, 1, 2, 3, 4, 5, 6]
        var offset = 0
        var seeded: [Chore] = []

        for roomId in rooms {
            let allNames = Room.defaultChores[roomId] ?? []
            let picks = Array(allNames.prefix(3))
            for (i, name) in picks.enumerated() {
                let dayOff = dayOffsets[(offset + i) % dayOffsets.count]
                guard let date = cal.date(byAdding: .day, value: dayOff, to: today) else { continue }
                let chore = Chore(
                    id: UUID(),
                    userId: userId,
                    roomId: roomId,
                    choreName: name,
                    dayOfWeek: dowFmt.string(from: date),
                    isDone: false,
                    scheduledDate: fmt.string(from: date),
                    completedAt: nil
                )
                seeded.append(chore)
            }
            offset += 3
        }

        saveChores(seeded)
        return seeded
    }

    // MARK: - Preset Seeding
    /// Seeds from the curated preset library. Spreads first occurrences across days 1–8.
    /// Caller is responsible for persisting via saveChores().
    func seedFromPresets(for roomIds: [String], userId: UUID) -> [Chore] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let dowFmt = DateFormatter(); dowFmt.dateFormat = "EEEE"

        // Collect all auto-add chores in room order
        let autoChores: [(name: String, roomId: String)] = roomIds.flatMap { roomId in
            PresetChoreLibrary.defaults(for: roomId).map { ($0.name, roomId) }
        }

        let total = autoChores.count
        guard total > 0 else { return [] }

        // Spread evenly across days 1–8 (max 1 per day)
        let maxDay = 8
        let spacing = max(1, maxDay / total)

        return autoChores.enumerated().map { (i, pair) in
            let dayOffset = 1 + (i * spacing)
            let date = cal.date(byAdding: .day, value: dayOffset, to: today) ?? today
            return Chore(
                id: UUID(),
                userId: userId,
                roomId: pair.roomId,
                choreName: pair.name,
                dayOfWeek: dowFmt.string(from: date),
                isDone: false,
                scheduledDate: fmt.string(from: date),
                completedAt: nil
            )
        }
    }
}
