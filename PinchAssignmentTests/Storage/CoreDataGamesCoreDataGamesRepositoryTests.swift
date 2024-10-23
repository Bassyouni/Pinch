//
//  CoreDataGamesRepositoryTests.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class CoreDataGamesRepositoryTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    func test_loadGames_hasNoSideEffectsOnEmptyRepository() {
        let sut = makeSUT()
        
        expect(sut, toLoad: .success([]))
        expect(sut, toLoad: .success([]))
    }
    
    func test_saveGames_deliversNoErrorOnEmptyRepository() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for games saving")
        
        sut.saveGames([Game.uniqueStub()]).sink { result in
            if case .failure = result {
                XCTFail("Expected not fail inserting games")
            }
            exp.fulfill()
        } receiveValue: { _ in }
        .store(in: &cancellables)

        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension CoreDataGamesRepositoryTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataGamesRepository {
        let sut = CoreDataGamesRepository(inMemory: true)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(
        _ sut: CoreDataGamesRepository,
        toLoad expectedResult: Result<[Game], Error>,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for games retrieval")
        var receivedGames: [Game]?
        
        sut.loadGames()
            .sink { result in
                switch (result, expectedResult) {
                case let (.finished, .success(expectedGames)):
                    XCTAssertEqual(receivedGames, expectedGames, file: file, line: line)
                    
                case (.failure, .failure):
                    break
                    
                default:
                    XCTFail("Expected to retrieve \(expectedResult), got \(result) instead", file: file, line: line)
                }
                
                exp.fulfill()
            } receiveValue: { games in
                receivedGames = games
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
}
