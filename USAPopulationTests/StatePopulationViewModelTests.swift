//
//  StatePopulationViewModelTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import XCTest
import Combine

struct Population: Equatable {}

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

enum ViewState<V: Equatable, E: Equatable>: Equatable {
    case loading
    case loaded(V)
    case error(E)
}

enum AppError: Error, Equatable {
    case network
}

@Observable
class StatePopulationViewModel {
    let api: StatePopulationAPIProtocol
    
    var state: ViewState<Population, AppError>?
    
    init(api: StatePopulationAPIProtocol) {
        self.api = api
    }
    
    func onAppear() async {
        do {
            state = .loading
            let population = try await self.api.getPopulation()
        } catch {
            
        }
    }
}

final class StatePopulationViewModelTests: XCTestCase {
    
    var cancellables: [AnyCancellable] = []
    
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
    
    func test_viewModel_loadIsTriggered() async throws {
        let mockAPI = StatePopulationAPIMock()
        let sut = StatePopulationViewModel(api: mockAPI)
        await sut.onAppear()
        var states = [ViewState<Population, AppError>]()
        
        sut.state.publisher.sink { newValue in
            states.append(newValue)
        }
        
        XCTAssertEqual(states, [.loading])
    }
}
