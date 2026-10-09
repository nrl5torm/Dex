//
//  DexTimelineProvider.swift
//  Dex
//
//  Created by Olivier Sbg on 09/10/2026.
//

import WidgetKit
import SwiftData

struct DexTimelineProvider: TimelineProvider {
    private var modelContainer = DexModelContainer.buildPersistent()
    
    func placeholder(in context: Context) -> PokemonEntry {
        PokemonEntry.entry1
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PokemonEntry) -> ()) {
        completion(PokemonEntry.entry1)
    }
    
    func getRandomPokemons(_ count: Int) -> [Pokemon] {
        var randomPokemons: [Pokemon] = []
        
        let context = ModelContext(modelContainer)
        if let pokedex = try? context.fetch(FetchDescriptor<Pokemon>()),
           !pokedex.isEmpty {
            for _ in 1...count {
                randomPokemons.append(pokedex.randomElement()!)
            }
        } else {
            print("ERROR", "Could not fetch pokemons.", separator: ": ")
            
            randomPokemons.append(DexModelContainer.previewPokemon)
        }
        return randomPokemons
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PokemonEntry] = []
        let currentDate = Date()
        
        let nbEntries = 20
        let freqInSec = 15
        let nbPokemons = 5
        let randomPokemons = getRandomPokemons(nbPokemons)
        
        for i in 0 ..< nbEntries {
            let entryDate = Calendar.current.date(
                byAdding: .second,
                value: i * freqInSec,
                to: currentDate) ?? Date.now
            
            let pokemon = randomPokemons[i % nbPokemons]
            
            entries.append(PokemonEntry(
                date: entryDate,
                id: pokemon.id,
                name: pokemon.name,
                types: pokemon.types,
                hp: pokemon.hp,
                sprite: pokemon.spriteView)
            )
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
