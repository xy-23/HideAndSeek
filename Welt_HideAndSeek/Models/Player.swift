import Foundation
import CoreLocation

struct Player: Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let isHost: Bool
    var role: PlayerRole = .runner
    
    enum PlayerRole {
        case seeker
        case runner
    }
} 
