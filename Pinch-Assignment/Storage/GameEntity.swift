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
    @NSManaged var coverURL: String
    @NSManaged var sortIndex: Int32
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<GameEntity> {
        let request = NSFetchRequest<GameEntity>(entityName: .init(describing: GameEntity.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(GameEntity.sortIndex), ascending: true)]
        return request
    }
    
    func setProtperties(to game: Game, sortIndex: Int32) {
        id = game.id
        name = game.name
        coverURL = game.coverURL.absoluteString
        self.sortIndex = sortIndex
    }
    
    var game: Game {
        Game(id: id, name: name, coverURL: URL(string: coverURL)!)
    }
}
