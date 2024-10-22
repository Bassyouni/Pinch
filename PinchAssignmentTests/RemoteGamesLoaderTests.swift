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
    
    func test_loadGames_requestsDataFromURL() {
        let url = URL(string: "www.any-url.com")
        let sut = makeSUT(url: url!)
        
        _ = sut.loadGames()
        
        XCTAssertEqual(env.client.requestedURLs.map { $0.url }, [url])
    }
    
    func test_loadGames_reuqestHeadersHasJSONContentType() {
        let sut = makeSUT()
        
        _ = sut.loadGames()
        
        let headers = env.client.requestedURLs.map { $0.allHTTPHeaderFields }.first!
        XCTAssertEqual(headers?["Content-Type"], "application/json")
    }
    
    func test_loadGames_reuqestHeadersHasCorrectAuthorization() {
        let bearerToken = "some bearerToken"
        let sut = makeSUT(bearerToken: bearerToken)
        
        _ = sut.loadGames()
        
        let headers = env.client.requestedURLs.map { $0.allHTTPHeaderFields }.first!
        XCTAssertEqual(headers?["Authorization"], "Bearer \(bearerToken)")
    }
}

private extension RemoteGamesLoaderTests {
    struct Environment {
        let client = HTTPClientSpy()
    }
    
    func makeSUT(
        url: URL = URL(string: "www.any.com")!,
        bearerToken: String = "any bearerToken",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> RemoteGamesLoader {
        let sut = RemoteGamesLoader(url: url, bearerToken: bearerToken, client: env.client)
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
