import SwiftUI

struct CoinListView: View {
    @StateObject private var viewModel = CoinListViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SortPicker(selection: $viewModel.sortOption)
                topMoversSection
                contentView
            }
            .navigationTitle("Crypto Tracker")
        }
        .searchable(text: $viewModel.searchText, prompt: "Search coin...")
        .task { await viewModel.fetchCoins() }
    }

    @ViewBuilder
    private var topMoversSection: some View {
        if !viewModel.topMovers.isEmpty && viewModel.searchText.isEmpty {
            TopMoversView(coins: viewModel.topMovers)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            CoinListLoadingView(showLoadingMore: viewModel.isLoadingMore)
        } else if let error = viewModel.errorMessage, viewModel.coins.isEmpty {
            CoinListErrorView(description: error) {
                await viewModel.fetchCoins(reset: true)
            }
        } else if viewModel.filteredCoins.isEmpty && !viewModel.searchText.isEmpty {
            EmptyStateView(
                title: "No Results",
                systemImage: "magnifyingglass",
                description: "Try searching for another coin."
            )
        } else {
            CoinListContentView(viewModel: viewModel)
        }
    }
}

// MARK: - Sort Picker

private struct SortPicker: View {
    @Binding var selection: SortOption

    var body: some View {
        Picker("Sort", selection: $selection) {
            Text("Price ↑").tag(SortOption.price)
            Text("Price ↓").tag(SortOption.priceDescending)
            Text("24h Change").tag(SortOption.change)
            Text("Name").tag(SortOption.name)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

// MARK: - Loading View
private struct CoinListLoadingView: View {
    let showLoadingMore: Bool

    var body: some View {
        List {
            ForEach(0..<8, id: \.self) { _ in
                CoinRowView(coin: .placeholder)
                    .redacted(reason: .placeholder)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            if showLoadingMore {
                ForEach(0..<3, id: \.self) { _ in
                    CoinRowView(coin: .placeholder)
                        .redacted(reason: .placeholder)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .modifier(CoinListStyle())
    }
}

// MARK: - Error State View
private struct CoinListErrorView: View {
    let description: String
    let retry: () async -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 80)
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(description)
                )
                Button("Retry") {
                    Task { await retry() }
                }
                .buttonStyle(.borderedProminent)
                Spacer(minLength: 80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .refreshable { await retry() }
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        VStack {
            Spacer()
            ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
            Spacer()
        }
    }
}

// MARK: - Coin List Content (main list + footer)
private struct CoinListContentView: View {
    @ObservedObject var viewModel: CoinListViewModel

    var body: some View {
        List {
            ForEach(viewModel.filteredCoins) { coin in
                NavigationLink {
                    CoinDetailView(coin: coin)
                } label: {
                    CoinRowView(coin: coin)
                }
                .onAppear {
                    if coin.id == viewModel.filteredCoins.last?.id {
                        Task { await viewModel.fetchCoins() }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            CoinListFooterView(
                errorMessage: viewModel.errorMessage,
                hasCoins: !viewModel.coins.isEmpty,
                isLoadingMore: viewModel.isLoadingMore,
                hasReachedEnd: viewModel.hasReachedEnd
            )
        }
        .modifier(CoinListStyle())
        .refreshable { await viewModel.fetchCoins(reset: true) }
    }
}

// MARK: - List Footer (error banner, loading, end message)
private struct CoinListFooterView: View {
    let errorMessage: String?
    let hasCoins: Bool
    let isLoadingMore: Bool
    let hasReachedEnd: Bool

    var body: some View {
        Group {
            if let error = errorMessage, hasCoins {
                errorBanner(error)
            }
            if isLoadingMore {
                loadingIndicator
            }
            if hasReachedEnd {
                endOfListLabel
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .padding()
    }

    private var loadingIndicator: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .listRowBackground(Color.clear)
        .padding()
    }

    private var endOfListLabel: some View {
        Text("You've seen all coins")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding()
    }
}

// MARK: - Coin Row
struct CoinRowView: View {
    let coin: Coin
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        HStack(spacing: 12) {
            rankLabel
            coinImage
            nameAndSymbol
            Spacer()
            priceAndChange
            favoriteButton
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private var rankLabel: some View {
        if let rank = coin.marketCapRank {
            Text("#\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 35)
        }
    }

    private var coinImage: some View {
        AsyncImage(url: URL(string: coin.image)) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 40, height: 40)
    }

    private var nameAndSymbol: some View {
        VStack(alignment: .leading) {
            Text(coin.name).font(.headline)
            Text(coin.symbol.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var priceAndChange: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("$\(coin.currentPrice, specifier: "%.2f")")
                .font(.headline)
            if let change = coin.priceChangePercentage24H {
                Text("\(change, specifier: "%.2f")%")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(change >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundStyle(change >= 0 ? .green : .red)
                    .clipShape(Capsule())
            }
            if let marketCap = coin.marketCap {
                Text("MCap: \(Self.formatMarketCap(marketCap))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private static func formatMarketCap(_ value: Double) -> String {
        let trillion = value / 1_000_000_000_000
        let billion = value / 1_000_000_000
        let million = value / 1_000_000
        if trillion >= 1 { return String(format: "%.2fT", trillion) }
        if billion >= 1 { return String(format: "%.2fB", billion) }
        return String(format: "%.2fM", million)
    }
    
    private var favoriteButton: some View {
        Button {
            favoritesManager.toggleFavorite(id: coin.id)
         } label: {
             Image(systemName: favoritesManager.isFavorite(id: coin.id) ? "star.fill" : "star")
                 .foregroundStyle(favoritesManager.isFavorite(id: coin.id) ? .yellow : .gray)
         }
         .buttonStyle(.plain)
    }
}

// MARK: - Coin Placeholder
private extension Coin {
    static var placeholder: Coin {
        Coin(
            id: "mock",
            name: "Bitcoin",
            symbol: "btc",
            image: "",
            currentPrice: 0,
            priceChangePercentage24H: 0,
            marketCap: 0,
            marketCapRank: 1
        )
    }
}

// MARK: - List Style Modifier
private struct CoinListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
    }
}
