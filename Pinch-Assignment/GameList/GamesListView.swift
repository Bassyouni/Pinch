//
//  ContentView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import SwiftUI
import Combine

struct GamesListView<ViewModel: GameListDisplayLogic> : View {
    
    @ObservedObject var viewModel: ViewModel
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            switch viewModel.gamesState {
            case .loading:
                ProgressView()
                
            case .loaded(let games):
                List(games, id: \.id) { gameCell($0) }
                    .refreshable { await refreshGames() }
                
            case .error(let errorMessage):
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Top Games")
    }
    
    private func gameCell(_ game: Game) -> some View {
        HStack(alignment: .center) {
            AsyncImage(url: game.coverURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 160, height: 284)
            
            Text(game.name)
                .font(.title2)
                .bold()
        }
    }
    
    private func refreshGames() async {
        return await withCheckedContinuation { continuation in
            viewModel.refreshGames()
                .sink(receiveCompletion: { _ in continuation.resume() }, receiveValue: {})
                .store(in: &cancellables)
        }
    }
}

#Preview("Games List") {
    NavigationView {
        GamesListView(viewModel: DisplayLogic(games: .loaded([
            Game(id: "1", name: "The Witcher 3", coverURL: DisplayLogic.testImage),
            Game(id: "2", name: "The Last of us", coverURL: DisplayLogic.testImage),
            Game(id: "3", name: "Counter Strike", coverURL: DisplayLogic.testImage),
            Game(id: "4", name: "Red Alert", coverURL: DisplayLogic.testImage),
        ])))
    }
}

#Preview("Error State") {
    GamesListView(viewModel: DisplayLogic(games: .error(message: "Something Went Wrong\nTry again later")))
}

#Preview("Loading State") {
    GamesListView(viewModel: DisplayLogic(games: .loading))
}

private class DisplayLogic: GameListDisplayLogic {
    let gamesState: ViewState<[Game]>
    
    static let testImage = URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_med/co4bvj.jpg")!
    init(games: ViewState<[Game]>) {
        self.gamesState = games
    }
    
    func refreshGames() -> Future<Void, Error> { .init { _ in} }
}
