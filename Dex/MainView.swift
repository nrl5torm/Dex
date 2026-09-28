//
//  ContentView.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\EnvironmentValues.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>
    
    private let fetcher = Fetcher()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink {
                        Text("\(pokemon.name ?? "no name"): HP \(pokemon.hp)")
                    } label: {
                        Text(pokemon.name ?? "no name")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
        }
    }
    
    private func getPokemon() {
        Task {
            for id in 1...151 {
                do {
                    let fetched = try await fetcher.fetchPokemon(id: id)
                    
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetched.id
                    pokemon.name = fetched.name
                    pokemon.types = fetched.types
                    pokemon.hp = fetched.hp
                    pokemon.attack = fetched.attack
                    pokemon.defense = fetched.defense
                    pokemon.specialAttack = fetched.specialAttack
                    pokemon.specialDefense = fetched.specialDefense
                    pokemon.speed = fetched.speed
                    pokemon.sprite = fetched.sprite
                    pokemon.shiny = fetched.shiny
                    
                    try viewContext.save()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    MainView().environment(
        \.managedObjectContext,
         PersistenceController.preview.container.viewContext)
}
