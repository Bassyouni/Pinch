//
//  ContentView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import SwiftUI

enum ViewState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case error(message: String)
}

struct Game: Equatable {
    let id: String
    let name: String
    let coverURL: URL
}

protocol GameListViewModel: ObservableObject {
    var games: ViewState<[Game]> { get }
}

struct GamesListView<ViewModel: GameListViewModel> : View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            switch viewModel.games {
            case .loading:
                ProgressView()
                
            case .loaded(let games):
                List(games, id: \.id) { gameCell($0) }
                
            case .error(let errorMessage):
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Top Games")
    }
    
    func gameCell(_ game: Game) -> some View {
        HStack(alignment: .center) {
            AsyncImage(url: game.coverURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 284)
            } placeholder: {
                ProgressView()
            }
            
            Text(game.name)
                .font(.title2)
                .bold()
        }
    }
}

#Preview("Games List") {
    NavigationView {
        GamesListView(viewModel: PreviewsViewModel(games: .loaded([
            Game(id: "1", name: "The Witcher 3", coverURL: PreviewsViewModel.testImage),
            Game(id: "2", name: "The Last of us", coverURL: PreviewsViewModel.testImage),
            Game(id: "3", name: "Counter Strike", coverURL: PreviewsViewModel.testImage),
            Game(id: "4", name: "Red Alert", coverURL: PreviewsViewModel.testImage),
        ])))
    }
}

#Preview("Error State") {
    GamesListView(viewModel: PreviewsViewModel(games: .error(message: "Something Went Wrong\nTry again later")))
}

#Preview("Loading State") {
    GamesListView(viewModel: PreviewsViewModel(games: .loading))
}

private class PreviewsViewModel: GameListViewModel {
    let games: ViewState<[Game]>
    
    static let testImage = URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_med/co4bvj.jpg")!
    init(games: ViewState<[Game]>) {
        self.games = games
    }
}
