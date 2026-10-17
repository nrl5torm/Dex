//
//  GenSectionView.swift
//  Dex
//
//  Created by Olivier Sbg on 14/10/2026.
//

import SwiftUI
import SwiftData

struct GenSectionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var isExpanded = true
    var generation: Generation
    var pokemons: [Pokemon]
    var language: DexLanguageCode
    
    var body: some View {
        Section(isExpanded: $isExpanded, content: {
            
            ForEach(pokemons) { pokemon in
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
                            Text(pokemon.localizedName(in: language))
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
        }, header: {
            Text(generation.name)
                .font(.title2)
        })
    }
}

#Preview {
    GenSectionView(generation: Generations.all.first!,
                   pokemons: [DexModelContainer.previewPokemon],
                   language: .defaultEN)
}
