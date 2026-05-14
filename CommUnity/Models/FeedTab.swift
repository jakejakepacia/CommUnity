import Foundation

enum FeedTab: String, CaseIterable, Identifiable {
    case announcements = "Announcements"
    case concerns = "Concerns"
    case marketplace = "Marketplace"

    var id: String { rawValue }
}

enum CreateMode: String, CaseIterable, Identifiable {
    case announcement = "Announcement"
    case concern = "Concern"
    case listing = "Listing"
    case store = "Store"
    case community = "Community"

    var id: String { rawValue }
}
