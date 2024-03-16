//
//  YearlyPopulationView.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import SwiftUI

struct YearlyPopulationView: View {
    var viewModel: YearlyPopulationViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .none:
                ProgressView()
            case .loaded(let value):
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
            case .error(let err):
                VStack {
                    Text("Error occured: \(err.localizedDescription)")
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
        .task {
            await viewModel.onAppear()
        }
        .navigationTitle("US Population")
    }
}

#Preview {
    NavigationStack {
        YearlyPopulationView(viewModel: YearlyPopulationViewModel(api: PreviewNetworkClient()))
    }
}
