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
    
    func fetchCoins(page: Int, perPage: Int = 20) async throws -> [Coin] {
        let endpoint = "\(baseUrl)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(perPage)&page=\(page)&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: endpoint) else {
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

