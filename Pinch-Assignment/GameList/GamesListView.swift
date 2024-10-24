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
                
            case let .loaded(games):
                List(games, id: \.id) { game in
                    gameCell(game)
                        .onTapGesture { viewModel.didSelectGame(game)  }
                }
                .refreshable { await refreshGames() }
                
            case let .error(errorMessage):
                errorView(errorMessage)
            }
        }
        .navigationTitle("Top Games")
        .task { viewModel.loadGames() }
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
    
    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        Text(message)
            .multilineTextAlignment(.center)
            .foregroundColor(.red)
            .padding()
        
        Button {
            viewModel.loadGames()
        } label: {
            Text("Try again")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal, 50)
        }
    }
    
    private func refreshGames() async {
        return await withCheckedContinuation { continuation in
            viewModel.refreshGames(completion: {
                continuation.resume()
            })
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
    
    func refreshGames(completion: () -> Void) {}
    func didSelectGame(_ game: Game) {}
    func loadGames() {}
}
