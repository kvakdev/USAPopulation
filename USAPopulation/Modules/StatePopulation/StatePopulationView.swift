//
//  StatePopulationView.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import SwiftUI

struct StatePopulationView: View {
    @ObservedObject var viewModel: StatePopulationViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .none:
                ProgressView()
            case .loaded(let value):
                GeometryReader(content: { geometry in
                    if geometry.size.width > 500 {
                        makeGridView(value: value)
                    } else {
                        makeListView(value: value)
                    }
                })
            case .error(let err):
                makeRetryButton(err: err)
            }
        }
        .onFirstAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .navigationTitle("US Population by state")
    }
    
    @ViewBuilder
    func makeGridView(value: PopulationViewModel) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(minimum: 200)), GridItem(.flexible(minimum: 200))], content: {
                ForEach(value.items, id: \.state) { item in
                    HStack {
                        Text(item.state.capitalized)
                            .font(.title)
                            .bold()
                        Text("-")
                        Text(item.population)
                            .font(.title2)
                        Spacer()
                    }
                    .padding(.leading, 32)
                }
            })
        }
    }
    
    @ViewBuilder
    func makeListView(value: PopulationViewModel) -> some View {
        List {
            ForEach(value.items, id: \.state) { item in
                makeRow(item)
            }
        }
        .padding(.bottom)
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    func makeRow(_ item: OneStatePopulationViewModel) -> some View {
        HStack {
            Text(item.state.capitalized)
                .font(.headline)
            Text("-")
            Text(item.population)
            Spacer()
        }
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
        StatePopulationView(viewModel: StatePopulationViewModel(api: PreviewNetworkClient(), delegate: nil))
    }
}

#Preview("Error state") {
    NavigationStack {
        StatePopulationView(viewModel: StatePopulationViewModel(api: FailingClient(), delegate: nil))
    }
}
