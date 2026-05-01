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

    func defaultProfile() -> Profile {
        Profile(
            id: UUID(),
            displayName: "You",
            householdType: "solo",
            members: [],
            rooms: Room.defaults.map(\.id),
            notificationPreference: "daily",
            onboardingCompleted: true,
            role: "admin",
            joinedAt: nil,
            earnedBadgeIds: [],
            preferences: UserPreferences(),
            inviteCode: nil,
            avatarEmoji: "🏠"
        )
    }
}
