import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var communities: [Community] = []
    @Published var announcements: [Announcement] = []
    @Published var concerns: [Concern] = []
    @Published var selectedCommunityID: Community.ID?
    @Published var communityMessage: String?

    @Published var currentUser: User? {
        didSet {
            if currentUser == nil {
                selectedCommunityID = nil
            } else if selectedCommunityID == nil {
                selectedCommunityID = joinedCommunities.first?.id
            }
        }
    }

    private let communityService: CommunityServicing
    private let previewMode: Bool
    private var announcementsListener: ListenerRegistration?
    private var concernsListener: ListenerRegistration?

    init(
        communityService: CommunityServicing = FirebaseCommunityService(),
        previewMode: Bool = false
    ) {
        self.communityService = communityService
        self.previewMode = previewMode

        if previewMode {
            communities = MockData.communities
            selectedCommunityID = MockData.communities.first(where: \.isJoined)?.id
            currentUser = MockData.currentUser
        }
    }

    var joinedCommunities: [Community] {
        if let user = currentUser{
            return communities.filter { $0.approvedMemberIds.contains(user.id) }
        } else { return [] }
    }

    var discoverCommunities: [Community] {
        if let user = currentUser{
            return communities.filter { !$0.approvedMemberIds.contains(user.id) }
        } else { return [] }
    }

    var ownedCommunities: [Community] {
        guard let currentUser else { return [] }
        let ownedNames = [currentUser.firstName, currentUser.fullName]
        return communities.filter { ownedNames.contains($0.ownerName) }
    }

    var selectedCommunity: Community? {
        guard let selectedCommunityID else { return joinedCommunities.first }
        return communities.first(where: { $0.id == selectedCommunityID })
    }

    var currentUserDisplayName: String {
        currentUser?.firstName.components(separatedBy: " ").first ?? "Neighbor"
    }
    

    func bootstrap() async {
        if previewMode { return }
        await loadCommunities()
    }
    
    func observeListeners(by communityID: UUID) {

        stopObservingListeners()
        
        announcementsListener = communityService.listenToAnnouncements(
            communityId: communityID
        ) { [weak self] announcements in

            self?.announcements = announcements
        }
        
        concernsListener = communityService.listenToConcerns(
            communityId: communityID
        ) { [weak self] concerns in

            self?.concerns = concerns
        }
    }
    
    func stopObservingListeners() {
        announcementsListener?.remove()
        announcementsListener = nil
        
        concernsListener?.remove()
        concernsListener = nil
    }
    
    

    deinit {
        announcementsListener?.remove()
    }

    func loadCommunities() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await communityService.fetchCommunities()
            communities = fetched.isEmpty ? MockData.communities : fetched
            if selectedCommunityID == nil {
                selectedCommunityID = joinedCommunities.first?.id
            }
        } catch {
            communities = MockData.communities
            if selectedCommunityID == nil {
                selectedCommunityID = joinedCommunities.first?.id
            }
        }
    }

    func loadAnnouncements(by communityID: UUID) async {
        do{
            let fetched = try await communityService.fetchAnnouncements(communityId: communityID)
            announcements = fetched.sorted {
                      $0.date > $1.date
                  }
        } catch {
            announcements = []
            print("Error loading announcements")
        }
      
    }
    
    func loadConcerns(by communityID: UUID) async{
        do{
            let fetched = try await communityService.fetchConcerns(communityId: communityID)
            concerns = fetched.sorted {
                $0.date > $1.date
            }
        } catch {
            concerns = []
            print("Error loading concerns")
        }
    }
    
    func selectCommunity(_ community: Community) {
        selectedCommunityID = community.id
    }

    func selectCommunityIfNeeded(_ communityID: Community.ID) {
        guard selectedCommunityID != communityID else { return }
        selectedCommunityID = communityID
    }

    func joinCommunity(code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let index = communities.firstIndex(where: { $0.joinCode == trimmed }), let user = currentUser else {
            communityMessage = "That invite code was not found."
            return
        }
        
        if !communities[index].isPrivate {
            communities[index].isJoined = true
            communities[index].approvedMemberIds.append(user.id)
            
            Task{
                try await communityService.joinPublicCommnuty(communityId: communities[index].id, user)
            }
        }else{
            communities[index].pendingJoinRequests.append(user.id)
            communityMessage = communities[index].isPrivate
                ? "Invite accepted. You joined \(communities[index].name)."
                : nil
        }

     
       
        
    }

    func requestToJoin(_ community: Community) {
        guard let currentUser,
              let index = communities.firstIndex(where: { $0.id == community.id }) else { return }

        let requesterName = currentUser.firstName
        guard !communities[index].pendingJoinRequests.contains(requesterName) else {
            communityMessage = "Your request is already waiting for admin approval."
            return
        }

        communities[index].pendingJoinRequests.append(requesterName)
        communityMessage = "Join request sent to \(communities[index].ownerName)."
    }

    func approveJoinRequest(for community: Community, requesterName: String) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }

        communities[index].pendingJoinRequests.removeAll { $0 == requesterName }
        communityMessage = "\(requesterName) has been approved for \(communities[index].name)."
    }

    func createCommunity(
        name: String,
        description: String,
        isPrivate: Bool,
        requiresApproval: Bool
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, let currentUser else { return }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let accessPolicy: CommunityAccessPolicy

        if !isPrivate {
            accessPolicy = .publicOpen
        } else {
            accessPolicy = requiresApproval ? .privateApproval : .privateInviteOnly
        }

        let ownerName = currentUser.fullName.isEmpty ? currentUser.firstName : currentUser.fullName
        let community = Community(
            id: UUID(),
            name: trimmedName,
            description: trimmedDescription.isEmpty ? "A newly created local community." : trimmedDescription,
            coverSymbol: "person.3.sequence.fill",
            joinCode: String(trimmedName.prefix(4)).uppercased() + String(Int.random(in: 100...999)),
            ownerName: ownerName,
            ownerId: currentUser.id,
            accessPolicy: accessPolicy,
            isJoined: true,
            pendingJoinRequests: [],
            concerns: [],
            stores: [],
            marketplaceItems: [],
            approvedMemberIds: [currentUser.id]
        )

        communities.insert(community, at: 0)
        selectedCommunityID = community.id

        Task {
            try? await self.communityService.createCommunity(community)
        }
    }

    func addAnnouncement(title: String, description: String) {
        guard let communityIndex = selectedCommunityIndex,
              let currentUser else { return }

        let community = communities[communityIndex]
        
        let annoucemnt = Announcement(
            id: UUID(),
            communityId: community.id.uuidString,
            title: title,
            description: description,
            date: .now,
            author: currentUser.firstName,
            authorId: currentUser.id
        )
        
        
        announcements.append(annoucemnt)
        
        Task{
            try? await self.communityService.postAnnouncement(announcement: annoucemnt)
        }
    }

    func addConcern(title: String, description: String, imageName: String?) {
        guard let communityIndex = selectedCommunityIndex,
              let currentUser else { return }

        let concern =  Concern(
            id: UUID(),
            communityId: communities[communityIndex].id.uuidString,
            title: title,
            description: description,
            imageName: imageName,
            status: .pending,
            reporter: currentUser.firstName,
            reporterUserId: currentUser.id,
            date: .now
        )
        
        concerns.append(concern)
        
        Task{
            try? await self.communityService.addConcern(concern: concern)
        }
    }

    func addMarketplaceItem(title: String, priceText: String, description: String, imageName: String) {
        guard let communityIndex = selectedCommunityIndex,
              let currentUser,
              let price = Double(priceText) else { return }

        communities[communityIndex].marketplaceItems.insert(
            MarketplaceItem(
                id: UUID(),
                title: title,
                price: price,
                description: description,
                imageName: imageName,
                seller: currentUser.firstName,
                postedDate: .now
            ),
            at: 0
        )
    }

    func addStore(
        name: String,
        tagline: String,
        description: String,
        category: String,
        locationDetail: String,
        featuredItems: [String],
        startingPriceText: String,
        imageName: String
    ) {
        guard let communityIndex = selectedCommunityIndex,
              let currentUser else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let trimmedTagline = tagline.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedPrice = Double(startingPriceText)

        communities[communityIndex].stores.insert(
            CommunityStore(
                id: UUID(),
                name: trimmedName,
                tagline: trimmedTagline.isEmpty ? "Fresh local food from your community." : trimmedTagline,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                imageName: imageName,
                ownerName: currentUser.firstName,
                category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Home Food Business" : category,
                locationDetail: locationDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? currentUser.location : locationDetail,
                featuredItems: featuredItems,
                startingPrice: parsedPrice,
                postedDate: .now
            ),
            at: 0
        )
    }

    func syncOwnedCommunityOwnerName(from oldName: String, to newName: String) {
        for index in communities.indices where communities[index].ownerName == oldName {
            communities[index].ownerName = newName
        }
    }

    private var selectedCommunityIndex: Int? {
        guard let selectedCommunityID else { return nil }
        return communities.firstIndex(where: { $0.id == selectedCommunityID })
    }

    private func removePendingRequestIfNeeded(at index: Int) {
        guard let currentUser else { return }
        communities[index].pendingJoinRequests.removeAll { $0 == currentUser.firstName }
    }
}

extension CommunityViewModel {
    static let preview = CommunityViewModel(
       // communityService: PreviewCommunityService(),
        previewMode: true
    )
}
