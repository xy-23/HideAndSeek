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
    @StateObject private var gameViewModel: GameViewModel
    @StateObject private var roomViewModel: RoomViewModel
    
    init() {
        let gameVM = GameViewModel()
        _gameViewModel = StateObject(wrappedValue: gameVM)
        _roomViewModel = StateObject(wrappedValue: RoomViewModel(gameViewModel: gameVM))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView()
                    .navigationDestination(isPresented: .constant(roomViewModel.currentRoom != nil)) {
                        Group {
                            if roomViewModel.currentRoom?.gameStatus == .playing {
                                GameView()
                                    .sheet(isPresented: $gameViewModel.showResult) {
                                        ResultView()
                                    }
                            } else {
                                RoomView()
                            }
                        }
                    }
            }
            .environmentObject(roomViewModel)
            .environmentObject(gameViewModel)
        }
    }
}
