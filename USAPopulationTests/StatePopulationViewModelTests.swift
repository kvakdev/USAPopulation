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
    
    var stub: StatePopulation?
    
    func set(stub: StatePopulation) {
        self.stub = stub
    }
    
    enum Messages {
        case loadPopulation
    }
    
    func getPopulation() async throws -> StatePopulation {
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
            var states = [ViewState<PopulationViewModel, AppError>]()
            
            sut.$state
                .sink(receiveValue: { newValue in
                states.append(newValue)
            })
            .store(in: &cancellables)
            
            await sut.onAppear()
            
            
            XCTAssertEqual(states, [.empty, .loading, .error(AppError.network)])
        }
    }
    
    func test_viewModel_deliversLoadedResult() async throws {
        await withMainSerialExecutor {
            let mockAPI = StatePopulationAPIMock()
            let stub = StatePopulation(id: "1")
            mockAPI.set(stub: stub)
            
            let sut = StatePopulationViewModel(api: mockAPI)
            var states = [ViewState<PopulationViewModel, AppError>]()
            
            sut.$state
                .sink(receiveValue: { newValue in
                states.append(newValue)
            })
            .store(in: &cancellables)
            
            await sut.onAppear()
            
            
            XCTAssertEqual(states, [.empty, .loading, .loaded(PopulationViewModel(id: stub.id))])
        }
    }
}
