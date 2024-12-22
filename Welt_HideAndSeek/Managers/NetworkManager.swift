import Foundation
import CoreLocation

class NetworkManager: ObservableObject {
    // 模拟房间存储
    private var mockRooms: [Room] = [
        // ID: 222222 - 可加入的房间
        Room(
            id: "222222",
            host: Player(name: "房主", isHost: true),
            players: [
                Player(name: "房主", isHost: true),
                Player(name: "玩家1", isHost: false)
            ],
            maxPlayers: 8,
            gameDuration: 300,
            gameStatus: .waiting
        ),
        // ID: 111111 - 已开始游戏的房间
        Room(
            id: "111111",
            host: Player(name: "房主A", isHost: true),
            players: [
                Player(name: "房主A", isHost: true),
                Player(name: "玩家A1", isHost: false),
                Player(name: "玩家A2", isHost: false)
            ],
            maxPlayers: 8,
            gameDuration: 300,
            gameStatus: .playing
        ),
        // ID: 666666 - 已满的房间
        Room(
            id: "666666",
            host: Player(name: "房主B", isHost: true),
            players: [
                Player(name: "房主B", isHost: true),
                Player(name: "玩家B1", isHost: false),
                Player(name: "玩家B2", isHost: false),
                Player(name: "玩家B3", isHost: false),
                Player(name: "玩家B4", isHost: false),
                Player(name: "玩家B5", isHost: false),
                Player(name: "玩家B6", isHost: false),
                Player(name: "玩家B7", isHost: false)
            ],
            maxPlayers: 8,
            gameDuration: 300,
            gameStatus: .waiting
        )
    ]
    
    enum NetworkError: Error {
        case roomNotFound
        case unauthorized
        
        var localizedDescription: String {
            switch self {
            case .roomNotFound:
                return "找不到指定房间"
            case .unauthorized:
                return "未授权的操作"
            }
        }
    }
    
    enum RoomStatus {
        case available
        case notFound
        case full
        case inProgress
    }
    
    // 查找房间
    func findRoom(roomId: String) -> Room? {
        return mockRooms.first { room in room.id == roomId }
    }
    
    // 验证房间状态
    func verifyRoom(_ roomId: String, completion: @escaping (RoomStatus) -> Void) {
        if let room = findRoom(roomId:roomId) {
            if room.gameStatus == .playing {
                completion(.inProgress)
            } else if room.players.count >= room.maxPlayers {
                completion(.full)
            } else {
                completion(.available)
            }
        } else {
            completion(.notFound)
        }
    }
    
    // 删除房间
    func removeRoom(roomId: String) {
        mockRooms.removeAll { $0.id == roomId }
    }
    
    // 模拟自动加入的玩家
    private let mockPlayers = [
        Player(name: "测试玩家1", isHost: false),
        Player(name: "测试玩家2", isHost: false)
    ]
    
    // 添加新房间并模拟玩家加入
    func addRoom(_ room: Room) {
        mockRooms.append(room)
        
        // 模拟延迟后玩家陆续加入
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.trySimulatePlayerJoining(roomId: room.id, player: self?.mockPlayers[0])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.trySimulatePlayerJoining(roomId: room.id, player: self?.mockPlayers[1])
        }
    }
    
    // 尝试模拟玩家加入房间
    private func trySimulatePlayerJoining(roomId: String, player: Player?) {
        guard let player = player,
              let index = mockRooms.firstIndex(where: { $0.id == roomId }) else { return }
        
        // 检查房间是否有空位
        let room = mockRooms[index]
        guard room.players.count < room.maxPlayers else { return }
        
        // 检查房间状态
        guard room.gameStatus == .waiting else { return }
        
        // 更新房间玩家列表
        var updatedRoom = room
        updatedRoom.players.append(player)
        mockRooms[index] = updatedRoom
        
        // 通知房间状态更新
        NotificationCenter.default.post(
            name: .roomUpdated,
            object: nil,
            userInfo: ["roomId": roomId, "room": updatedRoom]
        )
    }
    
    // 更新房间信息
    func updateRoom(_ room: Room) {
        if let index = mockRooms.firstIndex(where: { $0.id == room.id }) {
            mockRooms[index] = room
        }
    }
}

// 添加通知名称
extension Notification.Name {
    static let roomUpdated = Notification.Name("roomUpdated")
}
