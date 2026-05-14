//
//  CommUnityApp.swift
//  CommUnity
//
//  Created by Christien Jake Pacia on 5/5/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

      let db = Firestore.firestore()
      print("db: \(db)")
    return true
  }
}
@main
struct CommUnityApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environmentObject(appViewModel.authViewModel)
                .environmentObject(appViewModel.communityViewModel)
        }
    }
}
