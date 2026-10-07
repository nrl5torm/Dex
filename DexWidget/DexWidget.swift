//
//  DexWidget.swift
//  DexWidget
//
//  Created by Olivier Sbg on 05/10/2026.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    func getRandomPokemon() -> Pokemon {
        var results: [Pokemon] = []
        
        do {
            results = try PersistenceController.shared.container
                .viewContext.fetch(Pokemon.fetchRequest())
        } catch {
            print("Couldn't fetch: \(error)")
        }
        
        if let randomPokemon = results.randomElement() {
            return randomPokemon
        }
        
        return PersistenceController.previewPokemon
    }
    
    func placeholder(in context: Context) -> PokemonEntry {
        PokemonEntry.placeholder1
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PokemonEntry) -> ()) {
        completion(PokemonEntry.placeholder1)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PokemonEntry] = []
        
        let currentDate = Date()
        for seconds in 0 ..< 10 {
            let entryDate = Calendar.current.date(
                byAdding: .second,
                value: seconds * 30,
                to: currentDate)!
            
            let pokemon = getRandomPokemon()
            let entry = PokemonEntry(
                date: entryDate,
                id: pokemon.id,
                name: pokemon.name!,
                types: pokemon.types!,
                hp: pokemon.hp,
                sprite: pokemon.spriteView)
            
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
}

struct PokemonEntry: TimelineEntry {
    let date: Date
    
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let sprite: Image
    
    static var placeholder1: PokemonEntry {
        PokemonEntry(date: .now,
                     id: 1,
                     name: "bulbasaur",
                     types: ["grass", "poison"],
                     hp: 45,
                     sprite: Image(.bulbasaur)
        )
    }
    
    static var placeholder2: PokemonEntry {
        PokemonEntry(date: .now,
                     id: 151,
                     name: "mew",
                     types: ["psychic"],
                     hp: 100,
                     sprite: Image(.mew)
        )
    }
    
    static var placeholder3: PokemonEntry {
        PokemonEntry(date: .now,
                     id: 6,
                     name: "charizard",
                     types: ["fire", "flying"],
                     hp: 78,
                     sprite: Image(.charizard)
        )
    }
}

struct DexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    
    var entry: Provider.Entry
    
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            //            if #available(iOS 17.0, *) {
            DexWidgetEntryView(entry: entry)
                .foregroundStyle(.black)
                .containerBackground(Color(entry.types[0].capitalized), for: .widget)
                .widgetURL(URL(string: "Dex://open/\(entry.id)"))
            //            } else {
            //                DexWidgetEntryView(entry: entry)
            //                    .padding()
            //                    .background()
            //            }
        }
        .configurationDisplayName("Pokémon")
        .description("See a random Pokémon.")
    }
}

#Preview(as: .systemSmall) {
    DexWidget()
} timeline: {
    PokemonEntry.placeholder1
    PokemonEntry.placeholder2
    PokemonEntry.placeholder3
}


#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    PokemonEntry.placeholder1
    PokemonEntry.placeholder2
    PokemonEntry.placeholder3
}


#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    PokemonEntry.placeholder1
    PokemonEntry.placeholder2
    PokemonEntry.placeholder3
}

#Preview(as: .systemExtraLargePortrait) {
    DexWidget()
} timeline: {
    PokemonEntry.placeholder1
    PokemonEntry.placeholder2
    PokemonEntry.placeholder3
}
