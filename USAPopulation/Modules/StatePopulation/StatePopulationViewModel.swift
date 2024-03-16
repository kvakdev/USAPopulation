//
//  StatePopulationViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

@Observable
class StatePopulationViewModel {
    let api: StatePopulationAPIProtocol
    var state: ViewState<PopulationViewModel, AppError>?
    
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
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        let items = remote.data.compactMap { oneItem in
            let populationString = nf.string(from: NSNumber(integerLiteral: oneItem.population)) ?? String(oneItem.population)
            
            return OneStatePopulationViewModel(idState: oneItem.idState,
                                               state: oneItem.state,
                                               idYear: oneItem.idYear,
                                               year: oneItem.year,
                                               population: populationString,
                                               slugState: oneItem.slugState)
        }
        
        return PopulationViewModel(items: items)
    }
}
