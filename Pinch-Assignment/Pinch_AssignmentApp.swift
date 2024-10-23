//
//  Pinch_AssignmentApp.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import SwiftUI

@main
struct Pinch_AssignmentApp: App {
    
    private let viewComposer: ViewComposer
    @StateObject var router: NavigationRouter
    
    init() {
        let router = NavigationRouter()
        self._router = .init(wrappedValue: router)
        viewComposer = ViewComposer(router: router)
    }
    
    var body: some Scene {
        WindowGroup {
            AppNavigationView(router: router, view: { route in
                switch route {
                case .gameList:
                    viewComposer.composeGameListView
                    
                case .gameDetails(let game):
                    viewComposer.composeGameDetailsView(with: game)
                }
            })
        }
    }
}
