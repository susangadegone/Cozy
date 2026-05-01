import Foundation

/// Stub — replaced by LocalStore. Re-wire to Supabase when ready.
final class DataService {
    static let shared = DataService()

    func fetchProfile(userId: UUID) async throws -> Profile? { nil }
    func fetchChores(userId: UUID) async throws -> [Chore] { [] }
    func addChore(_ chore: Chore) async throws {}
    func updateChore(_ chore: Chore) async throws {}
    func deleteChore(id: UUID) async throws {}
    func updateProfile(_ profile: Profile) async throws {}
    func createProfile(_ profile: Profile) async throws {}
    func updateDisplayName(profileId: UUID, name: String) async throws {}
    func updateAvatarEmoji(profileId: UUID, emoji: String) async throws {}
    func updateMembers(profileId: UUID, members: [HouseholdMember]) async throws {}
    func updateBadges(profileId: UUID, badgeIds: [String]) async throws {}
}
