//
//  StatePopulationAPIProtocol.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

protocol StatePopulationAPIProtocol {
    func getPopulation() async throws -> StatePopulation
}
