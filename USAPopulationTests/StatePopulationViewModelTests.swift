//
//  StatePopulationViewModelTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import XCTest
import Combine
import CombineSchedulers
import ConcurrencyExtras

struct Population: Equatable {}

protocol StatePopulationAPIProtocol {
    func getPopulation() async throws -> Population
}

class StatePopulationAPIMock: StatePopulationAPIProtocol {
    var messages: [Messages] = []
    
    var stub: Population?
    
    func set(stub: Population) {
        self.stub = stub
    }
    
    enum Messages {
        case loadPopulation
    }
    
    func getPopulation() async throws -> Population {
        messages.append(.loadPopulation)

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
    
    @Published var state: ViewState<Population, AppError>
    var scheduler: any Scheduler
    
    init(api: StatePopulationAPIProtocol, scheduler: any Scheduler) {
        self.api = api
        self.scheduler = scheduler
        self.state = .empty
    }
    
    @MainActor
    func onAppear() async {
        state = .loading
        
        do {
            let population = try await self.api.getPopulation()
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
    var scheduler = TestSchedulerOf<DispatchQueue>(now: .init(.now()))
    
    func test_viewModel_doesNothing_onInit() async throws {
        let mockAPI = StatePopulationAPIMock()
        let sut = StatePopulationViewModel(api: mockAPI, scheduler: scheduler)
        
        XCTAssertEqual(mockAPI.messages, [])
    }
    
    func test_viewModel_startsLoadOnAppear() async throws {
        let mockAPI = StatePopulationAPIMock()
        let sut = StatePopulationViewModel(api: mockAPI, scheduler: scheduler)
        await sut.onAppear()
        
        XCTAssertEqual(mockAPI.messages, [.loadPopulation])
    }
    
    func test_viewModel_loadIsTriggered() async throws {
        await withMainSerialExecutor {
            let mockAPI = StatePopulationAPIMock()
            let stub = Population()
            mockAPI.set(stub: stub)
            
            let sut = StatePopulationViewModel(api: mockAPI, scheduler: scheduler)
            var states = [ViewState<Population, AppError>]()
            
            sut.$state
                .sink(receiveValue: { newValue in
                states.append(newValue)
            })
            .store(in: &cancellables)
            
            await sut.onAppear()
            
            
            XCTAssertEqual(states, [.empty, .loading, .error(AppError.network)])
        }
    }
}
