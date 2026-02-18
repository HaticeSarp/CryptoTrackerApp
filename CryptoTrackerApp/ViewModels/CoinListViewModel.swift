//
//  CoinListViewModel.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 18.02.2026.
//
import Foundation

@MainActor
final class CoinListViewModel: ObservableObject{
    
    @Published var coins: [Coin] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = CoinService()
    
    func fetchCoins() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.coins = try await service.fetchCoins()
        } catch {
            self.errorMessage = "Failed to fetch coins."
        }
        
        isLoading = false
    }
    
}
