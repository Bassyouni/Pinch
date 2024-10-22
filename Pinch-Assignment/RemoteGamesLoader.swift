//
//  RemoteGamesLoader.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Combine
import Foundation

public protocol HTTPClient {
    func post(request: URLRequest) -> Result<Data, Error>
}

final public class RemoteGamesLoader {
    private let client: HTTPClient
 
    public init(client: HTTPClient) {
        self.client = client
    }
    
    func loadGames() -> AnyPublisher<[Game], Error> {
        return Empty().eraseToAnyPublisher()
    }
}
