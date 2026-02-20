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
            List{
                if viewModel.isLoading {
                    ProgressView("Loading...") }
                else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                    ForEach(viewModel.coins) { coin in
                        HStack(spacing: 12) {
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
                                          .clipShape(RoundedRectangle(cornerRadius: 6))
                                  }
                            }
                        }
                        .padding(.vertical,4)
                    }
                }
            }
            .refreshable {
                await viewModel.fetchCoins()
            }
            .navigationTitle("Crypto Tracker")
        }.task {
            await viewModel.fetchCoins()
        }
    }
}

#Preview {
    CoinListView()
}

