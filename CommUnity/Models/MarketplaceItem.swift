import Foundation

struct MarketplaceItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var price: Double
    var description: String
    var imageName: String
    var seller: String
    var postedDate: Date
}

struct CommunityStore: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var tagline: String
    var description: String
    var imageName: String
    var ownerName: String
    var category: String
    var locationDetail: String
    var featuredItems: [String]
    var startingPrice: Double?
    var postedDate: Date
}

enum MarketplaceEntry: Identifiable, Equatable {
    case listing(MarketplaceItem)
    case store(CommunityStore)

    var id: UUID {
        switch self {
        case .listing(let item):
            item.id
        case .store(let store):
            store.id
        }
    }
}
