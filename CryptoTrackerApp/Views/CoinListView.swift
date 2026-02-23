import SwiftUI

struct CoinListView: View {
    @StateObject private var viewModel = CoinListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // MARK: - Sort Picker
                Picker("Sort", selection: $viewModel.sortOption) {
                    Text("Price ↑").tag(SortOption.price)
                    Text("Price ↓").tag(SortOption.priceDescending)
                    Text("24h Change").tag(SortOption.change)
                    Text("Name").tag(SortOption.name)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if !viewModel.topMovers.isEmpty && viewModel.searchText.isEmpty {
                    Section {
                        TopMoversView(coins: viewModel.topMovers)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                
                // MARK: - Content
                contentView
            }
            .navigationTitle("Crypto Tracker")
        }
        .searchable(text: $viewModel.searchText, prompt: "Search coin...")
        .task {
            await viewModel.fetchCoins()
        }
    }
}

// MARK: - Main Content Switch
private extension CoinListView {
    
    @ViewBuilder
    var contentView: some View {
        
        if viewModel.isLoading {
            loadingView
        }
        
        else if let error = viewModel.errorMessage, viewModel.coins.isEmpty {
            errorStateView(description: error)
        }
        
        else if viewModel.filteredCoins.isEmpty && !viewModel.searchText.isEmpty {
            centeredStateView(
                title: "No Results",
                systemImage: "magnifyingglass",
                description: "Try searching for another coin."
            )
        }
        
        else {
            coinListView
        }
    }
}

// MARK: - Loading View
private extension CoinListView {
    
    var loadingView: some View {
        List {
            ForEach(0..<8, id: \.self) { _ in
                coinRow(for: mockCoin)
                    .redacted(reason: .placeholder)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Normal List
private extension CoinListView {
    
    var coinListView: some View {
        List {
            ForEach(viewModel.filteredCoins) { coin in
                NavigationLink {
                    CoinDetailView(coin: coin)
                } label: {
                    coinRow(for: coin)
                }
                .onAppear {
                    if coin.id == viewModel.filteredCoins.last?.id {
                         Task {
                             await viewModel.fetchCoins()
                         }
                     }
                 }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            if let error = viewModel.errorMessage, !viewModel.coins.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding()
            }
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .padding()
            }
            if viewModel.hasReachedEnd {
                Text("You've seen all coins")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.fetchCoins(reset: true)
        }
    }
}

// MARK: - Error State View (supports pull-to-refresh and retry when initial load fails)
private extension CoinListView {
    
    func errorStateView(description: String) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 80)
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(description)
                )
                Button("Retry") {
                    Task {
                        await viewModel.fetchCoins(reset: true)
                    }
                }
                .buttonStyle(.borderedProminent)
                Spacer(minLength: 80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.fetchCoins(reset: true)
        }
    }
}

// MARK: - Centered State View
private extension CoinListView {
    
    func centeredStateView(title: String,
                           systemImage: String,
                           description: String) -> some View {
        VStack {
            Spacer()
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: Text(description)
            )
            Spacer()
        }
    }
}

// MARK: - Coin Row
@ViewBuilder
private func coinRow(for coin: Coin) -> some View {
    HStack(spacing: 12) {
        
        if let rank = coin.marketCapRank {
            Text("#\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 35)
        }
        
        AsyncImage(url: URL(string: coin.image)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 40, height: 40)
        
        VStack(alignment: .leading) {
            Text(coin.name)
                .font(.headline)
            
            Text(coin.symbol.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        Spacer()
        
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
                Text("MCap: \(formatMarketCap(marketCap))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding(.vertical, 4)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
    )
    .padding(.horizontal)
}

// MARK: - Helpers
private func formatMarketCap(_ value: Double) -> String {
    let trillion = value / 1_000_000_000_000
    let billion = value / 1_000_000_000
    let million = value / 1_000_000
    
    if trillion >= 1 {
        return String(format: "%.2fT", trillion)
    } else if billion >= 1 {
        return String(format: "%.2fB", billion)
    } else {
        return String(format: "%.2fM", million)
    }
}

private let mockCoin = Coin(
    id: "mock",
    name: "Bitcoin",
    symbol: "btc",
    image: "",
    currentPrice: 0,
    priceChangePercentage24H: 0,
    marketCap: 0,
    marketCapRank: 1
)

#Preview {
    CoinListView()
}
