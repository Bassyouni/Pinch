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
    func test_init_gameListIsByDefaultTheRootOfTheStack() {
        XCTAssertEqual(makeSUT().stack, [.gameList])
    }
    
    func test_push_addsNewViewToTheStack() {
        let sut = makeSUT()
        
        sut.push(.gameDetails)
        XCTAssertEqual(sut.stack, [.gameList, .gameDetails])
        
        sut.push(.gameList)
        XCTAssertEqual(sut.stack, [.gameList, .gameDetails, .gameList])
    }
    
    func test_pop_removeLastViewFromTheStack() {
        let sut = makeSUT()
        sut.push(.gameDetails)
        sut.push(.gameList)
        
        let firstRemovedRoute = sut.pop()
        let secondRemovedRoute = sut.pop()
        
        XCTAssertEqual(firstRemovedRoute, .gameList)
        XCTAssertEqual(secondRemovedRoute, .gameDetails)
        XCTAssertEqual(sut.stack, [.gameList])
    }
}

private extension NavigationRouterTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> NavigationRouter {
        let sut = NavigationRouter()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
