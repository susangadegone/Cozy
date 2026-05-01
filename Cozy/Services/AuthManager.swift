import Foundation

/// Stub — replaced by local storage. Re-wire to Supabase when ready.
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var isAuthenticated: Bool = false
    var currentUserId: UUID? { nil }
    func checkSession() async {}
    func signUp(email: String, password: String) async throws {}
    func signIn(email: String, password: String) async throws {}
    func signOut() async throws {}
    func sendMagicLink(email: String) async throws {}
}
