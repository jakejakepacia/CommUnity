import SwiftUI

struct CommunitiesView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var communityViewModel: CommunityViewModel
    @State private var inviteCode = ""
    @State private var showingCreateCommunitySheet = false

    var body: some View {
        List {
            

            Section("Owned communities") {
                if communityViewModel.ownedCommunities.isEmpty {
                    VStack{
                        EmptyStateView(
                            title: "No Owned Communities",
                            message: "Create your first community.",
                            systemImage: "person.3"
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        Button("Create Community"){
                            showingCreateCommunitySheet = true
                        }
                        .frame(maxWidth: .infinity)
                    }
               
                } else {
                    ForEach(communityViewModel.ownedCommunities) { community in
                        Button {
                            communityViewModel.selectCommunity(community)
                        } label: {
                            communityRow(community: community, isOwnCommunity: true)
                        }
                        .buttonStyle(.plain)
                        Button("Create Community"){
                            showingCreateCommunitySheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primary)
                    }
                }
            }

            let ownedCommunitiesWithRequests = communityViewModel.ownedCommunities.filter { !$0.pendingJoinRequests.isEmpty }
            if !ownedCommunitiesWithRequests.isEmpty {
                Section("Pending approvals") {
                    ForEach(ownedCommunitiesWithRequests) { community in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(community.name)
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            ForEach(community.pendingJoinRequests, id: \.self) { requester in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(requester)
                                            .font(.subheadline.weight(.semibold))
                                        Text("Waiting to join this private community")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }

                                    Spacer()

                                    Button("Approve") {
                                        communityViewModel.approveJoinRequest(for: community, requesterName: requester)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(AppTheme.primary)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            
            Section("Joined community") {
                if communityViewModel.joinedCommunities.isEmpty {
                    EmptyStateView(
                        title: "No Joined Communities",
                        message: "Join a community to connect",
                        systemImage: "person.3"
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(communityViewModel.joinedCommunities) { community in
                        Button {
                            communityViewModel.selectCommunity(community)
                        } label: {
                            communityRow(community: community)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Enter invite code", text: $inviteCode)
                        .textInputAutocapitalization(.characters)

                    Button("Join Community") {
                        communityViewModel.joinCommunity(code: inviteCode)
                        inviteCode = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)

                    if let message = communityViewModel.communityMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Discover") {
                if communityViewModel.discoverCommunities.isEmpty {
                    Text("You’ve joined all available mock communities.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    ForEach(communityViewModel.discoverCommunities) { community in
                        VStack(alignment: .leading, spacing: 10) {
                            communityRow(community: community)

                            if community.accessPolicy == .privateApproval {
                                let currentName = authViewModel.currentUser?.firstName ?? ""
                                let alreadyRequested = community.pendingJoinRequests.contains(currentName)

                                Button(alreadyRequested ? "Request Sent" : "Request Access") {
                                    if !alreadyRequested {
                                        communityViewModel.requestToJoin(community)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(alreadyRequested ? .gray : AppTheme.secondary)
                                .disabled(alreadyRequested)
                            } else {
                                Button(community.isPrivate ? "Join with invite code: \(community.joinCode)" : "Join with \(community.joinCode)") {
                                    communityViewModel.joinCommunity(code: community.joinCode)
                                }
                                .buttonStyle(.bordered)
                                .tint(AppTheme.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingCreateCommunitySheet) {
            CreateCommunitySheet()
                .environmentObject(communityViewModel)
        }
    }

    private func communityRow(community: Community, isOwnCommunity: Bool = false) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.background)

                Image(systemName: community.coverSymbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.secondary)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
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

                Text("Owner: \(community.ownerName)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if(isOwnCommunity){
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundStyle(AppTheme.primary)
            }
     
        }
    }
}

private struct CreateCommunitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var communityViewModel: CommunityViewModel

    @State private var communityName = ""
    @State private var description = ""
    @State private var isPrivateCommunity = false
    @State private var requiresApproval = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Community Details") {
                    TextField("Community name", text: $communityName)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }

                Section("Privacy") {
                    Toggle("Make this community private", isOn: $isPrivateCommunity)

                    if isPrivateCommunity {
                        Picker("Private access", selection: $requiresApproval) {
                            Text("Invite only").tag(false)
                            Text("Admin approval").tag(true)
                        }
                        .pickerStyle(.segmented)

                        Text(requiresApproval
                             ? "Members can request access and you approve them before they join."
                             : "Only people with your invite code can join this community.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .navigationTitle("New Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        communityViewModel.createCommunity(
                            name: communityName,
                            description: description,
                            isPrivate: isPrivateCommunity,
                            requiresApproval: requiresApproval
                        )
                        dismiss()
                    }
                    .disabled(communityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct CommunitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CommunitiesView()
                .environmentObject(AuthViewModel.preview)
                .environmentObject(CommunityViewModel.preview)
        }
    }
}
