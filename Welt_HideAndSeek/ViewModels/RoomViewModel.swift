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
            // 只更新新加入的玩家
            let newPlayers = updatedRoom.players.filter { newPlayer in
                !self.players.contains { $0.id == newPlayer.id }
            }
            self.players.append(contentsOf: newPlayers)
            
            // 更新房间其他信息，但保留当前玩家列表
            var room = updatedRoom
            room.players = self.players
            self.currentRoom = room
        }
    }
    
    func createPlayer(name: String, isHost: Bool) {
        // 如果已经有玩家对象，更新其身份
        if currentPlayer != nil {
            currentPlayer = Player(name: currentPlayer!.name, isHost: isHost)
        } else {
            // 创建新玩家
            currentPlayer = Player(name: name, isHost: isHost)
        }
        
        // 如果是房主，创建新房间
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
            gameStatus: .waiting
        )
        currentRoom = newRoom
        roomId = newRoom.id
        players = [host]
        networkManager.addRoom(newRoom)
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
                    if let room = self.networkManager.findRoom(roomId:roomId) {
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
    
    func leaveRoom() {
        if let player = currentPlayer {
            players.removeAll(where: { $0.id == player.id })
            
            if player.isHost {
                if let room = currentRoom {
                    // 房主解散房间时，通知所有玩家退出
                    for player in room.players {
                        if !player.isHost {
                            players.removeAll(where: { $0.id == player.id })
                        }
                    }
                    networkManager.removeRoom(roomId:room.id)
                }
            } else if let room = currentRoom {
                // 普通玩家退出，更新房间信息
                var updatedRoom = room
                updatedRoom.players = players
                networkManager.updateRoom(updatedRoom)
            }
            
            // 清理房间相关信息，保留玩家基本信息
            currentRoom = nil
            roomId = ""
            // 重置玩家角色为默认值
            currentPlayer?.role = .runner
        }
    }
    
    func kickPlayer(player: Player) {
        guard currentPlayer?.isHost == true else { return }
        
        // 从房间中移除被踢玩家
        players.removeAll(where: { $0.id == player.id })
        
        // 更新房间信息
        if let room = currentRoom {
            var updatedRoom = room
            updatedRoom.players = players
            networkManager.updateRoom(updatedRoom)
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
        
        // 更新网络管理器中的房间状态
        if let room = currentRoom {
            var updatedRoom = room
            updatedRoom.gameStatus = .playing
            updatedRoom.players = players
            networkManager.updateRoom(updatedRoom)
            
            // 更新本地状态
            currentRoom = updatedRoom
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
        
        // 只检查玩家数量是否在有效范围内
        let validPlayerCount = players.count >= 2 && players.count <= currentRoom.maxPlayers
        
        return validPlayerCount
    }
} 
