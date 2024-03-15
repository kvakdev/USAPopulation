//
//  ViewState.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

enum ViewState<Value: Equatable, Err: Equatable>: Equatable {
    case loading
    case loaded(Value)
    case error(Err)
}
