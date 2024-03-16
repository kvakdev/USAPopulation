//
//  PreviewNetworkClient.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import Foundation

class PreviewNetworkClient: StatePopulationAPIProtocol {
    func getPopulation() async throws -> USAPopulation.StatePopulationResponse {
        guard let sampleJSON = String.statePopulationJSON.data(using: .utf8) else {
            throw NSError(domain: "JSON Parsing Test. Unable to convert sample json", code: 1)
        }
        
        return try JSONDecoder().decode(StatePopulationResponse.self, from: sampleJSON)
    }
}

extension PreviewNetworkClient: YearPopulationAPIProtocol {
    func getPopulation() async throws -> YearlyPopulationResponse {
        guard let sampleJSON = String.yearlyPopulationJSON.data(using: .utf8) else {
            throw NSError(domain: "JSON Parsing Test. Unable to convert sample json", code: 1)
        }
        
        return try JSONDecoder().decode(YearlyPopulationResponse.self, from: sampleJSON)
    }
}
