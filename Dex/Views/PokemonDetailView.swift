//
//  PokemonDetailView.swift
//  Dex
//
//  Created by Olivier Sbg on 30/09/2026.
//

import SwiftUI

struct PokemonDetailView: View {
    @Environment(\EnvironmentValues.managedObjectContext
    ) private var viewContext
    
    @EnvironmentObject
    private var pokemon: Pokemon
    
    @State private var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(.normalgrasselectricpoisonfairy)
                    .resizable()
                    .scaledToFit()
//                    .shadow(color: .black, radius: 6)
                
                AsyncImage(url: pokemon.sprite) { image in
                    image
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .padding(.horizontal, 40)
                        .shadow(color: .black, radius: 6)
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .navigationTitle(pokemon.name!.capitalized)
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
