//
//  TopMoverCard.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 22.02.2026.
//
import SwiftUI

struct TopMoverCard: View {
    let coin: Coin
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: coin.image)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            Text(coin.symbol.uppercased())
                .font(.headline)
            
            if let change = coin.priceChangePercentage24H {
                Text("\(change, specifier: "%.2f")%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(width: 110)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
