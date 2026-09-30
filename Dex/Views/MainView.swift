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
    ) private var selection
    
    @FetchRequest<Pokemon>(sortDescriptors: []
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
        if pokedex.isEmpty {
            
            ContentUnavailableView {
                Label("No Pokémons", image: .nopokemon)
            } description: {
                Text("There aren't any Pokémon yet.\n Fetch them to get started:")
            } actions: {
                Button("Fetch Pokémons", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemons(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
            
        } else {
    
            NavigationStack {
                List {
                    Section() {
                        ForEach(selection) { pokemon in
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
                            .swipeActions(edge: .leading) {
                                Button(pokemon.favorite ? "Unfavorite" : "Favorite", systemImage: "star") {
                                    pokemon.favorite.toggle()
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if pokedex.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokémons", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\n Fetch the rest of the Pokémons:")
                            } actions: {
                                Button("Fetch Pokémons", systemImage: "arrow.down.circle") {
                                    getPokemons(from: selection.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
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
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetailView()
                        .environmentObject(pokemon)
                }
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
                }
            }
            .task {
                getPokemons(from: 1)
            }
        }
    }
    
    private func updateFilter() {
        selection.nsPredicate = dynamicPredicate
    }
    
    private func getPokemons(from startId: Int) {
        Task {
            for id in startId...151 {
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
