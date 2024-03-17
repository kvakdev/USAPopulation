//
//  SceneDelegate.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var coordinator: AppFlowCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
   
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let container = DIContainer(
            makePopulationAPI: { PopulationNetworkClient(urlClient: URLClientImpl()) }
        )
        self.coordinator = AppFlowCoordinator(window: window, diContainer: container)
        self.coordinator.start()
    }
    
}

