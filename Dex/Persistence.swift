//
//  Persistence.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController() // controls the "database"

    @MainActor
    static let preview: PersistenceController = { // the sample preview database
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
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
        pokemon.sprite = URL(string:  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        pokemon.shiny = URL(string:  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
        do {
            try viewContext.save()
        } catch {
            print(error)
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer // the "database"

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
