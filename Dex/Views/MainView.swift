//
//  ContentView.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Pokemon.id, animation: .default)
    private var pokedex: [Pokemon]
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    @State private var deepLinkedPokemon: Pokemon?
    @State private var fetching = false

    private let fetcher = Fetcher()

    @AppStorage(
        DexLanguageCode.Storage.key,
        store: UserDefaults(suiteName: DexLanguageCode.Storage.group)
    ) private var selectedLanguage: DexLanguageCode = .defaultEN
    
    private var dynamicPredicate: Predicate<Pokemon> {
        let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return #Predicate<Pokemon> {
            (!filterByFavorites || $0.favorite) &&
            (normalizedSearchText.isEmpty || $0.searchKey.localizedStandardContains(normalizedSearchText))
        }
    }
    
    var body: some View {
        if pokedex.isEmpty {
            
            ContentUnavailableView {
                Label("No Pokémon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokémon yet.\nFetch them to get started:")
            } actions: {
                Button("Fetch Pokémon", systemImage: "arrow.down.circle") {
                    getPokemons(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
            
        } else {
            let filteredPokemons = (try? pokedex.filter(dynamicPredicate)) ?? pokedex
            let visibleGenerations = Generations.all.filter { generation in
                filteredPokemons.contains { pokemon in
                    pokemon.id >= generation.firstPokemon && pokemon.id <= generation.lastPokemon
                }
            }
            
            NavigationStack {
                List {
                    ForEach(visibleGenerations) { generation in
                        let generationPokemons = filteredPokemons.filter { pokemon in
                            pokemon.id >= generation.firstPokemon && pokemon.id <= generation.lastPokemon
                        }
                        
                        GenSectionView(generation: generation,
                                       pokemons: generationPokemons,
                                       language: selectedLanguage)
                    }
                    
                    if filteredPokemons.isEmpty {
                        if !searchText.isEmpty {
                            Section {
                                EmptyView()
                            } footer: {
                                ContentUnavailableView {
                                    Label("No matches", image: .nopokemon)
                                } description: {
                                    Text("No \(filterByFavorites ? "favorite ":"")Pokémon matched your search \"\(searchText)\". Try again?")
                                }
                            }
                        } else {
                            Section {
                                EmptyView()
                            } footer: {
                                ContentUnavailableView {
                                    Label("No favorites", image: .nopokemon)
                                } description: {
                                    Text("You have no favorite Pokémon yet :-(")
                                }
                            }
                        }
                    } else if fetching {
                        Section {
                            EmptyView()
                        } footer: {
                            HStack() {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(4)
                                Spacer()
                            }
                            .padding()
                        }
                    } else if pokedex.count < Generations.lastPokemon {
                        Section {
                            EmptyView()
                        } footer: {
                            ContentUnavailableView {
                                Label("Missing Pokémon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!")
                            } actions: {
                                Button("Fetch more Pokémon", systemImage: "arrow.down.circle") {
                                    getPokemons(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Pokédex")
                .searchable(text: $searchText, prompt: "Find a Pokémon")
                .animation(.default, value: searchText)
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetailView(pokemon: pokemon)
                }
                .navigationDestination(item: $deepLinkedPokemon) { pokemon in
                    PokemonDetailView(pokemon: pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Picker("Language", selection: $selectedLanguage.animation()) {
                                ForEach(DexLanguageCode.supportedLanguages) { language in
                                    Text("\(language.flag) \(language.displayName)")
                                }
                            }
                            .onChange(of: selectedLanguage) {
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        } label: {
                            Text(selectedLanguage.flag)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorites.toggle()
                            }
                        } label: {
                            Label("Show only favorites",
                                  systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
            .task {
                if pokedex.count == Generations.lastPokemon {
                    await downloadSprites()
                }
            }.onOpenURL { url in
                guard url.scheme == "Dex" else { return }
                guard let host = url.host(), host == "showPokemon" else { return }
                guard let pokemonId = Int16(url.lastPathComponent) else { return }
                
                guard let pokémon = pokedex.first(where: { pokemon in
                    pokemon.id == pokemonId
                }) else {
                    return
                }
                
                // will navigate to pokemon detail view
                deepLinkedPokemon = pokémon
            }
        }
    }
    
    private func getPokemons(from startId: Int) {
        fetching = true
        
        Task {
            for id in startId...Generations.lastPokemon {
                do {
                    let fetched = try await fetcher.fetchPokemon(id: id)
                    let species = try await fetcher.fetchSpecies(id: id)
                    
                    fetched.name = species.name(in: .defaultEN) ?? fetched.name
                    fetched.nameFR = species.name(in: .fr)
                    fetched.nameJAhk = species.name(in: .jaHrkt)
                    fetched.nameJAro = species.name(in: .jaRoma)
                    
                    modelContext.insert(fetched)
                } catch {
                    print(error)
                }
            }
            
            fetching = false
            
            await downloadSprites()
        }
    }
    
    private func downloadSprites() async {
        guard let pokemonsMissingSprites = try? pokedex.filter(#Predicate<Pokemon> { pokemon in
            pokemon.sprite == nil || pokemon.shiny ==  nil
        }) else {
            print("Predicate for missing-sprites pokémons failed.")
            return
        }
        
        let nbPokemonsMissingSprites = pokemonsMissingSprites.count
        print("Sprites for \(Generations.lastPokemon - nbPokemonsMissingSprites) pokémons already downloaded.")
        
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
            
            print("Downloaded sprites for \(nbPokemonsMissingSprites) remaining pokémons.")
        } catch {
            print(error)
        }
    }
}

#Preview {
    MainView()
        .modelContainer(DexModelContainer.buildInMemory())
}
