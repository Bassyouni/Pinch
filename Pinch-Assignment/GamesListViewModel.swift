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
            .sink { [weak self] result in
                if case .failure = result {
                    self?.gamesState = .error(message: "Unable to load games")
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
