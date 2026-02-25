//
//  FavoritesView.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 25.02.2026.
//
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var viewModel = CoinListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if favoriteCoins.isEmpty {
                    VStack {
                        Spacer()
                        ContentUnavailableView(
                            "No Favorites Yet",
                            systemImage: "star",
                            description: Text("Tap the star icon to add coins to favorites.")
                        )
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(favoriteCoins) { coin in
                            NavigationLink {
                                CoinDetailView(coin: coin)
                            } label: {
                                CoinRowView(coin: coin)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Favorites")
        }
        .task {
            await viewModel.fetchCoins(reset: true)
        }
    }
    
    private var favoriteCoins: [Coin] {
        viewModel.coins.filter {
            favoritesManager.isFavorite(id: $0.id)
        }
    }
}

