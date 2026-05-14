import Foundation

enum ConcernStatus: String, CaseIterable, Identifiable, Codable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case resolved = "Resolved"

    var id: String { rawValue }
}

struct Concern: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var description: String
    var imageName: String?
    var status: ConcernStatus
    var reporter: String
    var date: Date
}
