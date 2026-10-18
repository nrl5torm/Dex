//
//  DexWidget.swift
//  DexWidget
//
//  Created by Olivier Sbg on 05/10/2026.
//

import WidgetKit
import SwiftUI

struct DexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    
    var entry: DexTimelineProvider.Entry
    
    var pokemonImage: some View {
        entry.sprite
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .shadow(radius: 3)
    }
    
    var typesView: some View {
        ForEach(entry.types, id: \.self) { type in
            Text(type.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.background)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(Color(type.capitalized))
                .clipShape(.capsule)
                .shadow(radius: 3)
        }
    }
    
    var hpView: some View {
        Text("HP \(entry.hp)")
            .fontWeight(.semibold)
            .foregroundStyle(.background)
            .shadow(color: .primary, radius: 1)
    }
    
    var generationView: some View? {
        if let gen = entry.generation {
            Text(gen)
                .font(.caption)
                .foregroundStyle(.background)
                .shadow(color: .primary, radius: 1)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        } else {
            nil
        }
    }
    
    var favView: some View? {
        entry.favorite ?
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
                .shadow(color: .primary, radius: 3)
        : nil
    }
    
    var body: some View {
        switch widgetSize {
        case .systemSmall:
            ZStack() {
                pokemonImage
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Text(entry.name.capitalized)
                            .fontWeight(.bold)
                            .foregroundStyle(.background)
                            .font(.title3)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .shadow(color: .primary, radius: 5)
                        
                        favView
                    }
                }
            }
            
        case .systemMedium:
            HStack {
                entry.sprite
                    .interpolation(.none)
                    .scaleEffect(2)
                    .shadow(color: .black, radius: 6)
                    .frame(width: 140)
                    .padding(.leading, 10)
                    .layoutPriority(1)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.name.capitalized)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.background)
                            .shadow(color: .primary, radius: 2)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .padding(.vertical, 1)
                        
                        favView
                    }
                    
                    HStack {
                        typesView
                    }
                    
                    hpView
                        .padding(.top, 2)
                    generationView
                }
                .layoutPriority(1)
                
                Spacer()
            }
            
        default:
            ZStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.name.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.background)
                            .shadow(color: .primary, radius: 2)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                        
                        favView
                    }
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            hpView
                            generationView
                        }
                        Spacer()
                        typesView
                    }
                }
            }
        }
    }
}

struct DexWidget: Widget {
    let kind: String = "DexWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DexTimelineProvider()) { entry in
            DexWidgetEntryView(entry: entry)
                .foregroundStyle(.black)
                .containerBackground(Color(entry.types[0].capitalized), for: .widget)
                .widgetURL(URL(string: "Dex://showPokemon/\(entry.id)"))
        }
        .configurationDisplayName("Pokémon")
        .description("See a random Pokémon.")
    }
}


#Preview(as: .systemSmall) {
    DexWidget()
} timeline: {
    PokemonEntry.entry1
    PokemonEntry.entry2
    PokemonEntry.entry3
}

#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    PokemonEntry.entry1
    PokemonEntry.entry2
    PokemonEntry.entry3
}

#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    PokemonEntry.entry1
    PokemonEntry.entry2
    PokemonEntry.entry3
}

#Preview(as: .systemExtraLargePortrait) {
    DexWidget()
} timeline: {
    PokemonEntry.entry1
    PokemonEntry.entry2
    PokemonEntry.entry3
}
