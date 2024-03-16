//
//  PopulationNetworkClienTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import XCTest
@testable import USAPopulation
import ConcurrencyExtras

class URLClientMock: URLClient {
    var wrongURL: URL?
    
    func getFrom(urlString: String) async throws -> (Data, URLResponse) {
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL(urlString)
        }
        let resultURL = wrongURL ?? url
        let urlRequest = URLRequest(url: resultURL)
        
        return try await URLSession.shared.data(for: urlRequest)
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
    
    func test_fetches_and_parses_yearly_correctly() async throws {
        let sut = PopulationNetworkClient(urlClient: URLClientMock())
        
        try await withMainSerialExecutor {
            let result = try await sut.fetchYearlyPopulation()
            
            XCTAssertNotNil(result)
        }
    }
    
}
