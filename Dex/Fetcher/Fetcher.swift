//
//  Fetcher.swift
//  Dex
//
//  Created by Olivier Sbg on 28/09/2026.
//

import Foundation

struct Fetcher {
    enum FetchError: Int16, Error {
        case badResponse = 42
    }
    
    private let basePokemonURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    private let baseSpeciesURL = URL(string: "https://pokeapi.co/api/v2/pokemon-species")!
    
    func fetchPokemon(id: Int) async throws -> Pokemon {
        let fetchURL = basePokemonURL.appending(path: String(id))
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        
        return pokemon
    }
    
    func fetchSpecies(id: Int) async throws -> PokemonSpecies {
        let fetchURL = baseSpeciesURL.appending(path: String(id))
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let species = try decoder.decode(PokemonSpecies.self, from: data)
        
        return species
    }
}
