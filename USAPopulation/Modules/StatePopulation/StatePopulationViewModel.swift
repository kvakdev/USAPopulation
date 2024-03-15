//
//  StatePopulationViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

class StatePopulationViewModel: ObservableObject {
    let api: StatePopulationAPIProtocol
    @Published var state: ViewState<PopulationViewModel, AppError>?
    
    init(api: StatePopulationAPIProtocol) {
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

extension PopulationViewModel {
    static func makeWith(remote: StatePopulationResponse) -> PopulationViewModel {
        let items = remote.data.compactMap { oneItem in
            OneStatePopulationViewModel(idState: oneItem.idState,
                                        state: oneItem.state,
                                        idYear: oneItem.idYear,
                                        year: oneItem.year,
                                        population: oneItem.population,
                                        slugState: oneItem.slugState)
        }
        
        return PopulationViewModel(items: items)
    }
}
