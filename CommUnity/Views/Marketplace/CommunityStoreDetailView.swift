import SwiftUI

struct CommunityStoreDetailView: View {
    let store: CommunityStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.22), AppTheme.secondary.opacity(0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: store.imageName)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(Color.orange)
                }
                .frame(height: 260)

                VStack(alignment: .leading, spacing: 12) {
                    Text(store.name)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(store.tagline)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.orange)

                    Label("By \(store.ownerName)", systemImage: "person.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Label(store.category, systemImage: "fork.knife")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Label(store.locationDetail, systemImage: "mappin.and.ellipse")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    if let startingPrice = store.startingPrice {
                        Text("Starts at \(startingPrice, format: .currency(code: "PHP"))")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.secondary)
                    }

                    Text(store.description)
                        .font(.body)
                        .foregroundStyle(AppTheme.textSecondary)

                    if !store.featuredItems.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Featured Menu")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            ForEach(store.featuredItems, id: \.self) { item in
                                Label(item, systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    Label(store.postedDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Button("View Store Menu") {
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primary)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Store")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommunityStoreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CommunityStoreDetailView(store: MockData.communities[0].stores[0])
        }
    }
}
