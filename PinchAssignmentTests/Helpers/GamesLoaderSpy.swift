//
//  GamesLoaderSpy.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine
import Foundation
import Pinch_Assignment

class GamesLoaderSpy: GamesLoader {
    private var subjects = [PassthroughSubject<[Game], Error>]()
    
    var loadGamesCallCount: Int {
        subjects.count
    }
    
    func loadGames() -> AnyPublisher<[Game], Error> {
        let subject = PassthroughSubject<[Game], Error>()
        subjects.append(subject)
        return subject.eraseToAnyPublisher()
    }

    func send(games: [Game], at index: Int = 0) {
        subjects[index].send(games)
    }
    
    func complete(with games: [Game], at index: Int = 0) {
        subjects[index].send(games)
        subjects[index].send(completion: .finished)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        subjects[index].send(completion: .failure(error))
    }
}
