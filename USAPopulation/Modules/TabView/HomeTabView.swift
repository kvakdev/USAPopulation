//
//  HomeTabView.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 17/03/2024.
//

import SwiftUI

struct HomeTabView<LeftView: View, RightView: View>: View {
    let viewModel: HomeTabViewModel
    var makeLeftView: LeftView
    var makeRightView: RightView
    
    enum Tab {
        case states
        case years
    }
    
    @State var tabState: Tab = .states
    
    var body: some View {
        TabView(selection: $tabState) {
            makeLeftView
                .tag(Tab.states)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("States")
                }
            
            makeRightView
                .tag(Tab.years)
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Years")
                    }
                }
        }
    }
}

#Preview {
    HomeTabView(viewModel: HomeTabViewModel(),
                makeLeftView: StatePopulationView(viewModel: StatePopulationViewModel(api: PreviewNetworkClient())),
                makeRightView: YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: PreviewNetworkClient())))
}
