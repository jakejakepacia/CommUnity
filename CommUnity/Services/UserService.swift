import Foundation
@preconcurrency import FirebaseFirestore

protocol UserServicing {
    func fetchUser(userID: String) async throws -> User
    func saveUser(_ user: User) async throws
    func updateUser(_ user: User) async throws
}

struct FirebaseUserService: UserServicing {
    private let db = Firestore.firestore()

    func fetchUser(userID: String) async throws -> User {
        let snapshot = try await db.collection(K.FStore.usersCollectionName)
            .whereField(K.FStore.idField, isEqualTo: userID)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(domain: "NoUserFound", code: 404)
        }

        let data = document.data()

        return User(
            id: userID,
            firstName: data[K.FStore.firstNameField] as? String ?? "",
            lastName: data[K.FStore.lastNameField] as? String ?? "",
            email: data[K.FStore.emailField] as? String ?? "",
            photoSystemName: data["photoSystemName"] as? String ?? "person.crop.circle.fill",
            location: data["location"] as? String ?? "",
            isAdmin: data["isAdmin"] as? Bool ?? false
        )
    }

    func saveUser(_ user: User) async throws {
        try db.collection(K.FStore.usersCollectionName).document(user.id).setData(from: user)
    }

    func updateUser(_ user: User) async throws {
        try await db.collection(K.FStore.usersCollectionName).document(user.id).updateData([
            K.FStore.emailField: user.email,
            K.FStore.firstNameField: user.firstName,
            K.FStore.lastNameField: user.lastName,
            "location": user.location,
            "photoSystemName": user.photoSystemName,
            "isAdmin": user.isAdmin
        ])
    }
}

struct PreviewUserService: UserServicing {
    func fetchUser(userID: String) async throws -> User {
        MockData.currentUser
    }

    func saveUser(_ user: User) async throws {}

    func updateUser(_ user: User) async throws {}
}
