//
//  GameDetailsView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import SwiftUI

struct GameDetailsView: View {
    
    let game: Game
    let urlEncoder: GameImageURLEncoder
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: coverURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Rating").font(.title)
                            Text("\(Int(floor(game.rating))) / 100")
                        }
                    }
                    
                    if let platforms = game.platforms {
                        section(
                            title: "Platforms",
                            body: platforms.joined(separator: ", ")
                        )
                    }
                    
                    if let genres = game.genres {
                        section(
                            title: "Genres",
                            body: genres.joined(separator: ", ")
                        )
                    }
                    
                    if let videoID = game.videosIDs?.last {
                        YouTubeView(videoID: videoID)
                            .frame(maxWidth: .infinity, idealHeight: 300)
                            .padding(.vertical, 10)
                    }
                    
                    section(title: "Summary", body: game.summary)
                }
                .padding()
            }
            .navigationTitle(game.name)
        }
    }
    
    @ViewBuilder
    func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title)
            
            Text(body)
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 10)
    }
    
    private var coverURL: URL {
        urlEncoder.encode(game.coverURL, forSize: .landscape)
    }
}

#Preview {
    NavigationView {
        GameDetailsView(game: makeGame(id: "1", name: "The Witcher"), urlEncoder: IGDBGameImageURLEncoder())
    }
    
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
