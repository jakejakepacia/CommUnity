import Foundation

enum MockData {
    static let currentUser = User(
        id: UUID().uuidString,
        firstName: "Mia",
        lastName: "Santos",
        email: "",
        photoSystemName: "person.crop.circle.fill",
        location: "Quezon City",
        isAdmin: true
    )

    static let communities: [Community] = [ ]
}
