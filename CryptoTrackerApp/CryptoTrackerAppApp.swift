//
//  CryptoTrackerAppApp.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 18.02.2026.
//

import SwiftUI
import Combine

@main
struct CryptoTrackerAppApp: App {
    
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some Scene {
        WindowGroup {
            TabView{
                CoinListView()
                    .environmentObject(themeManager)
                   
                    .preferredColorScheme(colorScheme)
                
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }
            }
            .environmentObject(favoritesManager)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch themeManager.selectedTheme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
