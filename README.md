# CryptoTrackerApp 💰

A native iOS application built with SwiftUI that displays real-time cryptocurrency market data using a scalable MVVM architecture.

## 🚀 Features

- Fetch coins from remote API (CoinGecko)
- MVVM Architecture
- URLSession networking
- Loading state handling (skeleton shimmer)
- Error state handling
- Pull to refresh
- Infinite scroll (pagination)
- NavigationStack-based navigation
- Coin Detail Screen
- Top Movers carousel
- Search and sort (price, 24h change, name)
- Light / Dark / System theme
- MainActor for safe UI updates
- Rate limit (429) handling with user-friendly messages

## 🛠 Tech Stack

- Swift
- SwiftUI
- MVVM
- URLSession
- Combine
- async/await
- JSONDecoder

## 📦 Architecture

The project follows the MVVM pattern:

- **Model** → Coin.swift
- **Service** → CoinService.swift
- **ViewModel** → CoinListViewModel.swift
- **View** → CoinListView.swift

The ViewModel handles:
- Business logic
- Sorting and filtering
- Pagination control
- State management (loading, error, empty)

## 🔄 Pagination Strategy

- Infinite scroll triggered when the last visible item appears
- isLoadingMore flag prevents duplicate API calls
- Graceful handling when no more data is available

## Views

- CoinListView.swift
- CoinDetailView.swift
- TopMoversView.swift
- TopMoverCard.swift

## 🌐 API Used

Data is fetched from:

**https://api.coingecko.com/api/v3/coins/markets**

- Free public API (no API key required)
- Paginated: 50 items per page
- Rate limit: ~10–30 requests per minute on free tier

## 🎯 Purpose of the Project

This project was created to practice:

- Networking in Swift
- JSON parsing
- MVVM architecture
- State management in SwiftUI
- Clean code structure
- Navigation between screens
- Pagination and pull-to-refresh
- Error and loading state handling

## 👩‍💻 Author
**Hatice Kapkıner**
iOS Developer
