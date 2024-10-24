//
//  ContentView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 21/10/2024.
//

import SwiftUI
import Combine

struct GamesListView<ViewModel: GameListDisplayLogic> : View {
    
    @StateObject var viewModel: ViewModel
    @State private var cancellables = Set<AnyCancellable>()
    @State private var scrollPositionID: String?
    let urlEncoder: GameImageURLEncoder
    
    var body: some View {
        VStack {
            switch viewModel.gamesState {
            case .loading:
                ProgressView()
                
            case let .loaded(games):
                ScrollViewReader{ proxy in
                    List(games, id: \.id) { game in
                        gameCell(game)
                            .onTapGesture {
                                viewModel.didSelectGame(game)
                                scrollPositionID = game.id
                            }
                            .id(game.id)
                    }
                    .refreshable { await refreshGames() }
                    .scrollIndicators(.hidden)
                    .onAppear {
                        proxy.scrollTo(scrollPositionID, anchor: .center)
                    }
                }
                
                
            case let .error(errorMessage):
                errorView(errorMessage)
            }
        }
        .navigationTitle("Top Games")
        .task { viewModel.loadGames() }
    }
    
    private func gameCell(_ game: Game) -> some View {
        HStack(alignment: .center) {
            AsyncImage(url: coverURL(for: game)) { image in
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
    
    private func coverURL(for game: Game) -> URL {
        urlEncoder.encode(game.coverURL, forSize: .portrait)
    }
}

#Preview("Games List") {
    NavigationView {
        GamesListView(viewModel: DisplayLogic(games: .loaded([
            DisplayLogic.makeGame(id: "1", name: "The Witcher 3"),
            DisplayLogic.makeGame(id: "2", name: "The Last of us"),
            DisplayLogic.makeGame(id: "3", name: "Counter Strike"),
            DisplayLogic.makeGame(id: "4", name: "Red Alert"),
        ])), urlEncoder: DisplayLogic())
    }
}

#Preview("Error State") {
    GamesListView(viewModel: DisplayLogic(games: .error(message: "Something Went Wrong\nTry again later")), urlEncoder: DisplayLogic())
}

#Preview("Loading State") {
    GamesListView(viewModel: DisplayLogic(games: .loading), urlEncoder: DisplayLogic())
}

private class DisplayLogic: GameListDisplayLogic, GameImageURLEncoder {
    let gamesState: ViewState<[Game]>
    
    static let testImage = URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_med/co4bvj.jpg")!
    init(games: ViewState<[Game]> = .loading) {
        self.gamesState = games
    }
    
    func refreshGames(completion: () -> Void) {}
    func didSelectGame(_ game: Game) {}
    func loadGames() {}
    
    static func makeGame(id: String, name: String) -> Game {
        Game(
            id: id,
            name: name,
            coverURL: DisplayLogic.testImage,
            summary: "",
            rating: 0,
            platforms: [],
            genres: [],
            videosIDs: nil
        )
    }
    func encode(_ url: URL, forSize size: GameImageSize) -> URL { url }
}
