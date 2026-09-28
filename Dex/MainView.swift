//
//  ContentView.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\EnvironmentValues.managedObjectContext)
    private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>
    
    private let fetcher = Fetcher()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            Text(pokemon.name!.capitalized)
                                .fontWeight(.bold)
                            
                            HStack {
                                ForEach(pokemon.types!, id: \.self) { type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 5)
                                        .background(Color(type.capitalized))
                                        .clipShape(.capsule)
                                        
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Pokemon.self,
                                   destination: { pokemon in
                Text("\(pokemon.name ?? "no name"): HP \(pokemon.hp)")

            })
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
