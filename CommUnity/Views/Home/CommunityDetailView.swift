import SwiftUI

struct CommunityDetailView: View {
    @EnvironmentObject private var communityViewModel: CommunityViewModel
    @State private var selectedTab: FeedTab = .announcements
    @State private var showingCreateAnnouncementSheet = false
    @State private var showingCreateConcernSheet = false

    let communityID: Community.ID

    private var community: Community? {
        communityViewModel.communities.first(where: { $0.id == communityID })
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if let community {
                        CommunityHeaderCard(community: community)

                        VStack(alignment: .leading, spacing: 10) {
                            Picker("Feed", selection: $selectedTab) {
                                ForEach(FeedTab.allCases) { tab in
                                    Text(tab.rawValue).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)

                            content(for: community)
                            
                          
                        }.padding(20)
                
                    } else {
                        EmptyStateView(
                            title: "Community not found",
                            message: "This community may have been removed from the local mock data.",
                            systemImage: "exclamationmark.triangle"
                        )
                    }
                }
            }
            
            // Floating button
             if let community {
                 addButton(for: community)
                     .padding(.trailing, 30)
                     .padding(.bottom, 50)
             }
            
        }
        .task {
            if let community {
                await communityViewModel.loadAnnouncements(by: community.id)
                await communityViewModel.loadConcerns(by: community.id)
                
                communityViewModel.observeListeners(by: community.id)
                
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if let community {
                communityViewModel.selectCommunity(community)
            }
        }
        .onDisappear {
            communityViewModel.stopObservingListeners()
        }
        .sheet(isPresented: $showingCreateAnnouncementSheet) {
            CreateAnnouncementView(communityID: communityID)
                .environmentObject(communityViewModel)
        }
        .sheet(isPresented: $showingCreateConcernSheet) {
            CreateConcernView(communityID: communityID)
                .environmentObject(communityViewModel)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func addButton(for community: Community) -> some View {

        let icon: String = {
            switch selectedTab {
            case .announcements:
                return "megaphone"

            case .concerns:
                return "exclamationmark.bubble"

            case .marketplace:
                return "storefront"
            }
        }()

        Button {
            switch selectedTab {
            case .announcements:
                showingCreateAnnouncementSheet = true
            case .concerns:
                showingCreateConcernSheet = true
            case .marketplace:
                break
            }
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .clipShape(Circle())
        }
        .disabled(selectedTab == .marketplace)
        .opacity(selectedTab == .marketplace ? 0.45 : 1)
    }

    @ViewBuilder
    private func content(for community: Community) -> some View {
        
        switch selectedTab {
        case .announcements:
            let announcements = communityViewModel.announcements.filter { $0.communityId == community.id.uuidString }
            
            if announcements.isEmpty {
                EmptyStateView(
                    title: "No announcements yet",
                    message: "Admins can post updates here for members to see.",
                    systemImage: "megaphone"
                )
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(announcements) { announcement in
                        AnnouncementCard(announcement: announcement)
                    }
                }
            }
        case .concerns:
            let concerns = communityViewModel.concerns.filter { $0.communityId == community.id.uuidString }
          
            if concerns.isEmpty {
                EmptyStateView(
                    title: "No concerns reported",
                    message: "Residents can submit issues like lighting, flooding, and safety concerns here.",
                    systemImage: "exclamationmark.bubble"
                )
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(concerns) { concern in
                        ConcernCard(concern: concern)
                    }
                }
            }
        case .marketplace:
            if community.marketplaceEntries.isEmpty {
                EmptyStateView(
                    title: "Marketplace is quiet",
                    message: "Once members post listings or open food stores, they’ll show up in this local marketplace.",
                    systemImage: "storefront"
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(community.marketplaceEntries) { entry in
                        NavigationLink {
                            switch entry {
                            case .listing(let item):
                                MarketplaceItemDetailView(item: item)
                            case .store(let store):
                                CommunityStoreDetailView(store: store)
                            }
                        } label: {
                            switch entry {
                            case .listing(let item):
                                MarketplaceItemCard(item: item)
                            case .store(let store):
                                CommunityStoreCard(store: store)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct CommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CommunityDetailView(communityID: MockData.communities[0].id)
                .environmentObject(CommunityViewModel.preview)
        }
    }
}

private struct CreateAnnouncementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var communityViewModel: CommunityViewModel

    @State private var title = ""
    @State private var description = ""

    let communityID: Community.ID

    private var communityName: String {
        communityViewModel.communities.first(where: { $0.id == communityID })?.name ?? "Community"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Announcement") {
                    TextField("Title", text: $title)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                }

                Section {
                    Text("This will be posted to \(communityName).")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .navigationTitle("Create Announcement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        communityViewModel.selectCommunityIfNeeded(communityID)
                        communityViewModel.addAnnouncement(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct CreateConcernView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var communityViewModel: CommunityViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var selectedSymbol = "photo"

    let communityID: Community.ID

    private let concernSymbols = ["photo", "lightbulb.max.fill", "drop.fill", "car.fill", "trash.fill", "exclamationmark.triangle.fill"]

    private var communityName: String {
        communityViewModel.communities.first(where: { $0.id == communityID })?.name ?? "Community"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Concern") {
                    TextField("Title", text: $title)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(6, reservesSpace: true)

                    Picker("Optional image", selection: $selectedSymbol) {
                        ForEach(concernSymbols, id: \.self) { symbol in
                            Label(symbol.replacingOccurrences(of: ".", with: " "), systemImage: symbol)
                                .tag(symbol)
                        }
                    }
                }

                Section {
                    Text("This will be reported to \(communityName).")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .navigationTitle("Report Concern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Submit") {
                        communityViewModel.selectCommunityIfNeeded(communityID)
                        communityViewModel.addConcern(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                            imageName: selectedSymbol == "photo" ? nil : selectedSymbol
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
