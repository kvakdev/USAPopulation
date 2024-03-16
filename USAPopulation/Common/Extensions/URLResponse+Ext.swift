//
//  URLResponse+Ext.swift
//  USAPopulation
//
//  Created by Andrii Kvashuk on 16/03/2024.
//

import Foundation

extension URLResponse {
    var isOK: Bool {
        return (self as? HTTPURLResponse)?.statusCode == 200
    }
}
