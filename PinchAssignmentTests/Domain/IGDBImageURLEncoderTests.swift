//
//  IGDBImageURLEncoderTests.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class IGDBGameImageURLEncoderTests: XCTestCase {
    
    func test_encode_whenURLHasNoHTTPs_prefixCoverURLWithHTTPs() {
        let sut = makeSUT()
        let urlWithNoPrefix = URL(string: "//www.url.com")!
        let urlWithPrefix = URL(string: "https://www.url.com")!
        
        XCTAssertEqual(sut.encode(urlWithNoPrefix, forSize: .portrait), urlWithPrefix)
        XCTAssertEqual(sut.encode(urlWithPrefix, forSize: .landscape), urlWithPrefix)
    }
    
    func test_encode_whenSizeIsPortrait_replaceSizeWithCoverMed() {
        let sut = makeSUT()
        let expectedSizeURL = URL(string: "https://www.url.com/path/t_cover_med/photoName.jpg")!
        let otherSizeURL = URL(string: "https://www.url.com/path/t_thumb/photoName.jpg")!
        
        let encodedURL = sut.encode(otherSizeURL, forSize: .portrait)
    
        XCTAssertEqual(encodedURL, expectedSizeURL)
    }
    
    func test_encode_whenSizeIsLandscape_replaceSizeWithScreenshotMed() {
        let sut = makeSUT()
        let expectedSizeURL = URL(string: "https://www.url.com/path/t_screenshot_med/photoName.jpg")!
        let otherSizeURL = URL(string: "https://www.url.com/path/t_thumb/photoName.jpg")!
        
        let encodedURL = sut.encode(otherSizeURL, forSize: .landscape)
    
        XCTAssertEqual(encodedURL, expectedSizeURL)
    }
}

private extension IGDBGameImageURLEncoderTests {
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IGDBGameImageURLEncoder {
        return IGDBGameImageURLEncoder()
    }
}
