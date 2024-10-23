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
            AppNavigationView { view, router in
                switch view {
                case .gameList:
                    makeGameListView(router)
                    
                case .gameDetails(let game):
                    makeGameDetailsView(game)
                }
            }
        }
    }
    
    private func makeGameListView(_ router: NavigationRouter) -> some View {
        let url = URL(string: "https://api.igdb.com/v4/games")!
        let clientId = "ctgyj1u5eoe8ynxsoi0anhpctz1oo6"
        let bearerToken = "iawmqtbgk5h47jjglcn4v7sofkue9v"
        let client = URLSessionHTTPClient()
        let remoteLoader = RemoteGamesLoader(url: url, clientID: clientId, bearerToken: bearerToken, client: client)
        let store = CoreDataGamesStore()
        let gamesLoader = LocalWithRemoteFallbackGamesLoader(store: store, remote: remoteLoader)
        let viewModel = GameListViewModel(
            gamesLoader: MainQueueDispatchDecorator(gamesLoader),
            coordinate: { destination in
                switch destination {
                case .gameDetails(let game):
                    router.push(.gameDetails(game))
                }
            }
        )
        
        return GamesListView(viewModel: viewModel)
    }
    
    @ViewBuilder
    private func makeGameDetailsView(_ game: Game) -> some View {
        Text(game.name)
    }
}
