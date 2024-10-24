//
//  GamesListViewModelTests.swift
//  PinchAssignmentTests
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class GamesListViewModelTests: XCTestCase {
    private let env = Environment()
    private var cancellables = Set<AnyCancellable>()
    
    func test_init_gamesStateIsloadedWithEmptyDataByDefault() {
        XCTAssertEqual(makeSUT().gamesState, .loaded([]))
    }
    
    func test_init_doesNoting() {
        _ = makeSUT()
        
        XCTAssertEqual(env.loaderSpy.loadGamesCallCount, 0)
    }
    
    func test_loadGames_doesNoting() {
        let sut = makeSUT()
        
        sut.loadGames()
        
        XCTAssertEqual(env.loaderSpy.loadGamesCallCount, 1)
    }
    
    func test_loadGames_onReceivingError_setsStateToErrorWithMessage() {
        let sut = makeSUT()
        
        sut.loadGames()
        env.loaderSpy.complete(with: anyError)
        
        let expectedErrorMessage = "Unable to load games"
        XCTAssertEqual(sut.gamesState, .error(message: expectedErrorMessage))
    }
    
    func test_loadGames_onReceivingNewGamesTwice_overridesOldGames() {
        let sut = makeSUT()
        let initalGames = [Game.uniqueStub(), .uniqueStub()]
        
        sut.loadGames()
        env.loaderSpy.send(games: initalGames)
        XCTAssertEqual(sut.gamesState, .loaded(initalGames))
        
        let newGames = [Game.uniqueStub(), .uniqueStub()]
        env.loaderSpy.send(games: newGames)
        XCTAssertEqual(sut.gamesState, .loaded(newGames))
    }
    
    func test_refreshGames_loadsGamesAgainAndTerminatesOldPublisher() {
        let sut = makeSUT()
        let initialPublisherGames = [Game.uniqueStub(), .uniqueStub()]
        let refreshPublisherGames = [Game.uniqueStub(), .uniqueStub()]

        sut.loadGames()
        env.loaderSpy.send(games: initialPublisherGames)

        sut.refreshGames(completion: {})

        env.refreshableSpy.complete(with: refreshPublisherGames)
        XCTAssertEqual(sut.gamesState, .loaded(refreshPublisherGames))
        
        env.loaderSpy.send(games: initialPublisherGames)
        XCTAssertEqual(sut.gamesState, .loaded(refreshPublisherGames), "Expected inital publisher to be terminated")
    }
    
    func test_refreshGames_loadsGamesAgainAndNotifesCaller() {
        let sut = makeSUT()
        sut.loadGames()
        env.loaderSpy.send(games: [.uniqueStub()], at: 0)
        let exp = expectation(description: "Expected refesh to be done")
        
        sut.refreshGames(completion: {
            exp.fulfill()
        })
        env.refreshableSpy.complete(with: [.uniqueStub()])

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

private extension GamesListViewModelTests {
    struct Environment {
        let loaderSpy = GamesLoaderSpy()
        let coordinate = CoordinateSpy()
        let refreshableSpy = GamesRefreshableSpy()
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> GameListViewModel {
        let sut = GameListViewModel(gamesLoader: env.loaderSpy, gamesRefreshable: env.refreshableSpy, coordinate: env.coordinate.closure)
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

final class GamesRefreshableSpy: GamesRefreshable {
    private var subjects = [PassthroughSubject<[Game], Error>]()
    
    func refreshGames() -> AnyPublisher<[Game], Error> {
        let subject = PassthroughSubject<[Game], Error>()
        subjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func complete(with games: [Game], at index: Int = 0) {
        subjects[index].send(games)
        subjects[index].send(completion: .finished)
    }
}
