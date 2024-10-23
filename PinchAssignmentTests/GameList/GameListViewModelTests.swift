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
    private var cancellables = Set<AnyCancellable>()
    
    func test_init_gamesStateIsLoadingByDefault() {
        XCTAssertEqual(makeSUT().gamesState, .loading)
    }
    
    func test_init_startsLoadingGames() {
        _ = makeSUT()
        
        XCTAssertEqual(env.loaderSpy.loadGamesCallCount, 1)
    }
    
    func test_loadGames_onReceivingError_setsStateToErrorWithMessage() {
        let sut = makeSUT()
        
        env.loaderSpy.complete(with: anyError)
        
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
    
    func test_refreshGames_loadsGamesAgainAndTerminatesOldPublisher() {
        let sut = makeSUT()
        let initialPublisherGames = [Game.uniqueStub(), .uniqueStub()]
        let refreshPublisherGames = [Game.uniqueStub(), .uniqueStub()]
        let newerRefreshPublisherGames = [Game.uniqueStub(), .uniqueStub()]
        env.loaderSpy.send(games: initialPublisherGames, at: 0)

        sut.refreshGames()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)

        env.loaderSpy.send(games: refreshPublisherGames, at: 1)
        XCTAssertEqual(sut.gamesState, .loaded(refreshPublisherGames))
        
        env.loaderSpy.send(games: initialPublisherGames, at: 0)
        XCTAssertEqual(sut.gamesState, .loaded(refreshPublisherGames), "Expected inital publisher to be terminated")
        
        env.loaderSpy.send(games: newerRefreshPublisherGames, at: 1)
        XCTAssertEqual(sut.gamesState, .loaded(refreshPublisherGames + newerRefreshPublisherGames))
    }
    
    func test_refreshGames_loadsGamesAgainAndNotifesCaller() {
        let sut = makeSUT()
        env.loaderSpy.send(games: [.uniqueStub()], at: 0)
        let exp = expectation(description: "Expected refesh to be done")
        
        sut.refreshGames()
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: {})
            .store(in: &cancellables)
        env.loaderSpy.send(games: [.uniqueStub()], at: 1)

        wait(for: [exp], timeout: 0.1)
    }
    
    func test_didSelectGame_coordinateToGameDetails() {
        let sut = makeSUT()
        let game1 = Game.uniqueStub()
        let game2 = Game.uniqueStub()
        
        sut.didSelectGame(game1)
        sut.didSelectGame(game2)
        
        XCTAssertEqual(env.coordinate.directions, [.gameDetails(game1), .gameDetails(game2)])
    }
}

private extension GameListViewModelTests {
    struct Environment {
        let loaderSpy = GamesLoaderSpy()
        let coordinate = CoordinateSpy()
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> GameListViewModel {
        let sut = GameListViewModel(gamesLoader: env.loaderSpy, coordinate: env.coordinate.closure)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

final class CoordinateSpy {
    var directions: [GameListViewTransition] = []
    private(set) lazy var closure: (GameListViewTransition) -> Void = {
        { self.directions.append($0) }
    }()
}
