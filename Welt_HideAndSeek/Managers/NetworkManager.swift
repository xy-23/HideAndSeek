import Foundation
import CoreLocation

class NetworkManager: ObservableObject {
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
    
    // 简化的房间查找
    func findRoom(roomId: String) async throws -> Bool {
        // 直接返回结果，不模拟延迟和错误
        return true
    }
    
    // 简化的位置更新
    func updateLocation(roomId: String, playerId: String, location: CLLocationCoordinate2D) async throws {
        // 直接返回，不模拟延迟和错误
    }
} 
