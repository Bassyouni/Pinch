//
//  XCTestCaseExtensions.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import XCTest
import Pinch_Assignment

extension XCTestCase {
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak for instance", file: file, line: line)
        }
    }
}

// MARK: - Helpers
extension XCTestCase {
    func uniqueGames() -> [Game] {
        return [.uniqueStub(), .uniqueStub()]
    }
    
    var anyError: Error {
        NSError(domain: "Test", code: 1)
    }
}
