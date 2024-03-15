//
//  PopulationParsingTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import XCTest
@testable import USAPopulation

final class PopulationParsingTests: XCTestCase {

    func testParsesStatePopulation() throws {
        guard let sampleJSON = String.statePopulationJSON.data(using: .utf8) else {
            throw NSError(domain: "JSON Parsing Test. Unable to convert sample json", code: 1)
        }
        
        let response = try JSONDecoder().decode(StatePopulationResponse.self, from: sampleJSON)
        
        XCTAssertNotNil(response)
        XCTAssertEqual(response.data.count, 52)
    }
    
    func testParsesYearlyPopulation() throws {
        guard let sampleJSON = String.yearlyPopulationJSON.data(using: .utf8) else {
            throw NSError(domain: "JSON Parsing Test. Unable to convert sample json", code: 1)
        }
        
        let response = try JSONDecoder().decode(YearlyPopulationResponse.self, from: sampleJSON)
        
        XCTAssertNotNil(response)
        XCTAssertEqual(response.data.count, 9)
    }
}
