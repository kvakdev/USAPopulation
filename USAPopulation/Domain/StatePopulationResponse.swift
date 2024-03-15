//
//  StatePopulation.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

struct StatePopulationResponse: Codable {
    let data: [StatePopulation]
}

// MARK: - Datum
struct StatePopulation: Codable {
    let idState, state: String
    let idYear: Int
    let year: String
    let population: Int
    let slugState: String

    enum CodingKeys: String, CodingKey {
        case idState = "ID State"
        case state = "State"
        case idYear = "ID Year"
        case year = "Year"
        case population = "Population"
        case slugState = "Slug State"
    }
}
