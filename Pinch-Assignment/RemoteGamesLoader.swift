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
    private let url: URL
    private let client: HTTPClient
 
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func loadGames() -> AnyPublisher<[Game], Error> {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = client.post(request: request)
        return Empty().eraseToAnyPublisher()
    }
}
