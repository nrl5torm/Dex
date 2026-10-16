//
//  PokemonDetailView.swift
//  Dex
//
//  Created by Olivier Sbg on 30/09/2026.
//

import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    @Environment(\.modelContext)
    private var modelContext
    
    public var pokemon: Pokemon
    
    @State private var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                pokemon.background
                    .resizable()
                    .scaledToFit()
                
                if pokemon.sprite == nil || pokemon.shiny == nil {
                    AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                        image
                            .interpolation(.none)
                            .scaleEffect(2)
                            .padding(.top, 180)
                            .padding(.horizontal, 40)
                            .shadow(color: .black, radius: 6)
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(8)
                    }
                } else {
                    let image = showShiny ? pokemon.shinyView : pokemon.spriteView
                    
                    image
                        .interpolation(.none)
                        .scaleEffect(2)
                        .padding(.top, 180)
                        .padding(.horizontal, 40)
                        .shadow(color: .black, radius: 6)
                }
            }
            
            HStack {
                ForEach(pokemon.types, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                }
                
                Spacer()
                
                Button {
                    pokemon.favorite.toggle()
                    do {
                        try modelContext.save()
                    } catch {
                        print(error)
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.title)
                        .tint(.yellow)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Stats:")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, -5)
                
                StatsView(pokemon: pokemon)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            VStack(alignment: .leading) {
                Text("Name translations:")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 5)
                
                HStack {
                    let names = DexLanguageCode.supportedLanguages.map { language in
                        "\(language.flag) \(pokemon.localizedName(in: language))"
                    }
                        .joined(separator: "\n")
                    
                    Text(names)
                        .font(.title3)
                        .textSelection(.enabled)
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("#\(String(pokemon.id)) \(pokemon.localizedName(in: DexLanguageCode.userLanguage))")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    Image(systemName: "wand.and.stars")
                }
                .tint(showShiny ? .yellow : .primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(pokemon: DexModelContainer.previewPokemon)
    }
}
