import Foundation

struct Room: Identifiable {
    let id: String
    var host: Player
    var players: [Player]
    var maxPlayers: Int
    var gameDuration: TimeInterval
    var gameStatus: GameStatus
    
    enum GameStatus {
        case waiting
        case playing
        case finished
    }
} 
