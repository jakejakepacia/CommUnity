import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var currentUser: User?
    @Published var authErrorMessage: String?

    var onUserChanged: ((User?) -> Void)?
    var onProfileRenamed: ((String, String) -> Void)?

    private let authService: AuthServicing
    private let userService: UserServicing
    private let previewMode: Bool

    init(
        authService: AuthServicing = FirebaseAuthService(),
        userService: UserServicing = FirebaseUserService(),
        previewMode: Bool = false
    ) {
        self.authService = authService
        self.userService = userService
        self.previewMode = previewMode

        if previewMode {
            currentUser = MockData.currentUser
        }
    }

    func bootstrap() async {
        if previewMode {
            onUserChanged?(currentUser)
            return
        }

        await loadCurrentUser()
    }

    func loadCurrentUser() async {
        guard let userID = authService.currentUserID else {
            currentUser = nil
            onUserChanged?(nil)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await userService.fetchUser(userID: userID)
            currentUser = user
            authErrorMessage = nil
            onUserChanged?(user)
        } catch {
            authErrorMessage = "We couldn't load your account right now."
            currentUser = nil
            onUserChanged?(nil)
        }
    }

    func signUp(email: String, password: String) {
        Task {
            await signUpAsync(email: email, password: password)
        }
    }

    func login(email: String, password: String) {
        Task {
            await loginAsync(email: email, password: password)
        }
    }

    func logout() {
        do {
            try authService.signOut()
            currentUser = nil
            authErrorMessage = nil
            onUserChanged?(nil)
        } catch {
            authErrorMessage = "We couldn't sign you out right now."
        }
    }

    func updateProfile(firstName: String, lastName: String, email: String) {
        guard var user = currentUser else { return }

        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedFirstName.isEmpty else {
            authErrorMessage = "First name can't be empty."
            return
        }

        let previousOwnerName = user.fullName.isEmpty ? user.firstName : user.fullName
        user.firstName = trimmedFirstName
        user.lastName = trimmedLastName
        user.email = trimmedEmail
        let updatedOwnerName = user.fullName.isEmpty ? user.firstName : user.fullName
        currentUser = user
        authErrorMessage = nil
        onUserChanged?(user)
        onProfileRenamed?(previousOwnerName, updatedOwnerName)

        Task {
            do {
                try await userService.updateUser(user)
            } catch {
                await MainActor.run {
                    self.authErrorMessage = "Profile saved locally, but syncing failed."
                }
            }
        }
    }

    private func signUpAsync(email: String, password: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            authErrorMessage = "Enter your email and password to continue."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await authService.signUp(email: trimmedEmail, password: password)
            let user = User(
                id: session.userID,
                firstName: session.displayName ?? "Neighbor",
                lastName: "",
                email: session.email ?? trimmedEmail,
                photoSystemName: "person.crop.circle.fill",
                location: "",
                isAdmin: false
            )

            try await userService.saveUser(user)

            currentUser = user
            authErrorMessage = nil
            onUserChanged?(user)
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    private func loginAsync(email: String, password: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            authErrorMessage = "Enter your email and password to continue."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await authService.signIn(email: trimmedEmail, password: password)
            let user = try await userService.fetchUser(userID: session.userID)

            currentUser = user
            authErrorMessage = nil
            onUserChanged?(user)
            isLoading = false 
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }
}

extension AuthViewModel {
    static let preview = AuthViewModel(
        authService: FirebaseAuthService(),
        userService: PreviewUserService(),
        previewMode: true
    )
}
