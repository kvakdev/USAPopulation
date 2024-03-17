//
//  URLClientImpl.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 17/03/2024.
//

import Foundation

class URLClientImpl: URLClient {

    func getFrom(urlString: String) async throws -> (Data, URLResponse) {
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL(urlString)
        }
        
        let urlRequest = URLRequest(url: url)
        
        return try await URLSession.shared.data(for: urlRequest)
    }
}
