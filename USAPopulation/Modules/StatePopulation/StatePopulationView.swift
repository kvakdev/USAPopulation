//
//  StatePopulationView.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import SwiftUI

struct StatePopulationView: View {
    var viewModel: StatePopulationViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .none:
                ProgressView()
            case .loaded(let value):
                makeListView(value: value)
            case .error(let err):
                makeRetryButton(err: err)
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .navigationTitle("US Population by state")
    }
    
    @ViewBuilder
    func makeListView(value: PopulationViewModel) -> some View {
        List {
            ForEach(value.items, id: \.state) { item in
                HStack {
                    Text(item.state.capitalized)
                        .font(.headline)
                    Spacer()
                    Text("-")
                    Text(item.population)
                }
            }
        }
        .padding(.bottom)
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    func makeRetryButton(err: AppError) -> some View {
        VStack {
            Text("Error occured: \(err.readableDescription)")
            Button(action: {
                Task {
                    await viewModel.handleRetry()
                }
            }, label: {
                Text("Try again")
            })
        }
    }
}

#Preview("Loaded state") {
    NavigationStack {
        StatePopulationView(viewModel: StatePopulationViewModel(api: PreviewNetworkClient()))
    }
}

#Preview("Error state") {
    NavigationStack {
        StatePopulationView(viewModel: StatePopulationViewModel(api: FailingClient()))
    }
}
