//
//  Persistence.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftData
import Foundation

@MainActor
struct DexModelContainer {
    /// Persistent container ("database") for normal app execution
    public let persistent: ModelContainer = {
        let schema = Schema([
            Pokemon.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    /// A sample pokemon for previews
    static var previewPokemon: Pokemon {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemonData = try! Data(
            contentsOf: Bundle.main.url(forResource: "samplepokemon", withExtension: "json")!)
        
        let pokemon = try! decoder.decode(Pokemon.self, from: pokemonData)
        return pokemon
    }
    
    /// In-memory container with sample pokemon for previews
    public let inMemory: ModelContainer = {
        let container = try! ModelContainer(for: Pokemon.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(previewPokemon)
        return container
    }()
}
