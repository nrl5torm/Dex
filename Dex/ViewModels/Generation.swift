//
//  Generation.swift
//  Dex
//
//  Created by Olivier Sbg on 14/10/2026.
//

import SwiftUI

struct Generation: Identifiable {
    let id: String
    
    let firstPokemon: Int
    let lastPokemon: Int
    
    @State var isExpanded: Bool = false
    
    var name: String {
        "Generation \(id)"
    }
}

enum Generations {
    static var lastPokemon: Int {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            25
        } else {
            all.last!.lastPokemon
        }
    }
    
    static let all = [
        Generation(id: "I", firstPokemon: 1, lastPokemon: 151),
        Generation(id: "II", firstPokemon: 152, lastPokemon: 251),
        Generation(id: "III", firstPokemon: 252, lastPokemon: 386),
        
        Generation(id: "IV", firstPokemon: 387, lastPokemon: 493),
        Generation(id: "V", firstPokemon: 494, lastPokemon: 649),
        Generation(id: "VI", firstPokemon: 650, lastPokemon: 721),
        
        Generation(id: "VII", firstPokemon: 722, lastPokemon: 809),
        Generation(id: "VIII", firstPokemon: 810, lastPokemon: 905),
        Generation(id: "IX", firstPokemon: 906, lastPokemon: 1025),
    ]
    
    static func genName(for pokemon: Pokemon) -> String? {
        Generations.all.first(where: { generation in
            pokemon.id >= generation.firstPokemon && pokemon.id <= generation.lastPokemon
        })?.name
    }
}
