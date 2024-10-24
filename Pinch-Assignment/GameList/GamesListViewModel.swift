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
    func refreshGames(completion: @escaping () -> Void)
    func didSelectGame(_ game: Game)
    func loadGames()
}

public enum GameListViewTransition: Equatable {
    case gameDetails(Game)
}

public final class GameListViewModel: ObservableObject, GameListDisplayLogic {
    
    @Published private(set) public var gamesState: ViewState<[Game]> = .loaded([])
    
    private let gamesLoader: GamesLoader
    private let gamesRefreshable: GamesRefreshable
    private var loadGamesCancellable: AnyCancellable?
    private let coordinate: (GameListViewTransition) -> Void
    
    public init(gamesLoader: GamesLoader, gamesRefreshable: GamesRefreshable, coordinate: @escaping (GameListViewTransition) -> Void) {
        self.gamesLoader = gamesLoader
        self.gamesRefreshable = gamesRefreshable
        self.coordinate = coordinate
    }
    
    public func loadGames() {
        gamesState = .loading
        loadGamesCancellable = loadAndProccessGames()
    }
    
    public func refreshGames(completion: @escaping () -> Void) {
        var temporaryCancellable: AnyCancellable?
        
        temporaryCancellable = gamesRefreshable.refreshGames()
            .map { Self.adjustCoverURLForGamesList($0) }
            .sink { [weak self] result in
                if case .failure = result {
                    self?.gamesState = .error(message: "Unable to load games")
                }
                
                completion()
            } receiveValue: { [weak self] games in
                if let temporaryCancellable = temporaryCancellable {
                    self?.loadGamesCancellable?.cancel()
                    self?.loadGamesCancellable = temporaryCancellable
                }
                
                self?.gamesState = .loaded(games)
            }
    }
    
    public func didSelectGame(_ game: Game) {
        coordinate(.gameDetails(game))
    }
}

extension GameListViewModel {
    private func loadAndProccessGames(completion: ((Result<Void, Error>) -> Void)? = nil) -> AnyCancellable {
        gamesLoader.loadGames()
            .map { Self.adjustCoverURLForGamesList($0) }
            .sink { [weak self] result in
                if case let .failure(error) = result {
                    completion?(.failure(error))
                    self?.gamesState = .error(message: "Unable to load games")
                }
            } receiveValue: { [weak self] games in
                completion?(.success(()))
                self?.gamesState = .loaded(games)
            }
    }
    
    private static func adjustCoverURLForGamesList(_ games: [Game]) -> [Game] {
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
