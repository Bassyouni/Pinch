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
        
        XCTAssertEqual(env.client.requests, [])
    }
    
    func test_loadGames_requestsDataFromURL() {
        let url = URL(string: "www.any-url.com")
        let sut = makeSUT(url: url!)
        
        _ = sut.loadGames()
        _ = sut.loadGames()
        
        XCTAssertEqual(env.client.requests.map { $0.url }, [url, url])
    }
    
    func test_loadGames_reuqestHeadersHasJSONContentType() {
        let sut = makeSUT()
        
        _ = sut.loadGames()
        
        XCTAssertEqual(env.client.requests[0].value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func test_loadGames_reuqestMethodIsSetToPOST() {
        let sut = makeSUT()
        
        _ = sut.loadGames()
        
        XCTAssertEqual(env.client.requests[0].httpMethod, "POST")
    }
    
    func test_loadGames_reuqestHeadersHasCorrectAuthorization() {
        let bearerToken = "some bearerToken"
        let sut = makeSUT(bearerToken: bearerToken)
        
        _ = sut.loadGames()
        
        XCTAssertEqual(env.client.requests[0].value(forHTTPHeaderField: "Authorization"), "Bearer \(bearerToken)")
    }
    
    func test_loadGames_reuqestBodyHasCorrectHasFieldsNeeded() throws {
        let clientID = "any clientID"
        let sut = makeSUT(clientID: clientID)
        
        _ = sut.loadGames()
        
        let expectedFields = Set(["first_release_date", "rating", "name", "cover.url"])
        XCTAssertEqual(Set(try items(forQuery: "fields")), expectedFields)
    }
    
    func test_loadGames_reuqestBodyHasCorrectSorting() throws {
        let clientID = "any clientID"
        let sut = makeSUT(clientID: clientID)
        
        _ = sut.loadGames()
    
        XCTAssertEqual(Set(try items(forQuery: "sort")), ["rating desc"])
    }
}

private extension RemoteGamesLoaderTests {
    struct Environment {
        let client = HTTPClientSpy()
    }
    
    func makeSUT(
        url: URL = URL(string: "www.any.com")!,
        bearerToken: String = "any bearerToken",
        clientID: String = "clientID",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> RemoteGamesLoader {
        let sut = RemoteGamesLoader(url: url, clientID: clientID, bearerToken: bearerToken, client: env.client)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func items(forQuery query: String, file: StaticString = #filePath, line: UInt = #line) throws -> [String] {
        let httpBodyData = try XCTUnwrap(env.client.requests[0].httpBody, file: file, line: line)
        let httpBodyString = try XCTUnwrap(String(data: httpBodyData, encoding: .utf8), file: file, line: line)
        
        let items = httpBodyString
            .split(separator: ";")
            .first(where: { $0.contains(query) })?
            .replacingOccurrences(of: "\(query) ", with: "")
            .split(separator: ",")
            .map { String($0) }
        
        return try XCTUnwrap(items, file: file, line: line)
    }
}

private final class HTTPClientSpy: HTTPClient {
    
    private(set) var requests = [URLRequest]()
    var stubbedPostResult: Result<Data, Error> = .success(Data())
    
    func post(request: URLRequest) -> Result<Data, Error> {
        requests.append(request)
        return stubbedPostResult
    }
}
