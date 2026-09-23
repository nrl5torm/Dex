//
//  DexApp.swift
//  Dex
//
//  Created by Olivier Sbg on 23/09/2026.
//

import SwiftUI
import CoreData

@main
struct DexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
