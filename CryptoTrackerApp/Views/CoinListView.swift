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
            Group{
                if viewModel.isLoading {
                    ProgressView("Loading...") }
                else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                    List(viewModel.coins) { coin in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: coin.image)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            
                            Text(coin.name)
                        }
                    }.refreshable {
                        await viewModel.fetchCoins()
                    }
                }
            }
        }.task {
            await viewModel.fetchCoins()
        }
    }
}

#Preview {
    CoinListView()
}

