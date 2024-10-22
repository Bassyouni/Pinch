//
//  MainQueueDispatchDecorator.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Combine
import Foundation

public final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    public init(_ decoratee: T) {
        self.decoratee = decoratee
    }
}

extension MainQueueDispatchDecorator: GamesLoader where T: GamesLoader {
    public func loadGames() -> AnyPublisher<[Game], any Error> {
        decoratee.loadGames()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
