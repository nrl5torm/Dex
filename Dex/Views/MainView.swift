//
//  ContentView.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext)
    private var modelContext
    
    @Query(sort: \Pokemon.id, animation: .default)
    private var pokedex: [Pokemon]
    
    let NbPokemons = 151
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    @State private var fetching = false
    
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
    
    @State private var deepLinkedPokemon: Pokemon?
    
    var body: some View {
        if pokedex.isEmpty {
            
            ContentUnavailableView {
                Label("No Pokémons", image: .nopokemon)
            } description: {
                Text("There aren't any Pokémons yet.\n Fetch them to get started:")
            } actions: {
                Button("Fetch Pokémons", systemImage: "arrow.down.circle") {
                    getPokemons(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
            
        } else {
    
            NavigationStack {
                List {
                    Section() {
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    pokemon.spriteView
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    HStack {
                                        ForEach(pokemon.types, id: \.self) { type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .shadow(color: .white, radius: 1)
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
                                        try modelContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if fetching {
                            HStack() {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(4)
                                Spacer()
                            }
                            .padding()
                            
                        } else if pokedex.count < NbPokemons {
                            ContentUnavailableView {
                                Label("Missing Pokémons", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\n Fetch the rest of the Pokémons:")
                            } actions: {
                                Button("Fetch Pokémons", systemImage: "arrow.down.circle") {
                                    getPokemons(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }

                        }
                    }
                }
                .navigationTitle("Pokédex")
                .searchable(text: $searchText, prompt: "Find a Pokémon")
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetailView(pokemon: pokemon)
                }
                .navigationDestination(item: $deepLinkedPokemon) { pokemon in
                    PokemonDetailView(pokemon: pokemon)
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
                if pokedex.count == NbPokemons {
                    downloadSprites()
                }
            }.onOpenURL { url in
                guard url.scheme == "Dex" else { return }
                guard let host = url.host(), host == "showPokemon" else { return }
                
                guard let pokemonId = Int16(url.lastPathComponent) else { return }
                guard let pokémon = pokedex.first(where: { pokemon in
                    pokemon.id == pokemonId
                }) else { return }
                
                // open details for pokémon identified by deep link
                deepLinkedPokemon = pokémon
            }
        }
    }
    
    private func getPokemons(from startId: Int) {
        fetching = true
        
        Task {
            for id in startId...NbPokemons {
                do {
                    let fetched = try await fetcher.fetchPokemon(id: id)
                    modelContext.insert(fetched)
                } catch {
                    print(error)
                }
            }
            
            fetching = false
            
            downloadSprites()
        }
    }
    
    private func downloadSprites() {
        Task {
            //TODO
//            let spritePred = NSPredicate(format: "sprite = nil")
//            let shinyPred = NSPredicate(format: "shiny = nil")
//            let nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [spritePred, shinyPred])
            let pokemonsMissingSprites = pokedex
            let nbPokemonsMissingSprites = pokemonsMissingSprites.count
            guard nbPokemonsMissingSprites != 0 else {
                print("Sprites for \(NbPokemons) pokémons already downloaded.")
                return
            }
            
            do {
                for pokemon in pokemonsMissingSprites {
                    if pokemon.sprite == nil {
                        let (sprite, _) = try await URLSession.shared.data(from: pokemon.spriteURL)
                        pokemon.sprite = sprite
                    }
                    
                    if pokemon.shiny == nil {
                        let (shiny, _) = try await URLSession.shared.data(from: pokemon.shinyURL)
                        pokemon.shiny = shiny
                    }
                    
                    try modelContext.save()
                }
            
                print("Downloaded missing sprites for \(nbPokemonsMissingSprites) pokémons.")
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(DexModelContainer.buildInMemory())
}
