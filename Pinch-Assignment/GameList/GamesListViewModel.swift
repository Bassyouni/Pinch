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
    func refreshGames() -> Future<Void, Error>
    func didSelectGame(_ game: Game)
}

public enum GameListViewTransition: Equatable {
    case gameDetails(Game)
}

public final class GameListViewModel: ObservableObject, GameListDisplayLogic {
    
    @Published private(set) public var gamesState: ViewState<[Game]> = .loading
    
    private let gamesLoader: GamesLoader
    private var loadGamesCancellable: AnyCancellable?
    private let coordinate: (GameListViewTransition) -> Void
    
    public init(gamesLoader: GamesLoader, coordinate: @escaping (GameListViewTransition) -> Void) {
        self.gamesLoader = gamesLoader
        self.coordinate = coordinate
        loadGamesCancellable = loadGames()
    }
    
    public func refreshGames() -> Future<Void, Error> {
        return Future { [weak self] promise in
            var temporaryCancellable: AnyCancellable?
            
            temporaryCancellable = self?.loadGames() { [weak self] result in
                if case .success = result, temporaryCancellable != nil {
                    self?.loadGamesCancellable?.cancel()
                    self?.loadGamesCancellable = temporaryCancellable
                    self?.gamesState = .loaded([])
                }
                
                temporaryCancellable = nil
                promise(.success(()))
            }
        }
    }
    
    public func didSelectGame(_ game: Game) {
        coordinate(.gameDetails(game))
    }
}

extension GameListViewModel {
    private func loadGames(completion: ((Result<Void, Error>) -> Void)? = nil) -> AnyCancellable {
        gamesLoader.loadGames()
            .map { Self.adjustCoverURLForGamesList($0) }
            .sink { [weak self] result in
                if case let .failure(error) = result {
                    completion?(.failure(error))
                    self?.gamesState = .error(message: "Unable to load games")
                }
            } receiveValue: { [weak self] games in
                completion?(.success(()))
                self?.proccessNew(games: games)
            }
    }
    
    private func proccessNew(games: [Game]) {
        if case let .loaded(oldGames) = gamesState {
            gamesState = .loaded(oldGames + games)
        } else {
            gamesState = .loaded(games)
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
