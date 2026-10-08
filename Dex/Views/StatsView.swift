//
//  StatsView.swift
//  Dex
//
//  Created by Olivier Sbg on 02/10/2026.
//

import SwiftUI
import Charts

struct StatsView: View {
    let pokemon: Pokemon
    
    var body: some View {
        Chart(pokemon.stats) { stat in
            BarMark(x: .value("Value", stat.value),
                    y: .value("Stat", stat.name)
            )
            .foregroundStyle(pokemon.typeColor)
            .annotation(position: .trailing) {
                Text(String(stat.value))
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .padding(.top, -3)
            }
        }
        .frame(height: 200)
        .chartXScale(domain: 0...pokemon.highestStat.value
                     + max(10, Int(Double(pokemon.highestStat.value) * 0.2)))
        .chartXAxis {
            AxisMarks {
                AxisGridLine()
                AxisValueLabel(anchor: .topLeading)
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisValueLabel(anchor: .topLeading)
            }
        }
    }
}

#Preview {
    StatsView(pokemon: DexModelContainer.previewPokemon)
}
