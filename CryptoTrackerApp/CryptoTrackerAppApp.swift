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

    var body: some Scene {
        WindowGroup {
            CoinListView()
                .environmentObject(themeManager)
                .preferredColorScheme(colorScheme)
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
