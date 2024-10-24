//
//  NavigationRouter.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Foundation

@MainActor
final class NavigationRouter: ObservableObject {
    
    let root: NavigationRoute = .gameList
    @Published var stack: [NavigationRoute] = []
    
    func push(_ route: NavigationRoute) {
        stack.append(route)
    }
    
    @discardableResult
    func pop() -> NavigationRoute? {
        stack.popLast()
    }
}
