//
//  CoreDataGamesRepository.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine
import CoreData

@objc(GameEntity)
private class GameEntity: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var coverURL: String
    @NSManaged var sortIndex: Int32
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameEntity> {
        let request = NSFetchRequest<GameEntity>(entityName: .init(describing: GameEntity.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(GameEntity.sortIndex), ascending: true)]
        return request
    }
}


public final class CoreDataGamesRepository {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(inMemory: Bool = false) {
        let container = NSPersistentContainer(name: "GamesStore")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        
        self.container = container
        self.context = container.newBackgroundContext()
    }
}

extension CoreDataGamesRepository: GamesLoader {
    public func loadGames() -> AnyPublisher<[Game], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            
            do {
                let request = GameEntity.fetchRequest()
                let games = try self.context.fetch(request)
                let models = games.map { game in
                    Game(
                        id: game.id,
                        name: game.name,
                        coverURL: URL(string: game.coverURL)!
                    )
                }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension CoreDataGamesRepository: GamesSaver {
    public func saveGames(_ games: [Game]) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            
            do {
                let request = GameEntity.fetchRequest()
                request.fetchLimit = 1
                let maxSortIndex = try self.context.fetch(request).first?.sortIndex ?? -1
                
                for (index, game) in games.enumerated() {
                    let managedGame = GameEntity(context: self.context)
                    managedGame.id = game.id
                    managedGame.name = game.name
                    managedGame.coverURL = game.coverURL.absoluteString
                    managedGame.sortIndex = maxSortIndex + Int32(index + 1)
                }
                
                try self.context.save()
                promise(.success(()))
                
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
