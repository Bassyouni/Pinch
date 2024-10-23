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

private class GamesStoreSpy: GamesLoader, GamesSaver {
    private var loadSubjects = [PassthroughSubject<[Game], Error>]()
    private var saveSubjects = [PassthroughSubject<Void, Error>]()
    private(set) var savedGames = [[Game]]()
    
    var loadGamesCallCount: Int { loadSubjects.count }
    var saveGamesCallCount: Int { saveSubjects.count }
    
    func loadGames() -> AnyPublisher<[Game], Error> {
        let subject = PassthroughSubject<[Game], Error>()
        loadSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func saveGames(_ games: [Game]) -> AnyPublisher<Void, Error> {
        savedGames.append(games)
        let subject = PassthroughSubject<Void, Error>()
        saveSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func complete(with games: [Game], at index: Int = 0) {
        loadSubjects[index].send(games)
        loadSubjects[index].send(completion: .finished)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        loadSubjects[index].send(completion: .failure(error))
    }
    
    func completeSave(at index: Int = 0) {
        saveSubjects[index].send(())
        saveSubjects[index].send(completion: .finished)
    }
    
    func completeSave(with error: Error, at index: Int = 0) {
        saveSubjects[index].send(completion: .failure(error))
    }
}

private class GamesLoaderSpy: GamesLoader {
    private var subjects = [PassthroughSubject<[Game], Error>]()
    
    var loadGamesCallCount: Int { subjects.count }
    
    func loadGames() -> AnyPublisher<[Game], Error> {
        let subject = PassthroughSubject<[Game], Error>()
        subjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func complete(with games: [Game], at index: Int = 0) {
        subjects[index].send(games)
        subjects[index].send(completion: .finished)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        subjects[index].send(completion: .failure(error))
    }
}
