struct Player: Identifiable, Equatable {
    let id: String = UUID().uuidString
    var name: String
    var isHost: Bool
    var isReady: Bool = false
    var location: CLLocationCoordinate2D?
    var role: PlayerRole = .runner
    
    enum PlayerRole {
        case runner
        case seeker
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
} 