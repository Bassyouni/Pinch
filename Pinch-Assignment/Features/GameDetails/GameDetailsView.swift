//
//  GameDetailsView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import SwiftUI

struct GameDetailsView: View {
    @ObservedObject var viewModel: GameDetailsViewModel
    
    var body: some View {
        Text(viewModel.game.name)
            .multilineTextAlignment(.leading)
        
        Text("\(Int(floor(viewModel.game.rating))) / 100")
            .multilineTextAlignment(.leading)
        
        Text(viewModel.game.platforms.joined(separator: ", "))
            .multilineTextAlignment(.leading)
        
        Text(viewModel.game.genres.joined(separator: ", "))
            .multilineTextAlignment(.leading)
        
        Text(viewModel.game.summary)
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    GameDetailsView(viewModel: .init(game: DisplayLogic.makeGame(id: "1", name: "The Witcher")))
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
    
    static func makeGame(id: String, name: String) -> Game {
        Game(
            id: id,
            name: name,
            coverURL: DisplayLogic.testImage,
            summary: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec pharetra, metus et elementum euismod, est erat tincidunt purus, sed porta arcu massa id ligula. Aenean accumsan ex et enim aliquam dapibus. Donec eleifend vestibulum sem, volutpat commodo enim luctus in. Vestibulum id tristique ex. Mauris eget arcu sit amet ligula rhoncus facilisis. Proin non tortor ut mauris pretium malesuada. Nullam at condimentum lectus, porta varius nulla. Mauris in enim vel urna luctus vehicula ut eu magna. Praesent libero augue, convallis sed turpis vitae, rutrum scelerisque nisl. Vivamus vitae lacus eget erat laoreet lobortis.
""",
            rating: 33.42112311,
            platforms: ["Google Stadia", "Mac", "PC (Microsoft Windows)", "PlayStation 5", "Xbox Series X|S"],
            genres: ["Role-playing (RPG)", "Strategy", "Turn-based strategy (TBS)", "Tactical, Adventure"],
            videosIDs: nil
        )
    }
}
