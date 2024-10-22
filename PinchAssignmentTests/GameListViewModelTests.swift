//
//  GameListViewModelTests.swift
//  PinchAssignmentTests
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class GameListViewModelTests: XCTestCase {
    private let env = Environment()
    
    func test_init_gamesStateIsLoadingByDefault() {
        XCTAssertEqual(makeSUT().gamesState, .loading)
    }
    
    func test_init_startsLoadingGames() {
        _ = makeSUT()
        
        XCTAssertEqual(env.loaderSpy.loadGamesCallCount, 1)
    }
}

private extension GameListViewModelTests {
    struct Environment {
        let loaderSpy = GamesLoaderSpy()
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> GameListViewModel {
        let sut = GameListViewModel(gamesLoader: env.loaderSpy)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

private class GamesLoaderSpy: GamesLoader {
    private(set) var loadGamesCallCount: Int = 0
    
    func loadGames() -> AnyPublisher<[Game], Error> {
        loadGamesCallCount += 1
        return Empty().eraseToAnyPublisher()
    }
}
