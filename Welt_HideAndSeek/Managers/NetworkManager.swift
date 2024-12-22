import Foundation
import MultipeerConnectivity
import CoreLocation

class NetworkManager: NSObject, ObservableObject {
    // 发布状态属性
    @Published var connectedPeers: [MCPeerID] = []
    @Published var mockRooms: [Room] = []
    
    // MultipeerConnectivity 相关属性
    private let serviceType = "hide-n-seek"
    private var session: MCSession!
    private var hostAdvertiser: MCNearbyServiceAdvertiser?
    private var guestBrowser: MCNearbyServiceBrowser?
    private let myPeerID: MCPeerID
    
    // 数据编码器和解码器
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // 游戏数据类型枚举
    enum DataType: String, Codable {
        case playerInfo      // 玩家信息（名字、角色等）
        case location       // 位置更新
        case roomUpdate    // 房间状态更新
        case gameStart     // 游戏开始
        case gameEnd       // 游戏结束
        case playerCaught  // 玩家被抓
    }
    
    // 网络消息结构
    struct NetworkMessage: Codable {
        let type: DataType
        let data: Data
    }
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    // MARK: - 主机功能
    
    func startHosting(room: Room) {
        // 停止之前的广播
        stopHosting()
        
        // 创建广播服务
        hostAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: ["roomId": room.id],
            serviceType: serviceType
        )
        hostAdvertiser?.delegate = self
        hostAdvertiser?.startAdvertisingPeer()
        
        // 保存房间信息
        mockRooms = [room]
    }
    
    func stopHosting() {
        hostAdvertiser?.stopAdvertisingPeer()
        hostAdvertiser = nil
    }
    
    // MARK: - 客户端功能
    
    func startBrowsing() {
        // 停止之前的搜索
        stopBrowsing()
        
        // 创建搜索服务
        guestBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        guestBrowser?.delegate = self
        guestBrowser?.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        guestBrowser?.stopBrowsingForPeers()
        guestBrowser = nil
    }
    
    // MARK: - 数据发送
    
    func sendPlayerInfo(_ player: Player) {
        do {
            let playerData = try encoder.encode(player)
            let message = NetworkMessage(type: .playerInfo, data: playerData)
            let messageData = try encoder.encode(message)
            try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending player info: \(error)")
        }
    }
    
    func sendLocation(_ location: CLLocationCoordinate2D, for playerId: String) {
        do {
            let locationInfo = ["playerId": playerId, "lat": location.latitude, "lon": location.longitude]
            let locationData = try encoder.encode(locationInfo)
            let message = NetworkMessage(type: .location, data: locationData)
            let messageData = try encoder.encode(message)
            try session.send(messageData, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("Error sending location: \(error)")
        }
    }
    
    func sendRoomUpdate(_ room: Room) {
        do {
            let roomData = try encoder.encode(room)
            let message = NetworkMessage(type: .roomUpdate, data: roomData)
            let messageData = try encoder.encode(message)
            try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending room update: \(error)")
        }
    }
    
    // MARK: - 游戏状态同步
    
    func startGame(room: Room) {
        do {
            let roomData = try encoder.encode(room)
            let message = NetworkMessage(type: .gameStart, data: roomData)
            let messageData = try encoder.encode(message)
            try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error starting game: \(error)")
        }
    }
    
    func reportPlayerCaught(playerId: String) {
        do {
            let caughtData = try encoder.encode(["playerId": playerId])
            let message = NetworkMessage(type: .playerCaught, data: caughtData)
            let messageData = try encoder.encode(message)
            try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error reporting caught player: \(error)")
        }
    }
}

// MARK: - MCSessionDelegate
extension NetworkManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try decoder.decode(NetworkMessage.self, from: data)
            DispatchQueue.main.async {
                self.handleReceivedMessage(message, from: peerID)
            }
        } catch {
            print("Error decoding received data: \(error)")
        }
    }
    
    private func handleReceivedMessage(_ message: NetworkMessage, from peer: MCPeerID) {
        do {
            switch message.type {
            case .playerInfo:
                let player = try decoder.decode(Player.self, from: message.data)
                NotificationCenter.default.post(
                    name: .playerInfoUpdated,
                    object: nil,
                    userInfo: ["player": player]
                )
                
            case .location:
                let locationInfo = try decoder.decode([String: Any].self, from: message.data) as! [String: Any]
                if let playerId = locationInfo["playerId"] as? String,
                   let lat = locationInfo["lat"] as? Double,
                   let lon = locationInfo["lon"] as? Double {
                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    NotificationCenter.default.post(
                        name: .playerLocationUpdated,
                        object: nil,
                        userInfo: ["playerId": playerId, "location": location]
                    )
                }
                
            case .roomUpdate:
                let room = try decoder.decode(Room.self, from: message.data)
                NotificationCenter.default.post(
                    name: .roomUpdated,
                    object: nil,
                    userInfo: ["room": room]
                )
                
            case .gameStart:
                let room = try decoder.decode(Room.self, from: message.data)
                NotificationCenter.default.post(
                    name: .gameStarted,
                    object: nil,
                    userInfo: ["room": room]
                )
                
            case .playerCaught:
                let caughtInfo = try decoder.decode([String: String].self, from: message.data)
                if let playerId = caughtInfo["playerId"] {
                    NotificationCenter.default.post(
                        name: .playerCaught,
                        object: nil,
                        userInfo: ["playerId": playerId]
                    )
                }
            }
        } catch {
            print("Error handling message: \(error)")
        }
    }
    
    // 必须实现的其他 MCSessionDelegate 方法
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 自动接受连接请求
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NetworkManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // 自动发起连接请求
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // 处理失去连接的peer
        DispatchQueue.main.async {
            self.connectedPeers.removeAll { $0 == peerID }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let playerInfoUpdated = Notification.Name("playerInfoUpdated")
    static let playerLocationUpdated = Notification.Name("playerLocationUpdated")
    static let roomUpdated = Notification.Name("roomUpdated")
    static let gameStarted = Notification.Name("gameStarted")
    static let playerCaught = Notification.Name("playerCaught")
}
