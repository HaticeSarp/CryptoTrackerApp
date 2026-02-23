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
    @Published var isLoadingMore = false
    private var currentPage = 1
    private var canLoadMore = true
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
    
    @MainActor
    func fetchCoins(reset: Bool = false) async {
        if reset {
            currentPage = 1
            canLoadMore = true
            errorMessage = nil
        }
        
        guard !isLoadingMore, canLoadMore else { return }
        
        isLoadingMore = true
        errorMessage = nil
        
        do {
            let newCoins = try await service.fetchCoins(page: currentPage)
            
            if reset {
                coins = newCoins
            } else if newCoins.isEmpty {
                canLoadMore = false
            } else {
                coins.append(contentsOf: newCoins)
            }
            
            if !newCoins.isEmpty {
                currentPage += 1
            } else if reset {
                canLoadMore = false
            }
            
        } catch {
            errorMessage = error.localizedDescription
            if reset {
                canLoadMore = !coins.isEmpty
            }
        }
        
        isLoadingMore = false
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
