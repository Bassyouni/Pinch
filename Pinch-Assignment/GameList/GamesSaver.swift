//
//  GamesSaver.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine
import Foundation

public protocol GamesSaver {
    func saveGames(_ games: [Game]) -> AnyPublisher<Void, Error>
}
