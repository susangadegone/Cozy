import Foundation
import Supabase

// MARK: - Partial update structs (only fields we update, all snake_case)

private struct ProfileCoreUpdate: Encodable {
    var display_name: String
    var household_type: String
    var members: [HouseholdMemberPayload]
    var rooms: [String]
    var notification_preference: String
    var onboarding_completed: Bool
    var avatar_emoji: String?
    var earned_badge_ids: [String]?
    var preferences: UserPreferences?
}

private struct HouseholdMemberPayload: Encodable {
    var name: String
    var emoji: String
    var role: String?
}

private struct MembersUpdate: Encodable {
    var members: [HouseholdMemberPayload]
}

private struct AvatarUpdate: Encodable {
    var avatar_emoji: String
}

private struct DisplayNameUpdate: Encodable {
    var display_name: String
}

// MARK: - DataService

@MainActor
final class DataService: ObservableObject {
    static let shared = DataService()
    private let client = SupabaseConfig.client

    // MARK: - Profile
    func fetchProfile(userId: UUID) async throws -> Profile? {
        let response: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value
        return response.first
    }

    func updateProfile(_ profile: Profile) async throws {
        let memberPayloads = profile.members.map {
            HouseholdMemberPayload(name: $0.name, emoji: $0.emoji, role: $0.role)
        }
        let payload = ProfileCoreUpdate(
            display_name: profile.displayName,
            household_type: profile.householdType,
            members: memberPayloads,
            rooms: profile.rooms,
            notification_preference: profile.notificationPreference,
            onboarding_completed: profile.onboardingCompleted,
            avatar_emoji: profile.avatarEmoji,
            earned_badge_ids: profile.earnedBadgeIds,
            preferences: profile.preferences
        )
        try await client
            .from("profiles")
            .update(payload)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }

    /// Targeted update for just the members array (avoids touching other fields)
    func updateMembers(profileId: UUID, members: [HouseholdMember]) async throws {
        let payloads = members.map {
            HouseholdMemberPayload(name: $0.name, emoji: $0.emoji, role: $0.role)
        }
        let update = MembersUpdate(members: payloads)
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: profileId.uuidString)
            .execute()
    }

    /// Targeted update for avatar emoji only
    func updateAvatarEmoji(profileId: UUID, emoji: String) async throws {
        // Use a plain dictionary to guarantee correct JSON encoding for Supabase PATCH
        let update: [String: String] = ["avatar_emoji": emoji]
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: profileId.uuidString)
            .execute()
    }

    /// Targeted update for display name only
    func updateDisplayName(profileId: UUID, name: String) async throws {
        let update = DisplayNameUpdate(display_name: name)
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: profileId.uuidString)
            .execute()
    }

    // MARK: - Chores
    func fetchChores(userId: UUID) async throws -> [Chore] {
        let response: [Chore] = try await client
            .from("chores")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        return response
    }

    func addChore(_ chore: Chore) async throws {
        try await client
            .from("chores")
            .insert(chore)
            .execute()
    }

    func updateChore(_ chore: Chore) async throws {
        try await client
            .from("chores")
            .update(chore)
            .eq("id", value: chore.id.uuidString)
            .execute()
    }

    func deleteChore(id: UUID) async throws {
        try await client
            .from("chores")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
