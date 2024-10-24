//
//  GameImageURLEncoder.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import Foundation

public enum GameImageSize {
    case portrait
    case landscape
}

public protocol GameImageURLEncoder {
    func encode(_ url: URL, forSize size: GameImageSize) -> URL
}
