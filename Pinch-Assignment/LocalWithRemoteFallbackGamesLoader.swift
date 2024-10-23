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
        let store = self.store
        let remote = self.remote
        var cancellables = self.cancellables
        
        return store.loadGames()
            .catch({ _ in
                remote.loadGames()
            })
            .flatMap { games in
                if !games.isEmpty {
                    return Just(games)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return remote.loadGames()
                    .handleEvents(receiveOutput:  { games in
                        store.saveGames(games)
                            .sink { _ in } receiveValue: { _ in }
                            .store(in: &cancellables)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
