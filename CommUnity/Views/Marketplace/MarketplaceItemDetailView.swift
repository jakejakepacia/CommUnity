import SwiftUI

struct MarketplaceItemDetailView: View {
    let item: MarketplaceItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary.opacity(0.18), AppTheme.secondary.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: item.imageName)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(AppTheme.primary)
                }
                .frame(height: 260)

                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(item.price, format: .currency(code: "PHP"))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.secondary)

                    Label("Sold by \(item.seller)", systemImage: "person.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(item.description)
                        .font(.body)
                        .foregroundStyle(AppTheme.textSecondary)

                    Label(item.postedDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Button("Message Seller") {
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primary)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Listing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MarketplaceItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MarketplaceItemDetailView(item: MockData.communities[0].marketplaceItems[0])
        }
    }
}
