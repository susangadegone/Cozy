import Foundation

/// Local-mode auth — stores a guest UUID in UserDefaults.
/// Swap signUp/signIn bodies for Supabase calls when ready.
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private let key = "cozy_guest_user_id"

    @Published var isAuthenticated: Bool = false
    private(set) var currentUserId: UUID?

    init() {
        if let saved = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: saved) {
            currentUserId = uuid
            isAuthenticated = true
        }
    }

    func checkSession() async {
        isAuthenticated = currentUserId != nil
    }

    func signUp(email: String, password: String) async throws {
        let id = UUID()
        UserDefaults.standard.set(id.uuidString, forKey: key)
        currentUserId = id
        isAuthenticated = true
    }

    func signIn(email: String, password: String) async throws {
        if currentUserId == nil {
            let id = UUID()
            UserDefaults.standard.set(id.uuidString, forKey: key)
            currentUserId = id
        }
        isAuthenticated = true
    }

    func signOut() async throws {
        UserDefaults.standard.removeObject(forKey: key)
        currentUserId = nil
        isAuthenticated = false
    }

    func sendMagicLink(email: String) async throws {}
}
