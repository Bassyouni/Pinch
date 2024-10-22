//
//  GameListViewModelTests.swift
//  PinchAssignmentTests
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import XCTest
import Pinch_Assignment

final class GameListViewModelTests: XCTestCase {
    private let env = Environment()
    
    func test_init_gamesStateIsLoadingByDefault() {
        XCTAssertEqual(makeSUT().gamesState, .loading)
    }
    
}

private extension GameListViewModelTests {
    struct Environment {}
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> GameListViewModel {
        let sut = GameListViewModel()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
