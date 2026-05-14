import Foundation

enum CommunityAccessPolicy: String, CaseIterable, Identifiable, Codable {
    case publicOpen = "Public"
    case privateInviteOnly = "Private: Invite Only"
    case privateApproval = "Private: Admin Approval"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .publicOpen:
            "Public"
        case .privateInviteOnly:
            "Invite Only"
        case .privateApproval:
            "Approval Required"
        }
    }
}

struct Community: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var description: String
    var coverSymbol: String
    var joinCode: String
    var ownerName: String
    var ownerId: String
    var accessPolicy: CommunityAccessPolicy
    var memberCount: Int{
        approvedMemberIds.count
    }
    var isJoined: Bool
    var pendingJoinRequests: [String]
    var concerns: [Concern]
    var stores: [CommunityStore]
    var marketplaceItems: [MarketplaceItem]
    var approvedMemberIds: [String]
}

extension Community {
    var isPrivate: Bool {
        accessPolicy != .publicOpen
    }

    var marketplaceEntries: [MarketplaceEntry] {
        let storeEntries = stores.map(MarketplaceEntry.store)
        let listingEntries = marketplaceItems.map(MarketplaceEntry.listing)
        return storeEntries + listingEntries
    }
}
