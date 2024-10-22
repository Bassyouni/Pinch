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

public final class GameListViewModel: ObservableObject, GameListDisplayLogic {
    @Published private(set) public var gamesState: ViewState<[Game]> = .loading
    
    public init() {}
}
