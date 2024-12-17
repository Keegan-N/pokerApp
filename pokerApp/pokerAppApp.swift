//
//  pokerAppApp.swift
//  pokerApp
//
//  Created by Norgard, Keegan - Student on 10/21/24.
//

import SwiftUI

@main
struct pokerAppApp: App {
    var body: some Scene {
        WindowGroup {
            PlayView(startingMoney: 500,scores: ["player":500,"bot 1":500,"bot 2":500,"bot 3":500])
        }
    }
}
