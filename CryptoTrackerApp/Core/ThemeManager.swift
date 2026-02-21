//
//  ThemeManager.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 21.02.2026.
//
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
}

final class ThemeManager: ObservableObject {
    
    @AppStorage("selectedTheme")
    private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    var selectedTheme: AppTheme {
        get { AppTheme(rawValue: selectedThemeRaw) ?? .system }
        set { selectedThemeRaw = newValue.rawValue }
    }
}
