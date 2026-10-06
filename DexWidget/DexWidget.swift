//
//  DexWidget.swift
//  DexWidget
//
//  Created by Olivier Sbg on 05/10/2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        for _ in 0 ..< 5 {
            let entry = SimpleEntry.placeholder
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let name: String
    let types: [String]
    let hp: Int16
    let sprite: Image
    
    static var placeholder: SimpleEntry {
        SimpleEntry(date: .now,
                    name: "bulbasaur",
                    types: ["grass", "poison"],
                    hp: 45,
                    sprite: Image(.bulbasaur)
        )
    }
    
    static var placeholder2: SimpleEntry {
        SimpleEntry(date: .now,
                    name: "mew",
                    types: ["psychic"],
                    hp: 100,
                    sprite: Image(.mew)
        )
    }
    
    static var placeholder3: SimpleEntry {
        SimpleEntry(date: .now,
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
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
    SimpleEntry.placeholder3
}


#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
    SimpleEntry.placeholder3
}


#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
    SimpleEntry.placeholder3
}

#Preview(as: .systemExtraLargePortrait) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
    SimpleEntry.placeholder3
}
