//
//  GamesListViewModel.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Combine
import Foundation

public protocol GameListDisplayLogic: ObservableObject {
    var gamesState: ViewState<[Game]> { get }
}

public protocol GamesLoader {
    func loadGames() -> AnyPublisher<[Game], Error>
}

public final class GameListViewModel: ObservableObject, GameListDisplayLogic {
    
    @Published private(set) public var gamesState: ViewState<[Game]> = .loaded([])
    
    private let gamesLoader: GamesLoader
    private var cancellables = Set<AnyCancellable>()
    
    public init(gamesLoader: GamesLoader) {
        self.gamesLoader = gamesLoader
        loadGames()
    }
    
    func loadGames() {
        gamesState = .loading
        
        gamesLoader.loadGames()
            .map { Self.prefixCoverURLWithHTTPs($0) }
            .sink { [weak self] result in
                if case .failure = result {
                    self?.gamesState = .error(message: "Unable to load games")
                }
            } receiveValue: { [weak self] receivedGames in
                switch self?.gamesState {
                case let .loaded(oldGames):
                    self?.gamesState = .loaded(oldGames + receivedGames)
                default:
                    self?.gamesState = .loaded(receivedGames)
                }
            }
            .store(in: &cancellables)
    }
    
    private static func prefixCoverURLWithHTTPs(_ games: [Game]) -> [Game] {
        games.map { game in
            var urlString = game.coverURL.absoluteString
            
            if !urlString.hasPrefix("https:") {
                urlString = "https:" + urlString
            }
            
            if let range = urlString.range(of: "t_[^/]+", options: .regularExpression) {
                urlString.replaceSubrange(range, with: "t_cover_med")
            }
            
            return Game(id: game.id, name: game.name, coverURL: URL(string: urlString) ?? game.coverURL)
        }
    }
}
