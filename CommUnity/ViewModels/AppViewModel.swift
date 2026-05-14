import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var isLoading = true

    let authViewModel: AuthViewModel
    let communityViewModel: CommunityViewModel

    private var cancellables: Set<AnyCancellable> = []
    private let previewMode: Bool

    init(
        authViewModel: AuthViewModel? = nil,
        communityViewModel: CommunityViewModel? = nil,
        previewMode: Bool = false
    ) {
        self.previewMode = previewMode
        self.authViewModel = authViewModel ?? (previewMode ? .preview : AuthViewModel())
        self.communityViewModel = communityViewModel ?? (previewMode ? .preview : CommunityViewModel())

        bindChildren()

        if previewMode {
            self.communityViewModel.currentUser = self.authViewModel.currentUser
            isLoading = false
        } else {
            Task {
                await bootstrap()
            }
        }
    }

    var currentUser: User? {
        authViewModel.currentUser
    }

    func bootstrap() async {
        await authViewModel.bootstrap()
        await communityViewModel.bootstrap()
        communityViewModel.currentUser = authViewModel.currentUser
        isLoading = false
    }

    private func bindChildren() {
        authViewModel.onUserChanged = { [weak self] user in
            self?.communityViewModel.currentUser = user
            self?.objectWillChange.send()
        }

        authViewModel.onProfileRenamed = { [weak self] oldName, newName in
            self?.communityViewModel.syncOwnedCommunityOwnerName(from: oldName, to: newName)
        }

        authViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.syncLoadingState()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        communityViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.syncLoadingState()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func syncLoadingState() {
        isLoading = previewMode ? false : (authViewModel.isLoading || communityViewModel.isLoading)
    }
}

extension AppViewModel {
    static let preview = AppViewModel(previewMode: true)
}
