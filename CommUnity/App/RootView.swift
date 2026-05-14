import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if appViewModel.isLoading {
                LoadingStateView(
                    title: "Preparing your community",
                    message: "Loading nearby conversations, concerns, and listings."
                )
            } else if authViewModel.currentUser == nil {
                AuthView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appViewModel.isLoading)
        .animation(.easeInOut(duration: 0.25), value: authViewModel.currentUser != nil)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppViewModel.preview)
            .environmentObject(AppViewModel.preview.authViewModel)
            .environmentObject(AppViewModel.preview.communityViewModel)
    }
}
