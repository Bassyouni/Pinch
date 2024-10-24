//
//  GameDetailsViewModelTests.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class GameDetailsViewModelTests: XCTestCase {
    private let env = Environment()
    private var cancellables = Set<AnyCancellable>()
}

private extension GameDetailsViewModelTests {
    struct Environment {}
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> GameDetailsViewModel {
        let sut = GameDetailsViewModel(game: .uniqueStub())
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func copyGame(from game: Game, newURL url: String) -> Game {
        Game(
            id: game.id,
            name: game.name,
            coverURL: URL(string: url)!,
            summary: game.summary,
            rating: game.rating,
            platforms: game.platforms,
            genres: game.genres,
            videosIDs: game.videosIDs
        )
    }
}
