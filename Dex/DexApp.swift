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
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    guard url.scheme == "Dex" else { return }
                    print(url) // parse the url to get someAction to determine what the app needs do
                    //TODO open corresponding detail view
                }
        }
    }
}
