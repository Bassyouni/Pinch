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
}

private extension NavigationRouterTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> NavigationRouter {
        let sut = NavigationRouter()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
