//
//  PokemonSpecies.swift
//  Dex
//
//  Created by Olivier Sbg on 13/10/2026.
//

import Foundation

struct PokemonSpecies: Decodable {
    let id: Int
    let names: [Name]
    
    struct Name: Decodable {
        let name: String
        let language: Language
    }
    
    var nameFR: String? {
        names.first { n in
            n.language.name == .fr
        }?.name
    }
    
    var nameJAhk: String? {
        names.first { n in
            n.language.name == .jaHrkt
        }?.name
    }
    
    var nameJAro: String? {
        names.first { n in
            n.language.name == .jaRoma
        }?.name
    }
}
