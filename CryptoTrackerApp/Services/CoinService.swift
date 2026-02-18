//
//  CoinService.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 18.02.2026.
//
import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

struct CoinService {
    private let baseUrl: String = "https://api.coingecko.com/api/v3"
    
    func fetchCoins() async throws -> [Coin] {
        guard let url = URL(string: """
            https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1
            """) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) =  try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([Coin].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
    
