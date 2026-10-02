//
//  PokemonDetailView.swift
//  Dex
//
//  Created by Olivier Sbg on 30/09/2026.
//

import SwiftUI
import CoreData

struct PokemonDetailView: View {
    @Environment(\EnvironmentValues.managedObjectContext
    ) private var viewContext
    
    @EnvironmentObject
    private var pokemon: Pokemon
    
    @State private var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                
                AsyncImage(url: pokemon.sprite) { image in
                    image
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 100)
                        .padding(.horizontal, 40)
                        .shadow(color: .black, radius: 6)
                } placeholder: {
                    ProgressView()
                        .scaleEffect(8)
                }
            }
            
            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
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
                        try viewContext.save()
                    } catch {
                        print(error)
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.title)
                        .tint(.yellow)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            VStack(alignment: .leading) {
                Text("Stats:")
                    .font(.title)
                    .padding(.bottom, -7)
                
                StatsView(pokemon: pokemon)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("#\(pokemon.id) \(pokemon.name!.capitalized)")
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
