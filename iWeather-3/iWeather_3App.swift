//
//  iWeather_3App.swift
//  iWeather-3
//
//  Created by meow on 5/14/25.
//

import SwiftUI

@main
struct iWeather_3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
