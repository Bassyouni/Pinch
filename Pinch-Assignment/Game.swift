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
    
    public init(id: String, name: String, coverURL: URL) {
        self.id = id
        self.name = name
        self.coverURL = coverURL
    }
}
