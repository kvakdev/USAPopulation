//
//  YearlyPopulationView.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import SwiftUI

struct YearlyPopulationView: View {
    @ObservedObject var viewModel: YearlyPopulationViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .none:
                ProgressView()
            case .loaded(let value):
               makeListView(value: value)
            case .error(let err):
               makeRetryButtton(err)
            }
        }
        .onFirstAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .navigationTitle("US Population by year")
    }
    
    @ViewBuilder
    func makeListView(value: YearlyListViewModel) -> some View {
        List {
            ForEach(value.items, id: \.year) { item in
                HStack(spacing: 0) {
                    Text(item.year)
                        .font(.headline)
                        .frame(width: 50, alignment: .leading)
                    
                    Text("-")
                        .padding(.horizontal)
                    
                    Text(item.population)
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    func makeRetryButtton(_ err: AppError) -> some View {
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

#Preview("Loaded") {
    NavigationStack {
        YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: PreviewNetworkClient()))
    }
}

#Preview("Failure") {
    NavigationStack {
        YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: FailingClient()))
    }
}
