import Foundation
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUserId: UUID?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let client = SupabaseConfig.client

    private init() {
        Task { await checkSession() }
    }

    func checkSession() async {
        isLoading = true
        do {
            let session = try await client.auth.session
            currentUserId = session.user.id
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            currentUserId = nil
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async throws {
        let result = try await client.auth.signUp(email: email, password: password)
        currentUserId = result.user.id
        isAuthenticated = true
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        currentUserId = session.user.id
        isAuthenticated = true
    }

    func sendMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(email: email)
    }

    func signOut() async throws {
        try await client.auth.signOut()
        isAuthenticated = false
        currentUserId = nil
    }
}
