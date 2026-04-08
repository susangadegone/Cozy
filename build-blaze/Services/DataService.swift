import Foundation
import Supabase

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
        try await client
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
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
