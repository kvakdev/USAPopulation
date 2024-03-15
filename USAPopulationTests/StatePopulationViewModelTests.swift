//
//  StatePopulationViewModelTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import XCTest

struct Population {}

protocol StatePopulationAPIProtocol {
    func getPopulation() async throws -> Population
}

class StatePopulationAPIMock: StatePopulationAPIProtocol {
    var messages: [Messages] = []
    
    enum Messages {
        case loadPopulation
    }
    
    func getPopulation() async throws -> Population {
        messages.append(.loadPopulation)
        
        throw NSError(domain: "test_error", code: 0)
    }
}


class StatePopulationViewModel {
    let api: StatePopulationAPIProtocol
    
    init(api: StatePopulationAPIProtocol) {
        self.api = api
    }
    
    func onAppear() async {
        do {
            let population = try await self.api.getPopulation()
        } catch {
            
        }
    }
}

final class StatePopulationViewModelTests: XCTestCase {
    
    func test_viewModel_doesNothing_onInit() async throws {
        let mockAPI = StatePopulationAPIMock()
        let sut = StatePopulationViewModel(api: mockAPI)
        
        XCTAssertEqual(mockAPI.messages, [])
    }
    
    func test_viewModel_startsLoadOnAppear() async throws {
        let mockAPI = StatePopulationAPIMock()
        let sut = StatePopulationViewModel(api: mockAPI)
        await sut.onAppear()
        
        XCTAssertEqual(mockAPI.messages, [.loadPopulation])
    }
}
