//
//  HomeTabViewModel.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 17/03/2024.
//

import Foundation

protocol HomeTabViewModelDelegate: AnyObject {}

final class HomeTabViewModel {
    private weak var delegate: HomeTabViewModelDelegate?
    
    init(delegate: HomeTabViewModelDelegate? = nil) {
        self.delegate = delegate
    }
}
