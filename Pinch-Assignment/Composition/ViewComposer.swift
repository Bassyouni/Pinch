//
//  ViewComposer.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import SwiftUI

@MainActor
final class ViewComposer {
    private let router: NavigationRouter
    
    init(router: NavigationRouter) {
        self.router = router
    }
    
    lazy var composeGameListView: some View = {
        let url = URL(string: "https://api.igdb.com/v4/games")!
        let clientId = "ctgyj1u5eoe8ynxsoi0anhpctz1oo6"
        let bearerToken = "iawmqtbgk5h47jjglcn4v7sofkue9v"
        
        let client = URLSessionHTTPClient()
        let remoteLoader = RemoteGamesLoader(url: url, clientID: clientId, bearerToken: bearerToken, client: client)
        let store = CoreDataGamesStore()
        let gamesLoaderWithFallback = GamesLoaderWithFallback(store: store, remote: remoteLoader)
        let gamesLoader = MainQueueDispatchDecorator(gamesLoaderWithFallback)
        
        let viewModel = GameListViewModel(
            gamesLoader: gamesLoader,
            gamesRefreshable: gamesLoader,
            coordinate: { [weak router] destination in
                switch destination {
                case .gameDetails(let game):
                    router?.push(.gameDetails(game))
                }
            }
        )
        
        return GamesListView(viewModel: viewModel)
    }()
    
    func composeGameDetailsView(with game: Game) -> some View {
        Text(game.name)
    }
}
