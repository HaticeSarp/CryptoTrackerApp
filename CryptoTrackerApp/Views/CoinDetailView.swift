//
//  CoinDetailView.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 20.02.2026.
//
import SwiftUI

struct CoinDetailView: View {
    let coin: Coin
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                AsyncImage(url: URL(string: coin.image)!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                
                Text(coin.name)
                    .font(.largeTitle)
                    .bold()
                
                Text("\(coin.symbol.uppercased())")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                
                VStack(spacing: 12){
                    
                    HStack{
                        Text("Current Price")
                        Spacer()
                        Text("$\(coin.currentPrice, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                    
                    if let change = coin.priceChangePercentage24H {
                        HStack{
                            Text("24h Change")
                            Spacer()
                            Text("\(change, specifier: "%.2f")%")
                                .foregroundStyle(change >= 0 ? .green : .red)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
