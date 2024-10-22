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
    
    func test_loadGames_onReceivingGames_setsStateToLoadedWithGames() {
        let sut = makeSUT()
        let games = [
            Game(id: "1", name: "any 1", coverURL: URL(string: "www.any.com")!),
            Game(id: "2", name: "any 2", coverURL: URL(string: "www.any.com")!),
            Game(id: "3", name: "any 3", coverURL: URL(string: "www.any.com")!)
        ]
        
        env.loaderSpy.send(games: games)
        
        XCTAssertEqual(sut.gamesState, .loaded(games))
    }
    
    func test_loadGames_onReceivingNewGames_setsStateToLoadedWithNewGamesAppendedToWhatWasAlreadyThere() {
        let sut = makeSUT()
        
        let initalGames = [Game(id: "1", name: "any 1", coverURL: URL(string: "www.any.com")!)]
        env.loaderSpy.send(games: initalGames)
        XCTAssertEqual(sut.gamesState, .loaded(initalGames))
        
        let newGames = [
            Game(id: "2", name: "any 1", coverURL: URL(string: "www.any.com")!),
            Game(id: "3", name: "any 1", coverURL: URL(string: "www.any.com")!)
        ]
        env.loaderSpy.send(games: newGames)
        XCTAssertEqual(sut.gamesState, .loaded(initalGames + newGames))
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
    
    func send(games: [Game], at index: Int = 0) {
        loadGamesSubjects[index].send(games)
    }
}
