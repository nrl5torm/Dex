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
    
    struct Language: Decodable {
        let name: DexLanguageCode
        let url: URL
    }

    func name(in language: DexLanguageCode) -> String? {
        names.first { n in
            n.language.name == language
        }?.name
    }
}
