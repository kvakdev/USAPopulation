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

struct PopulationViewModel: Equatable {
    let id: String
}

protocol StatePopulationAPIProtocol {
    func getPopulation() async throws -> StatePopulation
}

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

enum ViewState<V: Equatable, E: Equatable>: Equatable {
    case loading
    case loaded(V)
    case error(E)
    case empty
}

enum AppError: Error, Equatable {
    case network
    case decodingError
    case unknown(String)
}


class StatePopulationViewModel: ObservableObject {
    let api: StatePopulationAPIProtocol
    @Published var state: ViewState<PopulationViewModel, AppError>
    
    init(api: StatePopulationAPIProtocol) {
        self.api = api
        self.state = .empty
    }
    
    @MainActor
    func onAppear() async {
        state = .loading
        
        do {
            let population = try await self.api.getPopulation()
            state = .loaded(.init(id: population.id))
        } catch let error {
            if let err = error as? AppError {
                state = .error(err)
            } else {
                state = .error(.unknown(error.localizedDescription.debugDescription))
            }
        }
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
