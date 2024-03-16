//
//  PopulationNetworkClienTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import XCTest
@testable import USAPopulation
import ConcurrencyExtras

enum Constants {
    static let stateUrl = "https://datausa.io/api/data?drilldowns=State&measures=Population&year=latest"
}

protocol URLClient {
    func getFrom(urlString: String) async throws -> (Data, URLResponse)
}

class URLClientMock: URLClient {
    var wrongURL: URL?
    
    func getFrom(urlString: String) async throws -> (Data, URLResponse) {
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL(urlString)
        }
        var resultURL = wrongURL ?? url
        let urlRequest = URLRequest(url: resultURL)
        
        return try await URLSession.shared.data(for: urlRequest)
    }
}

class PopulationNetworkClient: StatePopulationAPIProtocol {
    func getPopulation() async throws -> USAPopulation.StatePopulationResponse {
        return try await fetchStatePopulation()
    }
    
    let urlClient: URLClient
    
    init(urlClient: URLClient) {
        self.urlClient = urlClient
    }
    
    func fetchStatePopulation() async throws -> StatePopulationResponse {
        let task = try await urlClient.getFrom(urlString: Constants.stateUrl)
        
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
        let sut = PopulationNetworkClient(urlClient: URLClientMock())
        
        try await withMainSerialExecutor {
            let result = try await sut.fetchStatePopulation()
            
            XCTAssertNotNil(result)
        }
    }
    
    func test_fetches_and_parses_error() async throws {
        let urlClient = URLClientMock()
        urlClient.wrongURL = URL(string: "http://wrong.url.com")
        
        let sut = PopulationNetworkClient(urlClient: urlClient)
        
        await withMainSerialExecutor {
            do {
                let result = try await sut.fetchStatePopulation()
                XCTAssertNil(result)
            } catch {
                XCTAssertNotNil(error)
            }
        }
    }

}
