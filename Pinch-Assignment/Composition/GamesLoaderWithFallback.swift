//
//  GamesLoaderWithFallback.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine

public final class GamesLoaderWithFallback {
    private let store: GamesLoader & GamesSaver
    private let remote: GamesLoader
    private var cancellables = Set<AnyCancellable>()
    
    public init(store: GamesLoader & GamesSaver, remote: GamesLoader) {
        self.store = store
        self.remote = remote
    }
    
    private func loadFromRemoteAndSaveToStore() -> AnyPublisher<[Game], Error> {
        remote.loadGames()
            .handleEvents(receiveOutput: { [weak self] games in
                self?.saveGames(games)
            })
            .eraseToAnyPublisher()
    }
    
    private func saveGames(_ games: [Game]) {
        store.saveGames(games)
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

extension GamesLoaderWithFallback: GamesLoader {
    public func loadGames() -> AnyPublisher<[Game], Error> {
        let loadFromRemote = self.loadFromRemoteAndSaveToStore
        
        return store.loadGames()
            .catch { _ in loadFromRemote() }
            .flatMap { games in
                if games.isEmpty {
                    return loadFromRemote()
                }
                
                return Just(games)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension GamesLoaderWithFallback: GamesRefreshable {
    public func refreshGames() -> AnyPublisher<[Game], any Error> {
        let store = store
        
        return remote.loadGames()
            .handleEvents(receiveOutput: { [weak self] games in
                self?.saveGames(games)
            })
            .catch { [store] _ in
                return store.loadGames()
            }
            .eraseToAnyPublisher()
    }
}
