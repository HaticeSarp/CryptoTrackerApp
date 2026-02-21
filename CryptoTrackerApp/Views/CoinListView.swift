//
//  CoinListView.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 18.02.2026.
//
import SwiftUI

struct CoinListView: View {
    @StateObject private var viewModel = CoinListViewModel()
    var body: some View {
        NavigationStack {
            VStack{
                Picker("Sort", selection: $viewModel.sortOption){
                    Text("Price ↑").tag(SortOption.price)
                    Text("Price ↓").tag(SortOption.priceDescending)
                    Text("24h Change").tag(SortOption.change)
                    Text("Name").tag(SortOption.name)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                List{
                    if viewModel.isLoading {
                        ForEach(0..<8, id: \.self) { _ in
                            coinRow(for: mockCoin)
                                .redacted(reason: .placeholder)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                    } else {
                        ForEach(viewModel.coins) { coin in
                            NavigationLink{
                                CoinDetailView(coin: coin)
                            } label : {
                                coinRow(for: coin)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    await viewModel.fetchCoins()
                }
            }
            .navigationTitle("Crypto Tracker")
        }.task {
            await viewModel.fetchCoins()
        }
    }
}

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
        
        VStack(alignment: .leading ) {
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
    .padding(.vertical,4)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
    )
    .padding(.horizontal)
}

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

