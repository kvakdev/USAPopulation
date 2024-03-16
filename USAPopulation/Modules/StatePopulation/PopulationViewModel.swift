//
//  PopulationViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

struct PopulationViewModel: Equatable {
    let items: [OneStatePopulationViewModel]
}

struct OneStatePopulationViewModel: Equatable {
    let idState: String
    let state: String
    let idYear: Int
    let year: String
    let population: String
    let slugState: String
}
