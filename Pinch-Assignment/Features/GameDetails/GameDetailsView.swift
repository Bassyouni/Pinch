//
//  GameDetailsView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import SwiftUI

struct GameDetailsView: View {

    let game: Game
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let videoID = game.videosIDs?.last {
                    YouTubeView(videoID: videoID)
                        .frame(maxWidth: .infinity, idealHeight: 300)
                }
                
                Text(game.name)
                    .multilineTextAlignment(.leading)
                
                Text("\(Int(floor(game.rating))) / 100")
                    .multilineTextAlignment(.leading)
                
                if let platforms = game.platforms {
                    Text(platforms.joined(separator: ", "))
                        .multilineTextAlignment(.leading)
                }
                
                if let genres = game.genres {
                    Text(genres.joined(separator: ", "))
                        .multilineTextAlignment(.leading)
                }
                
                Text(game.summary)
                    .multilineTextAlignment(.leading)
            }
        }
        
    }
}

#Preview {
    GameDetailsView(game: makeGame(id: "1", name: "The Witcher"))
}

private func makeGame(id: String, name: String) -> Game {
    Game(
        id: id,
        name: name,
        coverURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_med/co4bvj.jpg")!,
        summary: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec pharetra, metus et elementum euismod, est erat tincidunt purus, sed porta arcu massa id ligula. Aenean accumsan ex et enim aliquam dapibus. Donec eleifend vestibulum sem, volutpat commodo enim luctus in. Vestibulum id tristique ex. Mauris eget arcu sit amet ligula rhoncus facilisis. Proin non tortor ut mauris pretium malesuada. Nullam at condimentum lectus, porta varius nulla. Mauris in enim vel urna luctus vehicula ut eu magna. Praesent libero augue, convallis sed turpis vitae, rutrum scelerisque nisl. Vivamus vitae lacus eget erat laoreet lobortis.
""",
        rating: 33.42112311,
        platforms: ["Google Stadia", "Mac", "PC (Microsoft Windows)", "PlayStation 5", "Xbox Series X|S"],
        genres: ["Role-playing (RPG)", "Strategy", "Turn-based strategy (TBS)", "Tactical, Adventure"],
        videosIDs: nil
    )
}
