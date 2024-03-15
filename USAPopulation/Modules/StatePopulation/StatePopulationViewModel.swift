//
//  StatePopulationViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

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
