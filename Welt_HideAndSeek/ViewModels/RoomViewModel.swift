class RoomViewModel: ObservableObject {
    @Published var currentPlayer: Player?
    @Published var currentRoom: Room?
    @Published var players: [Player] = []
    
    func createPlayer(name: String, isHost: Bool) {
        currentPlayer = Player(name: name, isHost: isHost)
        if isHost {
            createRoom()
        }
    }
    
    func createRoom() {
        guard let host = currentPlayer else { return }
        let newRoom = Room(
            id: UUID().uuidString,
            host: host,
            players: [host],
            maxPlayers: 8,
            gameDuration: 300,
            gameStatus: .waiting
        )
        currentRoom = newRoom
        players = [host]
    }
    
    func joinRoom(roomId: String) {
        // 加入房间逻辑
    }
    
    func leaveRoom() {
        if let player = currentPlayer {
            players.removeAll(where: { $0.id == player.id })
            if player.isHost {
                currentRoom = nil
            }
        }
        currentPlayer = nil
    }
    
    func kickPlayer(player: Player) {
        players.removeAll(where: { $0.id == player.id })
    }
    
    func setReady(isReady: Bool) {
        if let index = players.firstIndex(where: { $0.id == currentPlayer?.id }) {
            players[index].isReady = isReady
        }
    }
    
    func updateGameSettings(maxPlayers: Int, duration: TimeInterval) {
        currentRoom?.maxPlayers = maxPlayers
        currentRoom?.gameDuration = duration
    }
    
    func startGame() {
        currentRoom?.gameStatus = .playing
    }
} 