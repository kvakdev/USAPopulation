//
//  DIContainer.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 17/03/2024.
//

import Foundation

struct DIContainer {
    var makePopulationAPI: () -> YearPopulationAPIProtocol & StatePopulationAPIProtocol
}
