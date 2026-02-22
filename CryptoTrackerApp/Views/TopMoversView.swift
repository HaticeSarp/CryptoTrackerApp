//
//  TopMoversView.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 22.02.2026.
//
import SwiftUI

struct TopMoversView: View {
    let coins: [Coin]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 Top Movers")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(coins) { coin in
                        TopMoverCard(coin: coin)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
