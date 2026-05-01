import Foundation
import Supabase

// MARK: - Partial update structs (snake_case keys match Supabase column names)

private struct HouseholdMemberPayload: Encodable {
    var name: String
    var emoji: String
    var role: String?
}

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

private struct MembersOnlyUpdate: Encodable {
    var members: [HouseholdMemberPayload]
}

private struct AvatarOnlyUpdate: Encodable {
    var avatar_emoji: String
}

private struct NameOnlyUpdate: Encodable {
    var display_name: String
}

private struct BadgesOnlyUpdate: Encodable {
    var earned_badge_ids: [String]
}

private struct PrefsOnlyUpdate: Encodable {
    var preferences: UserPreferences?
}

// MARK: - DataService

@MainActor
final class DataService: ObservableObject {
    static let shared = DataService()
    private let client = SupabaseConfig.client

    // MARK: - Profile
    func createProfile(userId: UUID, displayName: String) async throws {
        struct NewProfile: Encodable {
            var id: String
            var display_name: String
            var household_type: String
            var members: [String]
            var rooms: [String]
            var notification_preference: String
            var onboarding_completed: Bool
        }
        let payload = NewProfile(
            id: userId.uuidString,
            display_name: displayName,
            household_type: "solo",
            members: [],
            rooms: [],
            notification_preference: "daily",
            onboarding_completed: false
        )
        try await client
            .from("profiles")
            .upsert(payload)
            .execute()
    }

    func fetchProfile(userId: UUID) async throws -> Profile? {
        let response: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value
        return response.first
    }

    /// Full profile update — all fields sent as explicit snake_case keys
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

    /// Targeted update for just the members array
    func updateMembers(profileId: UUID, members: [HouseholdMember]) async throws {
        let payloads = members.map { HouseholdMemberPayload(name: $0.name, emoji: $0.emoji, role: $0.role) }
        let update = MembersOnlyUpdate(members: payloads)
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: profileId.uuidString)
            .execute()
    }

    /// Targeted update for avatar emoji only
    func updateAvatarEmoji(profileId: UUID, emoji: String) async throws {
        let update = AvatarOnlyUpdate(avatar_emoji: emoji)
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: profileId.uuidString)
            .execute()
    }

    /// Targeted update for display name only
    func updateDisplayName(profileId: UUID, name: String) async throws {
        let update = NameOnlyUpdate(display_name: name)
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: profileId.uuidString)
            .execute()
    }

    /// Targeted update for earned badges only
    func updateBadges(profileId: UUID, badgeIds: [String]) async throws {
        let update = BadgesOnlyUpdate(earned_badge_ids: badgeIds)
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
