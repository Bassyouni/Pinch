//
//  LocalWithRemoteFallbackGamesLoader.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine

public final class LocalWithRemoteFallbackGamesLoader {
    private let store: GamesLoader & GamesSaver
    private let remote: GamesLoader
    
    public init(store: GamesLoader & GamesSaver, remote: GamesLoader) {
        self.store = store
        self.remote = remote
    }
}
