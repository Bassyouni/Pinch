//
//  HTTPClient.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Combine
import Foundation

public protocol HTTPClient {
    func trigger(_ request: URLRequest) -> AnyPublisher<Data, Error>
}
