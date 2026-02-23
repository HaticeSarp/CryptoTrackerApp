//
//  CoinService.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 18.02.2026.
//
import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int?)
    case decodingError
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid address."
        case .invalidResponse:
            return "Server couldn't be reached. Try again later."
        case .decodingError:
            return "An error occurred while processing the data."
        case .rateLimited:
            return "Too many requests. Please wait a minute and pull to refresh."
        }
    }
}

struct CoinService {
    private let baseUrl: String = "https://api.coingecko.com/api/v3"
    
    /// Use a larger perPage (e.g. 50) to reduce request count and avoid rate limits.
    func fetchCoins(page: Int, perPage: Int = 50) async throws -> [Coin] {
        let endpoint = "\(baseUrl)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(perPage)&page=\(page)&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: nil)
        }
        switch httpResponse.statusCode {
        case 200:
            break
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode([Coin].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

