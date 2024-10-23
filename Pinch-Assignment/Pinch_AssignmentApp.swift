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
            AppNavigationView { view, _ in
                switch view {
                case .gameList:
                    makeGameListView()
                    
                case .gameDetails:
                    makeGameDetailsView()
                }
            }
        }
    }
    
    private func makeGameListView() -> some View {
        let url = URL(string: "https://api.igdb.com/v4/games")!
        let clientId = "ctgyj1u5eoe8ynxsoi0anhpctz1oo6"
        let bearerToken = "iawmqtbgk5h47jjglcn4v7sofkue9v"
        let client = URLSessionHTTPClient()
        let remoteLoader = RemoteGamesLoader(url: url, clientID: clientId, bearerToken: bearerToken, client: client)
        let store = CoreDataGamesStore()
        let gamesLoader = LocalWithRemoteFallbackGamesLoader(store: store, remote: remoteLoader)
        let viewModel = GameListViewModel(gamesLoader: MainQueueDispatchDecorator(gamesLoader))
        
        return GamesListView(viewModel: viewModel)
    }
    
    @ViewBuilder
    private func makeGameDetailsView() -> some View {
        Text("Game Details")
    }
}
