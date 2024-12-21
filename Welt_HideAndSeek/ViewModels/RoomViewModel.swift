import Foundation
import CoreLocation
import SwiftUI

class RoomViewModel: ObservableObject {
    @Published var currentPlayer: Player?
    @Published var currentRoom: Room?
    @Published var players: [Player] = []
    @Published var roomId: String = ""
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let networkManager = NetworkManager()
    
    // 房间验证状态
    enum RoomError: Error {
        case roomNotFound
        case roomFull
        case gameAlreadyStarted
        case invalidRoomId
        
        var message: String {
            switch self {
            case .roomNotFound:
                return "房间不存在"
            case .roomFull:
                return "房间已满"
            case .gameAlreadyStarted:
                return "游戏已开始"
            case .invalidRoomId:
                return "无效的房间ID"
            }
        }
    }
    
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
        roomId = newRoom.id
        players = [host]
    }
    
    func joinRoom(roomId: String) {
        guard let player = currentPlayer else { return }
        
        // 验证房间ID格式
        guard UUID(uuidString: roomId) != nil else {
            handleError(.invalidRoomId)
            return
        }
        
        // 检查是否是当前已存在的房间
        if let room = currentRoom, room.id == roomId {
            // 验证房间状态
            guard room.gameStatus == .waiting else {
                handleError(.gameAlreadyStarted)
                return
            }
            
            // 验证房间人数
            guard room.players.count < room.maxPlayers else {
                handleError(.roomFull)
                return
            }
            
            // 通过验证，加入房间
            self.roomId = roomId
            players.append(player)
        } else {
            // 房间不存在
            handleError(.roomNotFound)
        }
    }
    
    private func handleError(_ error: RoomError) {
        errorMessage = error.message
        showError = true
    }
    
    func leaveRoom() {
        if let player = currentPlayer {
            players.removeAll(where: { $0.id == player.id })
            if player.isHost {
                currentRoom = nil
            }
        }
        currentPlayer = nil
        roomId = ""
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
        guard canStartGame() else { return }
        
        // 更新房间状态为游戏中
        currentRoom?.gameStatus = .playing
        
        // 分配角色
        assignPlayerRoles()
        
        // 模拟通知所有玩家进入游戏状态
        // 实际实现时，这里应该是通过网络通知所有玩家
        for i in 0..<players.count {
            players[i].isReady = false  // 重置准备状态
        }
    }
    
    func endGame() {
        currentRoom?.gameStatus = .finished
    }
    
    func resetRoom() {
        currentRoom?.gameStatus = .waiting
        players.forEach { player in
            if let index = players.firstIndex(where: { $0.id == player.id }) {
                players[index].isReady = false
                players[index].role = .runner
            }
        }
    }
    
    func assignPlayerRoles() {
        // 随机选择一名玩家作为抓捕者
        guard let seekerIndex = players.indices.randomElement() else { return }
        
        // 重置所有玩家角色为被抓者
        for i in players.indices {
            players[i].role = .runner
        }
        
        // 设置选中的玩家为抓捕者
        players[seekerIndex].role = .seeker
    }
    
    func canStartGame() -> Bool {
        guard let currentRoom = currentRoom else { return false }
        
        // 检查是否所有非房主玩家都已准备
        let nonHostPlayers = players.filter { !$0.isHost }
        let allReady = nonHostPlayers.allSatisfy { $0.isReady }
        
        // 检查玩家数量是否在有效范围内
        let validPlayerCount = players.count >= 2 && players.count <= currentRoom.maxPlayers
        
        return allReady && validPlayerCount
    }
    
    // 添加监听游戏状态的方法
    func checkGameStatus() -> Bool {
        return currentRoom?.gameStatus == .playing
    }
} 
