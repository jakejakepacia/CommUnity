import Foundation

struct Announcement: Identifiable, Equatable, Codable {
    let id: UUID
    var communityId: String
    var title: String
    var description: String
    var date: Date
    var author: String
    var authorId: String
}
