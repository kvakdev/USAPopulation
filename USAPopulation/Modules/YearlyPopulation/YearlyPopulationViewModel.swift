//
//  YearlyPopulationViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

struct OneYearPopulationViewModel: Equatable {
    let year: String
    let population: String
}

struct YearlyListViewModel: Equatable {
    let items: [OneYearPopulationViewModel]
}

protocol YearPopulationAPIProtocol {
    func getPopulation() async throws -> YearlyPopulationResponse
}

class YearlyPopulationViewModel: ObservableObject {
    let api: YearPopulationAPIProtocol
    @Published var state: ViewState<YearlyListViewModel, AppError>?
    
    init(api: YearPopulationAPIProtocol) {
        self.api = api
    }
    
    func onAppear() async {
        await load()
    }
    
    func handleRetry() async {
        await load()
    }
    
    @MainActor
    private func load() async {
        state = .loading
        
        do {
            let population = try await self.api.getPopulation()
            state = .loaded(.makeWith(remote: population))
        } catch let error {
            if let err = error as? AppError {
                state = .error(err)
            } else {
                state = .error(.unknown(error.localizedDescription.debugDescription))
            }
        }
    }
}

extension YearlyListViewModel {
    static func makeWith(remote: YearlyPopulationResponse) -> YearlyListViewModel {
        let items = remote.data.compactMap { oneItem in
            OneYearPopulationViewModel(year: oneItem.year,
                                       population: String(oneItem.population) + " people")
        }
        
        return YearlyListViewModel(items: items)
    }
}