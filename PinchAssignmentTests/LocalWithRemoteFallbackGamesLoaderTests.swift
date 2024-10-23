//
//  LocalWithRemoteFallbackGamesLoaderTests.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class LocalWithRemoteFallbackGamesLoaderTests: XCTestCase {
    private let env = Environment()
    private var cancellables = Set<AnyCancellable>()
    
    func test_init_doesNotLoadFromAnySource() {
        _ = makeSUT()
        
        XCTAssertEqual(env.local.savedGames, [])
        XCTAssertEqual(env.local.loadGamesCallCount, 0)
        XCTAssertEqual(env.remote.loadGamesCallCount, 0)
    }
    
    func test_loadGames_loadsFromLocalFirst() {
        let sut = makeSUT()
        
        _ = sut.loadGames()
        
        XCTAssertEqual(env.local.loadGamesCallCount, 1)
        XCTAssertEqual(env.remote.loadGamesCallCount, 0)
    }
    
    func test_loadGames_onEmptyLocalData_loadsFromRemote() {
        let sut = makeSUT()
        let games = uniqueGames()
        
        expect(sut, toCompleteWith: .success(games)) {
            env.local.complete(with: [])
            env.remote.complete(with: games)
        }
    }
}

private extension LocalWithRemoteFallbackGamesLoaderTests {
    struct Environment {
        let local = GamesStoreSpy()
        let remote = GamesLoaderSpy()
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalWithRemoteFallbackGamesLoader {
        let sut = LocalWithRemoteFallbackGamesLoader(store: env.local, remote: env.remote)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(
        _ sut: LocalWithRemoteFallbackGamesLoader,
        toCompleteWith expectedResult: Result<[Game], Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: Result<[Game], Error>?
        
        sut.loadGames().sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    receivedResult = .failure(error)
                }
                exp.fulfill()
            },
            receiveValue: { games in
                receivedResult = .success(games)
            }
        ).store(in: &cancellables)
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedGames), .success(expectedGames)):
            XCTAssertEqual(receivedGames, expectedGames, file: file, line: line)
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(String(describing: receivedResult)) instead", file: file, line: line)
        }
    }
}

private class GamesStoreSpy: GamesLoaderSpy, GamesSaver {
    private var messages = [(savedGames: [Game], subject: PassthroughSubject<Void, Error>)]()
    
    var savedGames: [[Game]] {
        messages.map { $0.savedGames }
    }
    
    func saveGames(_ games: [Game]) -> AnyPublisher<Void, Error> {
        let subject = PassthroughSubject<Void, Error>()
        messages.append((games, subject))
        return subject.eraseToAnyPublisher()
    }
    
    func completeSave(at index: Int = 0) {
        messages[index].subject.send(())
        messages[index].subject.send(completion: .finished)
    }
    
    func completeSave(with error: Error, at index: Int = 0) {
        messages[index].subject.send(completion: .failure(error))
    }
}
