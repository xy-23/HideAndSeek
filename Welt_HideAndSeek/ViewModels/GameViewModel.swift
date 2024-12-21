class GameViewModel: ObservableObject {
    @Published var playerLocations: [String: CLLocationCoordinate2D] = [:]
    @Published var gameTimeRemaining: TimeInterval = 0
    @Published var gameStatus: GameStatus = .waiting
    
    private let catchDistance: Double = 5.0
    
    enum GameStatus {
        case waiting
        case playing
        case finished
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
        // 处理抓捕逻辑
    }
    
    func startGameTimer(duration: TimeInterval) {
        gameTimeRemaining = duration
        gameStatus = .playing
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.gameTimeRemaining > 0 {
                self.gameTimeRemaining -= 1
            } else {
                timer.invalidate()
                self.endGame()
            }
        }
    }
    
    private func endGame() {
        gameStatus = .finished
    }
    
    func getVisibleLocations(for playerId: String) -> [String: CLLocationCoordinate2D] {
        return playerLocations
    }
} 