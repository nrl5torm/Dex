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
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypesDictKeys: CodingKey {
            case type
            enum TypeDictKeys: CodingKey {
                case name
            }
        }
        
        enum StatsDictKeys: CodingKey {
            case baseStat
            case stat
            enum StatDictKeys: CodingKey {
                case name
            }
        }
        
        enum SpriteDictKeys: String, CodingKey {
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }
    
    enum Stats {
        case hp
        case attack
        case defense
        case specialAttack
        case specialDefense
        case speed
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int16.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        var decodedTypes: [String] = []
        var typesArrayContainer = try container.nestedUnkeyedContainer(forKey: .types)
        while !typesArrayContainer.isAtEnd {
            let typesDictContainer = try typesArrayContainer.nestedContainer(keyedBy: CodingKeys.TypesDictKeys.self)
            let typeDictContainer = try typesDictContainer.nestedContainer(keyedBy: CodingKeys.TypesDictKeys.TypeDictKeys.self, forKey: .type)
            let type = try typeDictContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        
        if decodedTypes.count > 1 && (decodedTypes[0] == "normal" || decodedTypes[1] == "ice") {
            decodedTypes.swapAt(0, 1)
        }
        
        types = decodedTypes
        
        var decodedStats: [Stats: Int16] = [:]
        var statsArrayContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsArrayContainer.isAtEnd {
            let statsDictContainer = try statsArrayContainer.nestedContainer(keyedBy: CodingKeys.StatsDictKeys.self)
            let baseStat = try statsDictContainer.decode(Int16.self, forKey: .baseStat)
            let statDictContainer = try statsDictContainer.nestedContainer(keyedBy: CodingKeys.StatsDictKeys.StatDictKeys.self, forKey: .stat)
            
            let name = try statDictContainer.decode(String.self, forKey: .name)
            switch name {
                
            case "hp":
                decodedStats[.hp] = baseStat
            case "attack":
                decodedStats[.attack] = baseStat
            case "defense":
                decodedStats[.defense] = baseStat
            case "specialAttack":
                decodedStats[.specialAttack] = baseStat
            case "specialDefense":
                decodedStats[.specialDefense] = baseStat
            case "speed":
                decodedStats[.speed] = baseStat
            default:
                continue
            }
        }
        
        hp = decodedStats[.hp] ?? 0
        attack = decodedStats[.attack] ?? 0
        defense = decodedStats[.defense] ?? 0
        specialAttack = decodedStats[.specialAttack] ?? 0
        specialDefense = decodedStats[.specialDefense] ?? 0
        speed = decodedStats[.speed] ?? 0
        
        let spritesContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteDictKeys.self, forKey: .sprites)
        
        sprite = try spritesContainer.decode(URL.self, forKey: .sprite)
        shiny = try spritesContainer.decode(URL.self, forKey: .shiny)
    }
}
