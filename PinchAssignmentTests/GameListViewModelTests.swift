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
    
    func test_loadGames_onReceivingError_setsStateToErrorWithMessage() {
        let sut = makeSUT()
        
        env.loaderSpy.finishLoadGamesWithError()
        
        let expectedErrorMessage = "Unable to load games"
        XCTAssertEqual(sut.gamesState, .error(message: expectedErrorMessage))
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
    private var loadGamesSubjects = [PassthroughSubject<[Game], Error>]()
    
    var loadGamesCallCount: Int {
        loadGamesSubjects.count
    }
    
    func loadGames() -> AnyPublisher<[Game], Error> {
        let subject = PassthroughSubject<[Game], Error>()
        loadGamesSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    
    func finishLoadGamesWithError(at index: Int = 0) {
        loadGamesSubjects[index].send(completion: .failure(NSError(domain: "Test", code: 1)))
    }
}
