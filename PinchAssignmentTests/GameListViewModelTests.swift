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
    
    func test_loadGames_onReceivingNewGames_setsStateToLoadedWithNewGamesAppendedToWhatWasAlreadyThere() {
        let sut = makeSUT()
        
        let initalGames = [Game.uniqueStub(), .uniqueStub()]
        env.loaderSpy.send(games: initalGames)
        XCTAssertEqual(sut.gamesState, .loaded(initalGames))
        
        let newGames = [Game.uniqueStub(), .uniqueStub()]
        env.loaderSpy.send(games: newGames)
        XCTAssertEqual(sut.gamesState, .loaded(initalGames + newGames))
    }
    
    func test_loadGames_onReceivingNewGames_prefixCoverURLWithHTTPs() {
        let sut = makeSUT()
        let urlWithNoPrefix = "//www.url.com"
        let urlWithPrefix = "https://www.url.com"
        let games = [Game.uniqueStub(url: urlWithNoPrefix), .uniqueStub(url: urlWithPrefix)]
        
        env.loaderSpy.send(games: games)
        
        let expectedGames = games.map { Game(id: $0.id, name: $0.name, coverURL: URL(string: urlWithPrefix)!) }
        XCTAssertEqual(sut.gamesState, .loaded(expectedGames))
    }
    
    func test_loadGames_onReceivingNewGames_replacesCoverURLSizeToSizeThatFitsGamesList() {
        let sut = makeSUT()
        let validSizeURL = "https://www.url.com/path/t_cover_med/photoName.jpg"
        let otherSizeURL1 = "https://www.url.com/path/t_thumb/photoName.jpg"
        let otherSizeURL2 = "https://www.url.com/path/t_cover_small/photoName.jpg"
        
        let games = [Game.uniqueStub(url: otherSizeURL1), .uniqueStub(url: otherSizeURL2)]
        
        env.loaderSpy.send(games: games)
        
        let expectedGames = games.map { Game(id: $0.id, name: $0.name, coverURL: URL(string: validSizeURL)!) }
        XCTAssertEqual(sut.gamesState, .loaded(expectedGames))
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

extension Game {
    static func uniqueStub(url: String? = nil) -> Game {
        let id = UUID().uuidString
        return Game(id: id, name: id, coverURL: URL(string: url ?? "https://www.url.com")!)
    }
}
