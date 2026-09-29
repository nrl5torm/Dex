//
//  ContentView.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\EnvironmentValues.managedObjectContext
    ) private var viewContext
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    ) private var pokedex
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    private let fetcher = Fetcher()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        if !searchText.isEmpty {
            let nameContains = NSPredicate(format: "name contains[c] %@", searchText)
            let idContains = NSPredicate(format: "id contains %@", searchText)
            predicates.append(
                NSCompoundPredicate(orPredicateWithSubpredicates: [nameContains, idContains]))
        }
        
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
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
                            HStack {
                                Text(pokemon.name!.capitalized)
                                    .fontWeight(.bold)
                                
                                if pokemon.favorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
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
            .navigationTitle("Pokedex")
            .searchable(text: $searchText, prompt: "Find a Pokémon")
            .onChange(of: searchText, {
                updateFilter()
            })
            .onChange(of: filterByFavorites, {
                updateFilter()
            })
            .navigationDestination(for: Pokemon.self,
                                   destination: { pokemon in
                Text("\(pokemon.id). \(pokemon.name ?? "no name"): HP \(pokemon.hp)")

            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        filterByFavorites.toggle()
                    } label: {
                        Label("Show only favorites",
                              systemImage: filterByFavorites ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                }
                ToolbarItem {
                    Button("Add", systemImage: "plus") {
                        getPokemons()
                    }
                }
            }
        }
    }
    
    private func updateFilter() {
        pokedex.nsPredicate = dynamicPredicate
    }
    
    private func getPokemons() {
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
