//
//  GameDetailsViewModel.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import Foundation

public final class GameDetailsViewModel: ObservableObject {
    
    let game: Game
    
    public init(game: Game) {
        self.game = game
    }
}
