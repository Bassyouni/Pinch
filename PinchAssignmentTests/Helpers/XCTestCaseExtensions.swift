//
//  XCTestCaseExtensions.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak for instance", file: file, line: line)
        }
    }
}
