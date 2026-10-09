//
//  Pokemon.swift
//  Dex
//
//  Created by Olivier Sbg on 08/10/2026.
//
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Pokemon: Decodable {
    @Attribute(.unique)
    var id: Int
    
    var name: String
    var types: [String]
    
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int
    
    var spriteURL: URL
    var shinyURL: URL
    var shiny: Data?
    var sprite: Data?
    
    var favorite: Bool = false
    
    
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
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
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
        
        id = try container.decode(Int.self, forKey: .id)
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
        
        var decodedStats: [Stats: Int] = [:]
        var statsArrayContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsArrayContainer.isAtEnd {
            let statsDictContainer = try statsArrayContainer.nestedContainer(keyedBy: CodingKeys.StatsDictKeys.self)
            let baseStat = try statsDictContainer.decode(Int.self, forKey: .baseStat)
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
        
        spriteURL = try spritesContainer.decode(URL.self, forKey: .spriteURL)
        shinyURL = try spritesContainer.decode(URL.self, forKey: .shinyURL)
    }
    
    var searchKey: String {
        "\(name) \(id)"
    }
    
    var spriteView: Image {
        if let data = sprite,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
        } else {
            Image("bulbasaur")
        }
    }
    
    var shinyView: Image {
        if let data = shiny,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
        } else {
            Image("shinybulbasaur")
        }
    }
    
    @MainActor
    var background: ImageResource {
        switch types[0] {
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
            
        case "fire", "dragon":
                .firedragon
            
        case "flying", "bug":
                .flyingbug
            
        case "ice":
                .ice
            
        case "water":
                .water
            
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    
    var typeColor: Color {
        Color(types[0].capitalized)
    }
    
    var stats: [Stat] {
        [
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "Special Attack", value: specialAttack),
            Stat(id: 5, name: "Special Defense", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)
        ]
    }
    
    var highestStat: Stat {
        stats.max { $0.value < $1.value }!
    }
}
