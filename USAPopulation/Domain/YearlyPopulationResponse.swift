//
//  YearlyPopulationResponse.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

struct YearlyPopulationResponse: Codable {
    let data: [YearPopulation]
}

// MARK: - Datum
struct YearPopulation: Codable {
    let idYear: Int
    let year: String
    let population: Int

    enum CodingKeys: String, CodingKey {
        case idYear = "ID Year"
        case year = "Year"
        case population = "Population"
    }
}
