//
//  CoreDataGamesRepository.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import Combine
import CoreData

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
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension CoreDataGamesRepository: GamesSaver {
    public func saveGames(_ games: [Game]) -> AnyPublisher<Void, Error> {
        Empty().eraseToAnyPublisher()
    }
}
