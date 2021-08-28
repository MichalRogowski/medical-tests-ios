//
//  Autism_TestApp.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import SwiftUI

@main
struct Autism_TestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
