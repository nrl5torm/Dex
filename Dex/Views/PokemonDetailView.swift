//
//  PokemonDetailView.swift
//  Dex
//
//  Created by Olivier Sbg on 30/09/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct PokemonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    public var pokemon: Pokemon
    
    @State private var showShiny = false
    
    var body: some View {
        GeometryReader { geo in
            
            ScrollView {
                ZStack(alignment: .bottom) {
                    pokemon.background
                        .resizable()
                        .scaledToFill()
                        .frame(height: geo.size.height > geo.size.width ? 380 : 250, alignment: .bottom)
                        .clipped()
                        .ignoresSafeArea()
                    
                    if pokemon.sprite == nil || pokemon.shiny == nil {
                        let imageUrl = showShiny ? pokemon.shinyURL : pokemon.spriteURL
                        AsyncImage(url: imageUrl) { image in
                            image.scaledView
                        } placeholder: {
                            ProgressView()
                                .scaleEffect(8)
                        }
                        
                    } else {
                        let imageView = showShiny ? pokemon.shinyView : pokemon.spriteView
                        imageView
                            .scaledView
                    }
                }
                
                HStack {
                    if let gen = pokemon.generation {
                        Text(gen)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(7)
                            .overlay(Capsule()
                                .stroke(.gray, lineWidth: 1)
                            )
                    }
                    
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
                            
                            // refresh widgets
                            WidgetCenter.shared.reloadAllTimelines()
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
                    Text("Names:")
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
}

extension Image {
    var scaledView: some View {
        self.interpolation(.none)
            .scaleEffect(3)
            .padding(.bottom, 80)
            .padding(.leading, 50)
            .shadow(color: .black, radius: 6)
    }
}


#Preview {
    NavigationStack {
        PokemonDetailView(pokemon: DexModelContainer.previewPokemon)
    }
}
