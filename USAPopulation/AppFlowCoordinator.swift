//
//  AppFlowCoordinator.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 17/03/2024.
//

import UIKit
import SwiftUI

class AppFlowCoordinator {
    let window: UIWindow
    let diContainer: DIContainer
    
    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
    }
    
    func start() {
        let loader = diContainer.makePopulationAPI()

        window.rootViewController = UIHostingController(rootView:
                                                            HomeTabView(viewModel: HomeTabViewModel(delegate: self),
                                                                        makeLeftView:
                                                                            NavigationStack {
            StatePopulationView(viewModel: StatePopulationViewModel(api: loader, delegate: self))
        },
                                                                        makeRightView:
                                                                            NavigationStack {
            YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: loader, delegate: self))
        }
            )
                                                        
        )
        window.makeKeyAndVisible()
    }
}

extension AppFlowCoordinator: HomeTabViewModelDelegate {}
extension AppFlowCoordinator: StatePopulationViewModelDelegate {}
extension AppFlowCoordinator: YearlyPopulationViewModelDelegate {}
