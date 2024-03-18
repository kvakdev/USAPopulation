//
//  StatePopulationViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

protocol StatePopulationViewModelDelegate: AnyObject {}

class StatePopulationViewModel: ObservableObject {
    private weak var delegate: StatePopulationViewModelDelegate?
    private let api: StatePopulationAPIProtocol
    @Published var state: ViewState<PopulationViewModel, AppError>?
    
    init(api: StatePopulationAPIProtocol, delegate: StatePopulationViewModelDelegate? = nil) {
        self.api = api
        self.delegate = delegate
    }
    
    func onAppear() async {
        guard state != .loading else { return }
        
        await load()
    }
    
    func handleRetry() async {
        guard state != .loading else { return }
        
        await load()
    }
    
    @MainActor
    private func load() async {
        guard state != .loading else { return }
        
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
