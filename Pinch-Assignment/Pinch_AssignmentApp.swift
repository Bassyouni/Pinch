//
//  Pinch_AssignmentApp.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import SwiftUI

@main
struct Pinch_AssignmentApp: App {
    var body: some Scene {
        WindowGroup {
            GamesListView(viewModel: NullViewModel())
        }
    }
}

class NullViewModel: GameListDisplayLogic {
    var gamesState: ViewState<[Game]> = .loading
}
