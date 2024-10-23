//
//  NavigationRouterTests.swift
//  PinchAssignmentTests
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import XCTest
@testable import Pinch_Assignment

@MainActor
final class NavigationRouterTests: XCTestCase {
    func test_init_root_isSetToGameList() {
        XCTAssertEqual(makeSUT().root, .gameList)
    }
    func test_init_gameListIsEmpty() {
        XCTAssertEqual(makeSUT().stack, [])
    }
    
    func test_push_addsNewViewToTheStack() {
        let sut = makeSUT()
        let game = Game.uniqueStub()
        
        sut.push(.gameDetails(game))
        XCTAssertEqual(sut.stack, [.gameDetails(game)])
        
        sut.push(.gameList)
        XCTAssertEqual(sut.stack, [.gameDetails(game), .gameList])
    }
    
    func test_pop_removeLastViewFromTheStack() {
        let sut = makeSUT()
        let game = Game.uniqueStub()
        sut.push(.gameDetails(game))
        sut.push(.gameList)
        
        let firstRemovedRoute = sut.pop()
        let secondRemovedRoute = sut.pop()
        
        XCTAssertEqual(firstRemovedRoute, .gameList)
        XCTAssertEqual(secondRemovedRoute, .gameDetails(game))
        XCTAssertEqual(sut.stack, [])
    }
}

private extension NavigationRouterTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> NavigationRouter {
        let sut = NavigationRouter()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
