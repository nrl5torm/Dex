//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Olivier Sbg on 27/09/2026.
//

import Foundation

struct FetchedPokemon: Decodable {
    let id: Int16
    
    let name: String
    let types: [String]
    
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    
    let sprite: URL
    let shiny: URL
    
    enum PokemonCodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey {
            case type
            enum NameDictionaryKeys: CodingKey {
                case name
            }
        }
        
        enum StatDictionaryKeys: CodingKey {
            case baseStat
        }
        
        enum SpriteDictionaryKeys: String, CodingKey {
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PokemonCodingKeys.self)
        
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.types = try container.decode([String].self, forKey: .types.type)
    }
}
