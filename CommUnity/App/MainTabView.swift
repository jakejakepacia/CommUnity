import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                CommunitiesView()
            }
            .tabItem {
                Label("Communities", systemImage: "person.3.fill")
            }
            .tag(1)

            NavigationStack {
                CreateHubView()
            }
            .tabItem {
                Label("Create", systemImage: "plus.app.fill")
            }
            .tag(2)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            .tag(3)
        }
        .tint(AppTheme.primary)
       
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppViewModel.preview)
            .environmentObject(AppViewModel.preview.authViewModel)
            .environmentObject(AppViewModel.preview.communityViewModel)
    }
}
