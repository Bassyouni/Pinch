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
