//
//  AppError.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

enum AppError: Error, Equatable {
    case network
    case decodingError
    case unknown(String)
    case invalidURL(String)
    
    var readableDescription: String {
        switch self {
        case .network:
            "Please check internet connection"
        case .decodingError:
            "Unexpected response format"
        case .unknown(let string):
            "Unknown error: \(string)"
        case .invalidURL(let string):
            "Invalid url: \(string)"
        }
    }
}
