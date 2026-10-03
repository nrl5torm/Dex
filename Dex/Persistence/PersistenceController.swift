//
//  Persistence.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import CoreData

/// Controls the persistence storage (database)
struct PersistenceController {
    static let shared = PersistenceController()

    /// A sample pokemon for previews
    static var previewPokemon: Pokemon {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try! context.fetch(fetchRequest)
        return results.first!
    }
    
    /// The sample (in-memory) database for previews
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let pokemon = Pokemon(context: viewContext)
        pokemon.id = 1
        pokemon.name = "bulbasaur"
        pokemon.types = ["grass", "poison"]
        pokemon.hp = 45
        pokemon.attack = 49
        pokemon.defense = 49
        pokemon.specialAttack = 65
        pokemon.specialDefense = 65
        pokemon.speed = 45
        pokemon.spriteURL = URL(string:  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        pokemon.shinyURL = URL(string:  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        
        return controller
    }()

    /// The container for the database (can be in-memory or on persistent storage)
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                print(error)
            }
        })
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
