//
//  PopulationNetworkClient.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import Foundation

enum Constants {
    static let stateUrl = "https://datausa.io/api/data?drilldowns=State&measures=Population&year=latest"
    static let nationUrl = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"
}

protocol URLClient {
    func getFrom(urlString: String) async throws -> (Data, URLResponse)
}

class PopulationNetworkClient {
    let urlClient: URLClient
    
    init(urlClient: URLClient) {
        self.urlClient = urlClient
    }
    
    func fetchStatePopulation() async throws -> StatePopulationResponse {
        let task = try await urlClient.getFrom(urlString: Constants.stateUrl)
        let response = task.1
        
        guard response.isOK else {
            //TODO: check the code and return related error
            throw AppError.network
        }
        do {
            let result = try JSONDecoder().decode(StatePopulationResponse.self, from: task.0)
            return result
        } catch {
            throw AppError.decodingError
        }
    }
    
    func fetchYearlyPopulation() async throws -> YearlyPopulationResponse {
        let task = try await urlClient.getFrom(urlString: Constants.nationUrl)
        let response = task.1
        
        guard response.isOK else {
            //TODO: check the code and return related error
            throw AppError.network
        }
        do {
            let result = try JSONDecoder().decode(YearlyPopulationResponse.self, from: task.0)
            return result
        } catch {
            throw AppError.decodingError
        }
    }
}

extension PopulationNetworkClient: StatePopulationAPIProtocol {
    func getPopulation() async throws -> USAPopulation.StatePopulationResponse {
        return try await fetchStatePopulation()
    }
}

extension PopulationNetworkClient: YearPopulationAPIProtocol {
    func getPopulation() async throws -> YearlyPopulationResponse {
        return try await fetchYearlyPopulation()
    }
}
