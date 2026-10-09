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
            .shadow(color: .black, radius: 6)
    }
    
    var typesView: some View {
        ForEach(entry.types, id: \.self) { type in
            Text(type.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
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
    }
    
    var body: some View {
        switch widgetSize {
        case .systemSmall:
            ZStack() {
                pokemonImage
                
                VStack {
                    Spacer()
                    
                    Text(entry.name.capitalized)
                        .fontWeight(.bold)
                        .font(.title3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .shadow(color: .white, radius: 5)
                }
            }
            
        case .systemMedium:
            HStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.title)
                        .bold()
                        .shadow(color: .white, radius: 2)
                        .minimumScaleFactor(0.5)
                        .padding(.vertical, 1)
                    
                    HStack {
                        typesView
                    }
                    
                    hpView
                        .padding(1)
                }
                .layoutPriority(1)
                
                Spacer()
            }
            
        default:
            ZStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .bold()
                        .shadow(color: .white, radius: 2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    HStack {
                        hpView
                        
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
