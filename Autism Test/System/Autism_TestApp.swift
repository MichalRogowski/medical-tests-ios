//
//  Autism_TestApp.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import SwiftUI

@main
struct Autism_TestApp: App {

    var body: some Scene {
        let environment = AppEnvironment.bootstrap()

        return WindowGroup {
            ContentView(container: environment.container)
        }
    }
}
