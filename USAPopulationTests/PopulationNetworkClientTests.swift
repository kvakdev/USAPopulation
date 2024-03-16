//
//  PopulationNetworkClienTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import XCTest
@testable import USAPopulation
import ConcurrencyExtras

class PopulationNetworkClient {
    func fetchStatePopulation() async throws -> StatePopulationResponse {
        let urlString = "https://datausa.io/api/data?drilldowns=State&measures=Population&year=latest"
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL(urlString)
        }
        let urlRequest = URLRequest(url: url)
        let task = try await URLSession.shared.data(for: urlRequest)
        
        if (task.1 as? HTTPURLResponse)?.statusCode == 200 {
            do {
                let result = try JSONDecoder().decode(StatePopulationResponse.self, from: task.0)
                return result
            } catch {
                throw AppError.decodingError
            }
        } else {
            //TODO: check the code and return related error
            throw AppError.network
        }
    }
}

final class PopulationNetworkClienTests: XCTestCase {

    func test_fetches_and_parses_correctly() async throws {
        let sut = PopulationNetworkClient()
        
        try await withMainSerialExecutor {
            let _ = try await sut.fetchStatePopulation()
        }
    }
    
}
