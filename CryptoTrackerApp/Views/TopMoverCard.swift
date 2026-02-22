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
        VStack(spacing: 12) {
            
            AsyncImage(url: URL(string: coin.image)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            Text(coin.symbol.uppercased())
                .font(.headline)
                .foregroundStyle(.white)
            
            if let change = coin.priceChangePercentage24H {
                Text("+\(change, specifier: "%.2f")%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .frame(width: 120)
        .background(
            LinearGradient(
                colors: [.green, .mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 6)
        .scaleEffect(0.98)
        .animation(.easeInOut(duration: 0.2), value: coin.id)
    }
}
