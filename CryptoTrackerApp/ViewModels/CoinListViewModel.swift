//
//  CoinListViewModel.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 18.02.2026.
//
import Foundation
import Combine

enum SortOption {
    case price
    case priceDescending
    case change
    case name
}

@MainActor
final class CoinListViewModel: ObservableObject{
    
    @Published var coins: [Coin] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .priceDescending{
        didSet{
            sortCoins()
        }
    }

    private let service = CoinService()
    
    var filteredCoins : [Coin] {
        if searchText.isEmpty {
            return coins
        } else {
            return coins.filter {
                      $0.name.localizedCaseInsensitiveContains(searchText) ||
                      $0.symbol.localizedCaseInsensitiveContains(searchText)
                  }
        }
    }
    
    var topMovers: [Coin] {
        coins
            .filter { ($0.priceChangePercentage24H ?? 0) > 0 }
            .sorted { ($0.priceChangePercentage24H ?? 0) > ($1.priceChangePercentage24H ?? 0) }
            .prefix(5)
            .map { $0 }
    }
    
    func fetchCoins() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.coins = try await service.fetchCoins()
            sortCoins()
        } catch {
            self.errorMessage = "Failed to fetch coins."
        }
        
        isLoading = false
    }

    func sortCoins() {
        switch sortOption {
        case .price:
            coins.sort { $0.currentPrice < $1.currentPrice }
            
        case .priceDescending:
            coins.sort { $0.currentPrice > $1.currentPrice }
            
        case .change:
            coins.sort { ($0.priceChangePercentage24H ?? 0) >
                         ($1.priceChangePercentage24H ?? 0) }
            
        case .name:
            coins.sort { $0.name < $1.name }
        }
    }
}
