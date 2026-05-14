import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var communityViewModel: CommunityViewModel

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    joinedCommunitiesSection
                    discoverSection
                }
                .padding(20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi, \(communityViewModel.currentUserDisplayName)")
                .font(.title.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Choose a community to open its updates, concerns, and marketplace.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var joinedCommunitiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Your Communities", subtitle: "Tap a community to open its page.")

            if communityViewModel.joinedCommunities.isEmpty {
                EmptyStateView(
                    title: "No joined communities yet",
                    message: "Join or create a community to start seeing local announcements, concerns, and marketplace activity.",
                    systemImage: "person.3.sequence.fill"
                )
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(communityViewModel.joinedCommunities) { community in
                        NavigationLink {
                            CommunityDetailView(communityID: community.id)
                        } label: {
                            CommunityListCard(community: community, isSelected: communityViewModel.selectedCommunityID == community.id)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                communityViewModel.selectCommunity(community)
                            }
                        )
                    }
                }
            }
        }
    }

    private var discoverSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Suggested Communities", subtitle: "Discover nearby groups you may want to join.")

            if communityViewModel.discoverCommunities.isEmpty {
                EmptyStateView(
                    title: "No more suggestions for now",
                    message: "You’ve already joined all available mock communities.",
                    systemImage: "sparkles"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(communityViewModel.discoverCommunities) { community in
                            DiscoverCommunityCard(community: community)
                                .environmentObject(communityViewModel)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(CommunityViewModel.preview)
        }
    }
}
