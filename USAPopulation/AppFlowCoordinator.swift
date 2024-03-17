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
    
    //This is just to showcase how I would handle navigation from the coordinator,
    let stateNavController: UINavigationController = UINavigationController()
    let yearNavController: UINavigationController = UINavigationController()
    
    //we can present whatever we want upon delegate actions
    let tabbarController = UITabBarController()
    
    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
    }
    
    func start() {
        let loader = diContainer.makePopulationAPI()

        stateNavController.setViewControllers([
            UIHostingController(rootView: StatePopulationView(viewModel: StatePopulationViewModel(api: loader, delegate: self)))
        ], animated: false)
        stateNavController.tabBarItem = UITabBarItem(title: "State", image: UIImage(systemName: "map.fill"), tag: 1)
        stateNavController.navigationBar.prefersLargeTitles = true
        
        yearNavController.setViewControllers([
            UIHostingController(rootView: YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: loader, delegate: self)))
        ], animated: false)
        yearNavController.tabBarItem = UITabBarItem(title: "Year", image: UIImage(systemName: "calendar"), tag: 2)
        yearNavController.navigationBar.prefersLargeTitles = true
        
        tabbarController.viewControllers = [
            stateNavController,
            yearNavController
        ]
       
        window.rootViewController = tabbarController
        
        window.makeKeyAndVisible()
    }
}

extension AppFlowCoordinator: StatePopulationViewModelDelegate {}
extension AppFlowCoordinator: YearlyPopulationViewModelDelegate {}
