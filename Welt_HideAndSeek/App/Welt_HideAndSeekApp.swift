//
//  Welt_HideAndSeekApp.swift
//  Welt_HideAndSeek
//
//  Created by admin on 2024/12/20.
//

import SwiftUI
import CoreLocation

@main
struct Welt_HideAndSeekApp: App {
    @StateObject private var roomViewModel = RoomViewModel()
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(roomViewModel)
                .environmentObject(gameViewModel)
        }
    }
}
