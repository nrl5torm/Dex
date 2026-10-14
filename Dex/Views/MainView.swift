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
                    let pokemons = (try? pokedex.filter(dynamicPredicate)) ?? pokedex

                    ForEach(Generation.allGens) { generation in
                        if pokemons.last!.id >= generation.firstPokemon {
                            GenSectionView(generation: generation,
                                           pokemons: pokemons,
                                           language: selectedLanguage)
                        }
                    }
                    
                    if fetching {
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
                    } else if pokedex.count < Generation.allPokemons {
                        Section {
                            EmptyView()
                        } footer: {
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
                if pokedex.count == Generation.allPokemons {
                    downloadSprites()
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
            for id in startId...Generation.allPokemons {
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
            
            downloadSprites()
        }
    }
    
    private func downloadSprites() {
        Task {
            
            guard let pokemonsMissingSprites = try? pokedex.filter(#Predicate<Pokemon> { pokemon in
                pokemon.sprite == nil || pokemon.shiny == nil
            }) else {
                print("Predicate for pokémons missing sprites failed.")
                return
            }
            
            let nbPokemonsMissingSprites = pokemonsMissingSprites.count
            print("Sprites for \(Generation.allPokemons - nbPokemonsMissingSprites) pokémons already downloaded.")
            
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
}

#Preview {
    MainView()
        .modelContainer(DexModelContainer.buildInMemory())
}
