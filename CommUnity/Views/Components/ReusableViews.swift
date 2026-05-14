import SwiftUI

struct LoadingStateView: View {
    let title: String
    let message: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.background, Color.white, AppTheme.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(AppTheme.primary)

                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 36)
            }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)

            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
    }
}

struct CommunityHeaderCard: View {
    let community: Community

    var body: some View {
        VStack(spacing: -30) {
            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: community.coverSymbol)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: geo.size.width, height: 200)
            }
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 14){
                HStack(alignment: .top) {
                   
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white, lineWidth: 4)
                            )

                        Image(systemName: community.coverSymbol)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 64, height: 64)

                    VStack(alignment: .leading, spacing: 6) {
                        Spacer()
                        Text(community.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("\(community.memberCount) members")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.secondary)
                    }

                    Spacer()
                }

                Text(community.description)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 8) {
                    Text(community.accessPolicy.shortLabel)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background((community.isPrivate ? Color.orange : AppTheme.secondary).opacity(0.14))
                        .foregroundStyle(community.isPrivate ? Color.orange : AppTheme.secondary)
                        .clipShape(Capsule())

                    Text("Owner: \(community.ownerName)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Label("Invite code: \(community.joinCode)", systemImage: "number.square.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)
            }.padding(20)
            
        }
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 14, y: 8)
    }
}

struct CommunityListCard: View {
    let community: Community
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: community.coverSymbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(community.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(community.accessPolicy.shortLabel)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((community.isPrivate ? Color.orange : AppTheme.secondary).opacity(0.14))
                        .foregroundStyle(community.isPrivate ? Color.orange : AppTheme.secondary)
                        .clipShape(Capsule())
                }

                Text(community.description)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)

                Text("\(community.memberCount) members")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.secondary)
            }

            Spacer()

            Image(systemName: isSelected ? "arrow.right.circle.fill" : "chevron.right")
                .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary)
        }
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 6)
    }
}

struct DiscoverCommunityCard: View {
    @EnvironmentObject private var communityViewModel: CommunityViewModel

    let community: Community

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primary.opacity(0.18), AppTheme.secondary.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: community.coverSymbol)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
            }
            .frame(height: 118)

            Text(community.name)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)

            Text(community.description)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(3)

            Text(community.accessPolicy.shortLabel)
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((community.isPrivate ? Color.orange : AppTheme.secondary).opacity(0.14))
                .foregroundStyle(community.isPrivate ? Color.orange : AppTheme.secondary)
                .clipShape(Capsule())

            actionButton
        }
        .frame(width: 240, alignment: .leading)
        .padding(16)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 6)
    }

    @ViewBuilder
    private var actionButton: some View {
        if community.accessPolicy == .privateApproval {
            let currentName = communityViewModel.currentUser?.firstName ?? ""
            let alreadyRequested = community.pendingJoinRequests.contains(currentName)

            Button(alreadyRequested ? "Request Sent" : "Request Access") {
                if !alreadyRequested {
                    communityViewModel.requestToJoin(community)
                }
            }
            .buttonStyle(.bordered)
            .tint(alreadyRequested ? .gray : AppTheme.primary)
            .disabled(alreadyRequested)
        } else {
            Button(community.isPrivate ? "Join by Invite" : "Join Community") {
                communityViewModel.joinCommunity(code: community.joinCode)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
        }
    }
}

struct AnnouncementCard: View {
    let announcement: Announcement

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(announcement.author, systemImage: "megaphone.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)

                Spacer()

                Text(announcement.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Text(announcement.title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(announcement.description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 6)
    }
}

struct ConcernStatusBadge: View {
    let status: ConcernStatus

    private var color: Color {
        switch status {
        case .pending: .orange
        case .inProgress: AppTheme.primary
        case .resolved: .green
        }
    }

    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.14))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct ConcernCard: View {
    let concern: Concern

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(concern.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Reported by \(concern.reporter)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                ConcernStatusBadge(status: concern.status)
            }

            Text(concern.description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            if let imageName = concern.imageName {
                HStack(spacing: 10) {
                    Image(systemName: imageName)
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary)

                    Text("Image attached")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Text(concern.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 6)
    }
}

struct MarketplaceItemCard: View {
    let item: MarketplaceItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.secondary.opacity(0.22), AppTheme.primary.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: item.imageName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
            }
            .frame(height: 140)

            Text(item.title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)

            Text(item.price, format: .currency(code: "PHP"))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.secondary)

            Text(item.seller)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(14)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 6)
    }
}

struct CommunityStoreCard: View {
    let store: CommunityStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.20), AppTheme.secondary.opacity(0.20)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: store.imageName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.orange)

                Text("Store")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .frame(height: 140)

            Text(store.name)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)

            Text(store.tagline)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(2)

            if let startingPrice = store.startingPrice {
                Text(startingPrice, format: .currency(code: "PHP"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.orange)
            } else {
                Text("Custom menu")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.orange)
            }

            Text(store.ownerName)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(14)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 6)
    }
}
