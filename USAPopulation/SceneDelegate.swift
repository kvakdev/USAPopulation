//
//  SceneDelegate.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
   
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let loader = PopulationNetworkClient(urlClient: URLClientImpl())
        

        window.rootViewController = UIHostingController(rootView:
                                                            HomeTabView(viewModel: HomeTabViewModel(),
                                                                        makeLeftView:
                                                                            NavigationStack {
            StatePopulationView(viewModel: StatePopulationViewModel(api: loader))
        },
                                                                        makeRightView:
                                                                            NavigationStack {
            YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: loader))
        }
            )
                                                        
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}

