import SwiftUI

struct CreateHubView: View {
    @EnvironmentObject private var communityViewModel: CommunityViewModel
    @State private var selectedMode: CreateMode = .announcement
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var tagline = ""
    @State private var category = ""
    @State private var locationDetail = ""
    @State private var featuredItemsText = ""
    @State private var communityName = ""
    @State private var isPrivateCommunity = false
    @State private var requiresApproval = false
    @State private var selectedSymbol = "photo"

    private let listingSymbols = ["photo", "bag.fill", "chair.fill", "book.fill", "bicycle"]
    private let storeSymbols = ["takeoutbag.and.cup.and.straw.fill", "fork.knife.circle.fill", "birthday.cake.fill", "cup.and.saucer.fill", "cart.fill"]

    var body: some View {
        Form {
            Section {
                Picker("Create", selection: $selectedMode) {
                    ForEach(CreateMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            switch selectedMode {
            case .announcement:
                Section("New announcement") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)

                    Button("Post Announcement") {
                        communityViewModel.addAnnouncement(title: title, description: description)
                        resetForm()
                    }
                }

            case .concern:
                Section("Report concern") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)

                    Picker("Optional image", selection: $selectedSymbol) {
                        ForEach(["photo", "lightbulb.max.fill", "drop.fill", "car.fill", "trash.fill"], id: \.self) { symbol in
                            Label(symbol.replacingOccurrences(of: ".", with: " "), systemImage: symbol).tag(symbol)
                        }
                    }

                    Button("Submit Concern") {
                        communityViewModel.addConcern(title: title, description: description, imageName: selectedSymbol == "photo" ? nil : selectedSymbol)
                        resetForm()
                    }
                }

            case .listing:
                Section("New marketplace listing") {
                    TextField("Title", text: $title)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)

                    Picker("Image", selection: $selectedSymbol) {
                        ForEach(listingSymbols, id: \.self) { symbol in
                            Label(symbol.replacingOccurrences(of: ".", with: " "), systemImage: symbol).tag(symbol)
                        }
                    }

                    Button("Post Listing") {
                        communityViewModel.addMarketplaceItem(title: title, priceText: price, description: description, imageName: selectedSymbol)
                        resetForm()
                    }
                }

            case .store:
                Section("Open a food store") {
                    TextField("Store name", text: $title)
                    TextField("Short tagline", text: $tagline)
                    TextField("Category", text: $category, prompt: Text("Home Cooked Meals"))
                    TextField("Pickup location", text: $locationDetail, prompt: Text("Block 3, front gate"))
                    TextField("Starting price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                    TextField("Featured items (comma separated)", text: $featuredItemsText, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)

                    Picker("Store image", selection: $selectedSymbol) {
                        ForEach(storeSymbols, id: \.self) { symbol in
                            Label(symbol.replacingOccurrences(of: ".", with: " "), systemImage: symbol).tag(symbol)
                        }
                    }

                    Button("Create Store") {
                        communityViewModel.addStore(
                            name: title,
                            tagline: tagline,
                            description: description,
                            category: category,
                            locationDetail: locationDetail,
                            featuredItems: featuredItems,
                            startingPriceText: price,
                            imageName: selectedSymbol
                        )
                        resetForm()
                    }
                }

            case .community:
                Section("Create community") {
                    TextField("Community name", text: $communityName)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                    Toggle("Make this community private", isOn: $isPrivateCommunity)

                    if isPrivateCommunity {
                        Picker("Private access", selection: $requiresApproval) {
                            Text("Invite only").tag(false)
                            Text("Admin approval").tag(true)
                        }
                        .pickerStyle(.segmented)

                        Text(requiresApproval
                             ? "Members can request access and the community owner must approve them."
                             : "Only users with an admin invite code can join this community.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                    }

                    Button("Create Community") {
                        communityViewModel.createCommunity(
                            name: communityName,
                            description: description,
                            isPrivate: isPrivateCommunity,
                            requiresApproval: requiresApproval
                        )
                        resetForm()
                    }
                }
            }

            Section {
                Text("Posts are mocked locally for now. New entries immediately appear in the selected community feed.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func resetForm() {
        title = ""
        description = ""
        price = ""
        tagline = ""
        category = ""
        locationDetail = ""
        featuredItemsText = ""
        communityName = ""
        isPrivateCommunity = false
        requiresApproval = false
        selectedSymbol = "photo"
    }

    private var featuredItems: [String] {
        featuredItemsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

struct CreateHubView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateHubView()
                .environmentObject(CommunityViewModel.preview)
        }
    }
}
