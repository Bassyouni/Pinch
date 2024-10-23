//
//  GameStub.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Foundation
import Pinch_Assignment

extension Game {
    static func uniqueStub(url: String? = nil) -> Game {
        let id = UUID().uuidString
        return Game(id: id, name: id, coverURL: URL(string: url ?? "https://www.url.com")!)
    }
}
