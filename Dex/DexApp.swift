//
//  DexApp.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import SwiftData

@main
struct DexApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(DexModelContainer().persistent)
    }
}
