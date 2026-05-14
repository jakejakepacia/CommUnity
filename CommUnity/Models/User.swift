import Foundation

struct User: Identifiable, Equatable, Codable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var photoSystemName: String
    var location: String
    var isAdmin: Bool
    var fullName : String {
        return "\(firstName) \(lastName)"
    }
}
