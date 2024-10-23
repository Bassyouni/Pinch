//
//  NavigationRouter.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Foundation

enum NavigationRoute: Hashable {
    case gameList
    case gameDetails
}

@MainActor
final class NavigationRouter: ObservableObject {
    
    @Published private(set) var stack: [NavigationRoute] = [.gameList]
}
