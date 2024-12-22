import Foundation
import CoreLocation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var playerLocations: [String: CLLocationCoordinate2D] = [:]
    @Published var gameTimeRemaining: TimeInterval = 0
    @Published var gameStatus: GameStatus = .waiting
    @Published var gameResult: GameResult?
    @Published var caughtPlayers: Set<String> = []
    @Published var showResult: Bool = false
    @Published var currentPlayers: [Player] = []

    private var gameTimer: Timer?

    private let catchDistance: Double = 5.0
    
    enum GameStatus {
        case waiting
        case playing
        case finished
    }
    
    enum GameResult {
        case seekerWin
        case runnerWin
    }
    
    func resetGame() {
        playerLocations.removeAll()
        gameTimeRemaining = 0
        gameStatus = .waiting
        gameResult = nil
        caughtPlayers.removeAll()
        showResult = false
    }
    
    private func checkGameEnd() {
        // 检查游戏是否结束
        let allRunnersCaught = caughtPlayers.count >= (playerLocations.count - 1) // 除了抓捕者外都被抓
        
        if allRunnersCaught {
            gameResult = .seekerWin
            endGame()
        } else if gameTimeRemaining <= 0 {
            gameResult = .runnerWin
            endGame()
        }
    }
    
    private func endGame() {
        gameStatus = .finished
        showResult = true
    }
    
    func updateLocation(playerId: String, location: CLLocationCoordinate2D) {
        playerLocations[playerId] = location
        checkCatchStatus(playerId: playerId)
    }
    
    private func checkCatchStatus(playerId: String) {
        guard let currentLocation = playerLocations[playerId] else { return }
        
        for (otherPlayerId, otherLocation) in playerLocations {
            if otherPlayerId != playerId {
                let distance = calculateDistance(from: currentLocation, to: otherLocation)
                if distance <= catchDistance {
                    handleCatch(seekerId: playerId, runnerId: otherPlayerId)
                }
            }
        }
    }
    
    private func calculateDistance(from location1: CLLocationCoordinate2D, to location2: CLLocationCoordinate2D) -> Double {
        let location1Point = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let location2Point = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return location1Point.distance(from: location2Point)
    }
    
    private func handleCatch(seekerId: String, runnerId: String) {
        caughtPlayers.insert(runnerId)
        checkGameEnd()
    }
    
    func startGame(duration: TimeInterval, players: [Player]) {
        gameTimeRemaining = duration
        gameStatus = .playing
        currentPlayers = players
        caughtPlayers.removeAll()
        playerLocations.removeAll()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.gameTimeRemaining > 0 {
                self.gameTimeRemaining -= 1
                self.checkGameEnd()
            } else {
                self.endGame(runnersWin: true)
            }
        }
    }
} 
