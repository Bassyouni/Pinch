//
//  GamesMapper.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Combine
import Foundation

internal final class GamesMapper {
    private struct GameDTO: Decodable {
        let id: Double
        let name: String
        let cover: CoverDTO
    }
    
    private struct CoverDTO: Decodable {
        let url: URL
    }
    
    static func map(data: Data) -> AnyPublisher<[Game], RemoteGamesLoader.Error> {
        guard let dtos = try? JSONDecoder().decode([GameDTO].self, from: data) else {
            return Fail(error: RemoteGamesLoader.Error.invalidData).eraseToAnyPublisher()
        }
        
        let games = dtos.map { Game(id: "\($0.id)", name: $0.name, coverURL: $0.cover.url) }
        
        return Just(games)
            .setFailureType(to: RemoteGamesLoader.Error.self)
            .eraseToAnyPublisher()
    }
}
