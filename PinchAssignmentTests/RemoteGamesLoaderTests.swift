//
//  RemoteGamesLoaderTests.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import XCTest
import Combine
import Pinch_Assignment

final class RemoteGamesLoaderTests: XCTestCase {
    private let env = Environment()
    
    func test_init_doesNothing() {
        _ = makeSUT()
        
        XCTAssertEqual(env.client.requestedURLs, [])
    }
}

private extension RemoteGamesLoaderTests {
    struct Environment {
        let client = HTTPClientSpy()
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemoteGamesLoader {
        let sut = RemoteGamesLoader(client: env.client)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

private final class HTTPClientSpy: HTTPClient {
    
    private(set) var requestedURLs = [URLRequest]()
    var stubbedPostResult: Result<Data, Error> = .success(Data())
    
    func post(request: URLRequest) -> Result<Data, Error> {
        requestedURLs.append(request)
        return stubbedPostResult
    }
}
