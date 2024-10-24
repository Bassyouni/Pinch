//
//  GameEntity.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import CoreData

@objc(GameEntity)
internal class GameEntity: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var coverURL: URL
    @NSManaged var summary: String
    @NSManaged var rating: Double
    @NSManaged var platforms: [String]?
    @NSManaged var genres: [String]?
    @NSManaged var videosIDs: [String]?
    @NSManaged var sortIndex: Int32
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<GameEntity> {
        let request = NSFetchRequest<GameEntity>(entityName: .init(describing: GameEntity.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(GameEntity.sortIndex), ascending: true)]
        return request
    }
    
    func setProtperties(to game: Game, sortIndex: Int32) {
        id = game.id
        name = game.name
        coverURL = game.coverURL
        summary = game.summary
        rating = game.rating
        platforms = game.platforms
        genres = game.genres
        videosIDs = game.videosIDs
        self.sortIndex = sortIndex
    }
    
    var game: Game {
        Game(
            id: id,
            name: name,
            coverURL: coverURL,
            summary: summary,
            rating: rating,
            platforms: platforms,
            genres: genres,
            videosIDs: videosIDs
        )
    }
}
