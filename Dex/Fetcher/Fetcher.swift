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
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    func fetchPokemon(id: Int) async throws -> Pokemon {
        let fetchURL = baseURL.appending(path: String(id))
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        
        return pokemon
    }
}
