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
    private var cancellables = Set<AnyCancellable>()
    
    public init(gamesLoader: GamesLoader, gamesRefreshable: GamesRefreshable, coordinate: @escaping (GameListViewTransition) -> Void) {
        self.gamesLoader = gamesLoader
        self.gamesRefreshable = gamesRefreshable
        self.coordinate = coordinate
    }
    
    public func loadGames() {
        gamesState = .loading
        loadGamesCancellable = processGames(from: gamesLoader.loadGames())
    }
    
    public func refreshGames(completion: @escaping () -> Void) {
        var temporaryCancellable: AnyCancellable?
        
        let refreshPublisher = gamesRefreshable.refreshGames()
        temporaryCancellable = processGames(from: refreshPublisher)
        
        refreshPublisher
            .prefix(1)
            .sink { result in
            completion()
        } receiveValue: { [weak self]_ in
            self?.loadGamesCancellable?.cancel()
            self?.loadGamesCancellable = temporaryCancellable
        }
        .store(in: &cancellables)
    }
    
    public func didSelectGame(_ game: Game) {
        coordinate(.gameDetails(game))
    }
}

extension GameListViewModel {
    private func processGames(from publisher: AnyPublisher<[Game], Error>) -> AnyCancellable {
        publisher
            .sink { [weak self] result in
                if case .failure = result {
                    self?.gamesState = .error(message: "Unable to load games")
                }
            } receiveValue: { [weak self] games in
                self?.gamesState = .loaded(games)
            }
    }
}
