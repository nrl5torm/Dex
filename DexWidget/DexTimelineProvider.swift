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
        var randomGenerator = SeededRandomGenerator(seedDate: Date.now)
        
        let context = ModelContext(modelContainer)
        if let pokedex = try? context.fetch(FetchDescriptor<Pokemon>()),
           !pokedex.isEmpty {
            for _ in 1...count {
                randomPokemons.append(pokedex.randomElement(using: &randomGenerator)!)
            }
        } else {
            print("ERROR", "Could not fetch pokemons.", separator: ": ")
            
            randomPokemons.append(DexModelContainer.previewPokemon)
        }
        return randomPokemons
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PokemonEntry] = []
        let currentDate = Date.now
        
        let nbEntries = 10
        let freqInSec = 15
        let randomPokemons = getRandomPokemons(nbEntries)
        
        for i in 0 ..< nbEntries {
            let entryDate = Calendar.current.date(
                byAdding: .second,
                value: i * freqInSec,
                to: currentDate) ?? currentDate
            
            let pokemon = randomPokemons[i]
            
            entries.append(PokemonEntry(
                date: entryDate,
                id: pokemon.id,
                name: pokemon.localizedName(in: DexLanguageCode.userLanguage),
                types: pokemon.types,
                hp: pokemon.hp,
                sprite: pokemon.spriteView,
                generation: pokemon.generation,
                favorite: pokemon.favorite)
            )
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
