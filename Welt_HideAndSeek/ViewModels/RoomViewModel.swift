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
    
    init() {
        // 添加房间更新通知监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRoomUpdate),
            name: .roomUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleRoomUpdate(_ notification: Notification) {
        guard let roomId = notification.userInfo?["roomId"] as? String,
              let updatedRoom = notification.userInfo?["room"] as? Room,
              roomId == self.roomId else { return }
        
        DispatchQueue.main.async {
            self.currentRoom = updatedRoom
            self.players = updatedRoom.players
        }
    }
    
    func createPlayer(name: String, isHost: Bool) {
        currentPlayer = Player(name: name, isHost: isHost)
        if isHost {
            createRoom()
        }
    }
    
    private func generateRoomId() -> String {
        String(format: "%06d", Int.random(in: 100000...999999))
    }
    
    func createRoom() {
        guard let host = currentPlayer else { return }
        let newRoom = Room(
            id: generateRoomId(),
            host: host,
            players: [host],
            maxPlayers: 8,
            gameDuration: 300,
            gameStatus: .waiting
        )
        currentRoom = newRoom
        roomId = newRoom.id
        players = [host]
        networkManager.addRoom(newRoom)
        
        // 提示房主房间创建成功
        errorMessage = "房间创建成功！房间ID：\(newRoom.id)"
        showError = true
    }
    
    func joinRoom(roomId: String) {
        guard let player = currentPlayer else { return }
        
        // 验证房间ID格式
        guard roomId.count == 6, Int(roomId) != nil else {
            errorMessage = "房间ID必须是6位数字"
            showError = true
            return
        }
        
        networkManager.verifyRoom(roomId) { [weak self] status in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch status {
                case .inProgress:
                    self.errorMessage = "该房间游戏已开始"
                    self.showError = true
                case .full:
                    self.errorMessage = "该房间已满"
                    self.showError = true
                case .notFound:
                    self.errorMessage = "房间不存在"
                    self.showError = true
                case .available:
                    if let room = self.networkManager.findRoom(roomId) {
                        self.currentRoom = room
                        self.roomId = roomId
                        self.players = room.players
                        self.players.append(player)
                        
                        // 更新房间信息
                        var updatedRoom = room
                        updatedRoom.players = self.players
                        self.networkManager.updateRoom(updatedRoom)
                    }
                }
            }
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
                if let roomId = currentRoom?.id {
                    networkManager.removeRoom(roomId)
                }
                currentRoom = nil
            } else if let room = currentRoom {
                // 更新房间信息
                var updatedRoom = room
                updatedRoom.players = players
                networkManager.updateRoom(updatedRoom)
            }
        }
        currentPlayer = nil
        roomId = ""
    }
    
    func kickPlayer(player: Player) {
        guard currentPlayer?.isHost == true else { return }
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
} 
