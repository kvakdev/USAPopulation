//
//  YearlyViewModelTests.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import XCTest
import Combine
import ConcurrencyExtras
@testable import USAPopulation


class YearlyPopulationAPIMock: YearPopulationAPIProtocol {
 
    
    var messages: [Messages] = []
    
    var stub: YearlyPopulationResponse?
    
    func set(stub: YearlyPopulationResponse) {
        self.stub = stub
    }
    
    enum Messages {
        case loadPopulation
    }
    func getPopulation() async throws -> USAPopulation.YearlyPopulationResponse {
        messages.append(.loadPopulation)
        
        if let stub = self.stub {
            return stub
        }
        
        throw AppError.network
    }
}

final class YearlyViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    
    func test_viewModel_doesNothing_onInit() async throws {
        let mockAPI = YearlyPopulationAPIMock()
        let sut = YearlyPopulationViewModel(api: mockAPI)
        
        XCTAssertEqual(mockAPI.messages, [])
    }
    
    func test_viewModel_startsLoadOnAppear() async throws {
        let mockAPI = YearlyPopulationAPIMock()
        let sut = YearlyPopulationViewModel(api: mockAPI)
        await sut.onAppear()
        
        XCTAssertEqual(mockAPI.messages, [.loadPopulation])
    }
    
    func test_viewModel_loadDeliversErrorOnApiError() async throws {
        await withMainSerialExecutor {
            let mockAPI = YearlyPopulationAPIMock()
            let sut = YearlyPopulationViewModel(api: mockAPI)
            var states = [ViewState<YearlyListViewModel, AppError>?]()
            
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
            let mockAPI = YearlyPopulationAPIMock()
            mockAPI.set(stub: .testValue)
            
            let expectedValue = YearlyListViewModel.makeWith(remote: .testValue)
            let sut = YearlyPopulationViewModel(api: mockAPI)
            var states = [ViewState<YearlyListViewModel, AppError>?]()
            
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
            let mockAPI = YearlyPopulationAPIMock()
            let expectedValue = YearlyListViewModel.makeWith(remote: .testValue)
            
            let sut = YearlyPopulationViewModel(api: mockAPI)
            var states = [ViewState<YearlyListViewModel, AppError>?]()
            
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


extension YearlyPopulationResponse {
    static var testValue: YearlyPopulationResponse {
        return .init(data: [.testValue])
    }
}
extension YearPopulation {
    static var testValue: YearPopulation {
        YearPopulation(idYear: 1,
                       year: "2024",
                       population: 1)
    }
}
