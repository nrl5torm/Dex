//
//  PokemonEntry.swift
//  Dex
//
//  Created by Olivier Sbg on 09/10/2026.
//

import WidgetKit
import SwiftUI


struct PokemonEntry: TimelineEntry {
    let date: Date
    
    let id: Int
    let name: String
    let types: [String]
    let hp: Int
    let sprite: Image
    
    static var entry1: PokemonEntry {
        PokemonEntry(date: .now,
                     id: 1,
                     name: "bulbasaur",
                     types: ["grass", "poison"],
                     hp: 45,
                     sprite: Image(.bulbasaur)
        )
    }
    
    static var entry2: PokemonEntry {
        PokemonEntry(date: .now,
                     id: 151,
                     name: "mew",
                     types: ["psychic"],
                     hp: 100,
                     sprite: Image(.mew)
        )
    }
    
    static var entry3: PokemonEntry {
        PokemonEntry(date: .now,
                     id: 6,
                     name: "charizard",
                     types: ["fire", "flying"],
                     hp: 78,
                     sprite: Image(.charizard)
        )
    }
}
