//
//  Constants.swift
//  CommUnity
//
//  Created by Christien Jake Pacia on 5/6/26.
//

struct K {
    static let appName = "FlashChat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let registerSegue = "RegisterToChat"
    static let loginSegue = "LoginToChat"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let usersCollectionName = "users"
        static let communityCollectionName = "communities"
        static let announcementsCollectionName = "announcements"
        static let idField = "id"
        static let firstNameField = "firstName"
        static let lastNameField = "lastName"
        static let emailField = "email"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
        
    }
    
    struct CommunityField{
        static let approvedIds = "approvedMemberIds"
    }
}
