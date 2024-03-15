//
//  StatePopulationViewModelTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import XCTest
import Combine
import ConcurrencyExtras
@testable import USAPopulation


class StatePopulationAPIMock: StatePopulationAPIProtocol {
    var messages: [Messages] = []
    
    var stub: StatePopulationResponse?
    
    func set(stub: StatePopulationResponse) {
        self.stub = stub
    }
    
    enum Messages {
        case loadPopulation
    }
    
    func getPopulation() async throws -> StatePopulationResponse {
        messages.append(.loadPopulation)
        
        if let stub = self.stub {
            return stub
        }
        
        throw AppError.network
    }
    
}

final class StatePopulationViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    
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
    
    func test_viewModel_loadDeliversErrorOnApiError() async throws {
        await withMainSerialExecutor {
            let mockAPI = StatePopulationAPIMock()
            let sut = StatePopulationViewModel(api: mockAPI)
            var states = [ViewState<PopulationViewModel, AppError>?]()
            
            sut.$state
                .sink(receiveValue: { newValue in
                states.append(newValue)
            })
            .store(in: &cancellables)
            
            await sut.onAppear()
            
            XCTAssertEqual(states, [nil, .loading, .error(AppError.network)])
        }
    }
    
    func test_viewModel_deliversLoadedResult() async throws {
        await withMainSerialExecutor {
            let mockAPI = StatePopulationAPIMock()
            mockAPI.set(stub: .testValue)
            
            let expectedValue = PopulationViewModel.makeWith(remote: .testValue)
            let sut = StatePopulationViewModel(api: mockAPI)
            var states = [ViewState<PopulationViewModel, AppError>?]()
            
            sut.$state
                .sink(receiveValue: { newValue in
                states.append(newValue)
            })
            .store(in: &cancellables)
            
            await sut.onAppear()
            
            XCTAssertEqual(states, [nil, .loading, .loaded(expectedValue)])
        }
    }
    
    func test_viewModelTriggersLoad_onRetry() async throws {
        await withMainSerialExecutor {
            let mockAPI = StatePopulationAPIMock()
            let expectedValue = PopulationViewModel.makeWith(remote: .testValue)
            
            let sut = StatePopulationViewModel(api: mockAPI)
            var states = [ViewState<PopulationViewModel, AppError>?]()
            
            sut.$state
                .sink(receiveValue: { newValue in
                states.append(newValue)
            })
            .store(in: &cancellables)
            
            await sut.onAppear()
            XCTAssertEqual(states, [nil, .loading, .error(.network)])

            mockAPI.set(stub: .testValue)
            await sut.handleRetry()
            XCTAssertEqual(states, [nil, .loading, .error(.network), .loading, .loaded(expectedValue)])
        }
    }
}

extension StatePopulationResponse {
    static var testValue: StatePopulationResponse {
        return .init(data: [.testValue])
    }
}
extension StatePopulation {
    static var testValue: StatePopulation {
        StatePopulation(idState: "1",
                        state: "A",
                        idYear: 1,
                        year: "2024",
                        population: 1,
                        slugState: "A")
    }
}
