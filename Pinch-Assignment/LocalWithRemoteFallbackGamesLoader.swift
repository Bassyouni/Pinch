//
//  LocalWithRemoteFallbackGamesLoader.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine

public final class LocalWithRemoteFallbackGamesLoader: GamesLoader {
    private let store: GamesLoader & GamesSaver
    private let remote: GamesLoader
    private var cancellables = Set<AnyCancellable>()
    
    public init(store: GamesLoader & GamesSaver, remote: GamesLoader) {
        self.store = store
        self.remote = remote
    }
    
    public func loadGames() -> AnyPublisher<[Game], Error> {
        return self.store.loadGames()
            .flatMap { games in
                if !games.isEmpty {
                    return Just(games)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.remote.loadGames()
                    .handleEvents(receiveOutput:  { games in
                        self.store.saveGames(games)
                            .sink { _ in } receiveValue: { _ in }
                            .store(in: &self.cancellables)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
