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
    private let clientID: String
    private let bearerToken: String
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case networkError
        case invalidData
    }
 
    public init(url: URL, clientID: String, bearerToken: String, client: HTTPClient) {
        self.url = url
        self.clientID = clientID
        self.bearerToken = bearerToken
        self.client = client
    }
    
    public func loadGames() -> AnyPublisher<[Game], Swift.Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        addNeededHeaders(to: &request)
        addBody(to: &request)
    
        do  {
            _ = try client.post(request: request).get()
            return Fail(error: Error.invalidData).eraseToAnyPublisher()
        } catch {
            return Fail(error: Error.networkError).eraseToAnyPublisher()
        }
    }
    
    private func addNeededHeaders(to request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue(clientID, forHTTPHeaderField: "Client-ID")
    }
    
    private func addBody(to request: inout URLRequest) {
        let sorting = "sort rating desc"
        
        let neededFields = ["first_release_date", "rating", "name", "cover.url"]
        let fields = "fields \(neededFields.joined(separator: ","))"
        
        request.httpBody = "\(fields);\(sorting);".data(using: .utf8, allowLossyConversion: false)
    }
}
