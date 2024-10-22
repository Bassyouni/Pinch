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
            let url = URL(string: "https://api.igdb.com/v4/games")!
            let clientId = "ctgyj1u5eoe8ynxsoi0anhpctz1oo6"
            let bearerToken = "iawmqtbgk5h47jjglcn4v7sofkue9v"
            let client = URLSessionHTTPClient()
            let loader = RemoteGamesLoader(url: url, clientID: clientId, bearerToken: bearerToken, client: client)
            
            NavigationView {
                GamesListView(viewModel: GameListViewModel(gamesLoader: MainQueueDispatchDecorator(loader)))
            }
        }
    }
}

class NullViewModel: GameListDisplayLogic {
    var gamesState: ViewState<[Game]> = .loading
}
