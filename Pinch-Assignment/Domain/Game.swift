//
//  Game.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Foundation

public struct Game: Equatable, Hashable {
    public let id: String
    public let name: String
    public let coverURL: URL
    public let summary: String
    public let rating: Double
    public let platforms: [String]?
    public let genres: [String]?
    public let videosIDs: [String]?
    
    public init(
        id: String,
        name: String,
        coverURL: URL,
        summary: String,
        rating: Double,
        platforms: [String]?,
        genres: [String]?,
        videosIDs: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.coverURL = coverURL
        self.summary = summary
        self.rating = rating
        self.platforms = platforms
        self.genres = genres
        self.videosIDs = videosIDs
    }
}
