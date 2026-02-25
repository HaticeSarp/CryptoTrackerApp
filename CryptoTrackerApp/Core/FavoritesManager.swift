//
//  FavoritesManager.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 25.02.2026.
//
import Foundation
import Combine

final class FavoritesManager: ObservableObject{
    @Published private(set) var favoriteIDs: Set<String> = []
    
    private let key = "favorite_coins"
    
    init(){
        loadFavorites()
    }
    
    func toggleFavorite(id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        saveFavorites()
    }
    
    func isFavorite(id: String) -> Bool {
        favoriteIDs.contains(id)
    }
    
    private func saveFavorites() {
        let array = Array(favoriteIDs)
        UserDefaults.standard.set(array, forKey: key)
    }
    
    private func loadFavorites(){
        if let savedFavorites = UserDefaults.standard.value(forKey: key) as? [String]{
            favoriteIDs = Set(savedFavorites)
        }
    }
}
