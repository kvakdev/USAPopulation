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
}
