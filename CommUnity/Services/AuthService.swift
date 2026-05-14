import Foundation
import FirebaseAuth

struct AuthSession {
    let userID: String
    let displayName: String?
    let email: String?
}

protocol AuthServicing {
    var currentUserID: String? { get }

    func signUp(email: String, password: String) async throws -> AuthSession
    func signIn(email: String, password: String) async throws -> AuthSession
    func signOut() throws
}

struct FirebaseAuthService: AuthServicing {
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = result.user
        return AuthSession(userID: user.uid, displayName: user.displayName, email: user.email)
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        return AuthSession(userID: user.uid, displayName: user.displayName, email: user.email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
