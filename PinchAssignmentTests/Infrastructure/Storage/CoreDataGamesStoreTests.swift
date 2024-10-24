//
//  CoreDataGamesStoreTests.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class CoreDataGamesStoreTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    func test_loadGames_hasNoSideEffectsOnEmptyStore() {
        expect(makeSUT(), toLoadTwice: .success([]))
    }
    
    func test_loadGames_deliversFoundValuesOnNonEmptyStore() {
        let sut = makeSUT()
        let games = uniqueGames()
        
        save(games, to: sut)
        
        expect(sut, toLoadTwice: .success(games))
    }

    func test_saveGames_deliversNoErrorOnEmptyStore() {
        let sut = makeSUT()
        
        let savingError = save(uniqueGames(), to: sut)
        
        XCTAssertNil(savingError, "Expected to save games successfully")
    }
    
    func test_saveGames_deliversNoErrorOnNonEmptyStore() {
        let sut = makeSUT()
        save(uniqueGames(), to: sut)
        
        let savingError = save(uniqueGames(), to: sut)
        
        XCTAssertNil(savingError, "Expected to append games successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedStoreValues() {
        let sut = makeSUT()
        let firstGames = uniqueGames()
        save(firstGames, to: sut)
        
        let latestGames = uniqueGames()
        save(latestGames, to: sut)
        
        expect(sut, toLoad: .success(latestGames))
    }
    
    func test_store_shouldRunSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.saveGames(uniqueGames())
            .sink(receiveCompletion: { _ in
                completedOperationsInOrder.append(op1)
                op1.fulfill()
            }, receiveValue: {})
            .store(in: &cancellables)
        
        let op2 = expectation(description: "Operation 2")
        sut.saveGames(uniqueGames())
            .sink(receiveCompletion: { _ in
                completedOperationsInOrder.append(op2)
                op2.fulfill()
            }, receiveValue: {})
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2], "Expected side-effects to run serially but operations finished in the wrong order")
    }
}

private extension CoreDataGamesStoreTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataGamesStore {
        let sut = CoreDataGamesStore(inMemory: true)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(
        _ sut: CoreDataGamesStore,
        toLoadTwice expectedResult: Result<[Game], Error>,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        expect(sut, toLoad: expectedResult, file: file, line: line)
        expect(sut, toLoad: expectedResult, file: file, line: line)
    }
    
    func expect(
        _ sut: CoreDataGamesStore,
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
    
    @discardableResult
    func save(_ games: [Game], to sut: CoreDataGamesStore) -> Error? {
        let exp = expectation(description: "Wait for games saving")
        var savingError: Error?
        
        sut.saveGames(games)
            .sink { result in
                if case let .failure(error) = result {
                    savingError = error
                }
                exp.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        
        
        wait(for: [exp], timeout: 1.0)
        return savingError
    }
}
