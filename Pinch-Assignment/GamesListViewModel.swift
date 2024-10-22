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
    @Published private(set) public var gamesState: ViewState<[Game]> = .loading
    
    private let gamesLoader: GamesLoader
    
    public init(gamesLoader: GamesLoader) {
        self.gamesLoader = gamesLoader
        _ = gamesLoader.loadGames()
    }
}
