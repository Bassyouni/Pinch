//
//  GamesRefreshable.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import Combine
import Foundation

public protocol GamesRefreshable {
    func refreshGames() -> AnyPublisher<[Game], Error>
}
