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

protocol YearlyPopulationViewModelDelegate: AnyObject {}


class YearlyPopulationViewModel: ObservableObject {
    private weak var delegate: YearlyPopulationViewModelDelegate?
    private let api: YearPopulationAPIProtocol
    @Published var state: ViewState<YearlyListViewModel, AppError>?
    
    init(api: YearPopulationAPIProtocol, delegate: YearlyPopulationViewModelDelegate? = nil) {
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

extension YearlyListViewModel {
    static func makeWith(remote: YearlyPopulationResponse) -> YearlyListViewModel {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        let items = remote.data.compactMap { oneItem in
            let populationString = nf.string(from: NSNumber(integerLiteral: oneItem.population)) ?? String(oneItem.population)
            return OneYearPopulationViewModel(year: oneItem.year,
                                       population: populationString)
        }
        
        return YearlyListViewModel(items: items)
    }
}
