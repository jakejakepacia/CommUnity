import Foundation
@preconcurrency import FirebaseFirestore

protocol CommunityServicing {
    func fetchCommunities() async throws -> [Community]
    func fetchAnnouncements(communityId: UUID) async throws -> [Announcement]
    func createCommunity(_ community: Community) async throws
    func joinPublicCommnuty(communityId: UUID, _ user: User) async throws
    func postAnnouncement(announcement: Announcement) async throws
    func listenToAnnouncements(
        communityId: UUID,
        completion: @escaping ([Announcement]) -> Void
    ) -> ListenerRegistration
}

struct FirebaseCommunityService: CommunityServicing {
    
    private let db = Firestore.firestore()

    func listenToAnnouncements(
            communityId: UUID,
            completion: @escaping ([Announcement]) -> Void
        ) -> ListenerRegistration {

            return db.collection(K.FStore.announcementsCollectionName)
                .whereField("communityId", isEqualTo: communityId.uuidString)
                .addSnapshotListener { snapshot, error in

                    guard let documents = snapshot?.documents else {
                        completion([])
                        return
                    }

                    let announcements = documents.compactMap {
                        try? $0.data(as: Announcement.self)
                    }
                    .sorted { $0.date > $1.date }

                    completion(announcements)
                }
        }
    
    func fetchCommunities() async throws -> [Community] {
        try await db.collection(K.FStore.communityCollectionName)
            .getDocuments()
            .documents
            .compactMap { document in
                try? document.data(as: Community.self)
            }
    }

    func createCommunity(_ community: Community) async throws {
        try db
            .collection(K.FStore.communityCollectionName)
            .document(community.id.uuidString)
            .setData(from: community)
    }
    
    func joinPublicCommnuty(communityId: UUID,_ user: User) async throws {
        
        let communityRef = db.collection(K.FStore.communityCollectionName).document(communityId.uuidString)
        
        try await communityRef.updateData([
            K.CommunityField.approvedIds: FieldValue.arrayUnion([user.id])
        ])
    }
    
    func postAnnouncement(announcement: Announcement) async throws {
        try db.collection(K.FStore.announcementsCollectionName)
            .document(announcement.id.uuidString)
            .setData(from: announcement)
    }
    
    func fetchAnnouncements(communityId: UUID) async throws -> [Announcement] {

        let snapshot = try await db
            .collection(K.FStore.announcementsCollectionName)
            .whereField("communityId", isEqualTo: communityId.uuidString)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            try? document.data(as: Announcement.self)
        }
    }
    
    
}

