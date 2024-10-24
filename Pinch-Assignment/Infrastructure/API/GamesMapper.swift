//
//  GamesMapper.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Combine
import Foundation

internal final class GamesMapper {
    static func map(data: Data) -> AnyPublisher<[Game], RemoteGamesLoader.Error> {
        guard let dtos = try? JSONDecoder().decode([GameDTO].self, from: data) else {
            return Fail(error: RemoteGamesLoader.Error.invalidData).eraseToAnyPublisher()
        }
        
        let games = dtos.map { Game(
            id: "\($0.id)",
            name: $0.name,
            coverURL: $0.cover.url,
            summary: $0.summary,
            rating: $0.rating,
            platforms: $0.platforms.map { $0.name },
            genres: $0.genres.map { $0.name },
            videosIDs: $0.videos?.map { $0.video_id }
        )}
        
        return Just(games)
            .setFailureType(to: RemoteGamesLoader.Error.self)
            .eraseToAnyPublisher()
    }
    
    private struct GameDTO: Decodable {
        let id: Double
        let name: String
        let summary: String
        let cover: CoverDTO
        let rating: Double
        let genres: [GenereDTO]
        let platforms: [PlatformDTO]
        let videos: [VideoDTO]?
    }
    
    private struct CoverDTO: Decodable {
        let url: URL
    }
    
    private struct GenereDTO: Decodable {
        let name: String
    }
    
    private struct PlatformDTO: Decodable {
        let name: String
    }
    
    private struct VideoDTO: Decodable {
        let video_id: String
    }
}
