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
    private let queue = DispatchQueue(label: "CoreDataGameStore", qos: .userInitiated)
    
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
            self?.queue.async { [weak self] in
                guard let self else { return }
                
                promise(self.fetchGames())
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchGames() -> Result<[Game], Error> {
        do {
            let request = GameEntity.fetchRequest()
            let games = try self.context.fetch(request).map { $0.game }
            return .success(games)
        } catch {
            return .failure(error)
        }
    }
}

extension CoreDataGamesRepository: GamesSaver {
    public func saveGames(_ games: [Game]) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.queue.async { [weak self] in
                do {
                    try self?._saveGames(games)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func _saveGames(_ games: [Game]) throws {
        let request = GameEntity.fetchRequest()
        request.fetchLimit = 1
        let maxSortIndex = try self.context.fetch(request).first?.sortIndex ?? -1
        
        for (index, game) in games.enumerated() {
            let managedGame = GameEntity(context: self.context)
            let sortIndex = maxSortIndex + Int32(index + 1)
            managedGame.setProtperties(to: game, sortIndex: sortIndex)
        }
        
        try self.context.save()
    }
}
