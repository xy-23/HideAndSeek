import SwiftUI
import MapKit
import CoreLocation

struct GameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var roomViewModel: RoomViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        ZStack {
            // 地图视图
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: getPlayerAnnotations()) { annotation in
                    MapAnnotation(coordinate: annotation.location) {
                        PlayerLocationMarker(
                            playerName: annotation.name,
                            color: annotation.color
                        )
                    }
            }
            .edgesIgnoringSafeArea(.all)
            
            // 游戏信息覆盖层
            VStack {
                // 计时器卡片
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("剩余时间: \(formatTime(Int(gameViewModel.gameTimeRemaining)))")
                        .bold()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 5)
                )
                .padding()
                
                Spacer()
                
                // 玩家角色信息
                if let currentPlayer = roomViewModel.currentPlayer {
                    PlayerRoleTag(player: currentPlayer)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                locationManager.requestAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onReceive(locationManager.$location) { location in
            if let newLocation = location {
                withAnimation {
                    region.center = newLocation
                }
                
                if let playerId = roomViewModel.currentPlayer?.id {
                    gameViewModel.updateLocation(
                        playerId: playerId,
                        location: newLocation
                    )
                }
            }
        }
        .alert(item: $locationManager.locationError) { error in
            Alert(
                title: Text("位置错误"),
                message: Text(error.errorDescription ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    // 获取玩家标注
    private func getPlayerAnnotations() -> [PlayerAnnotation] {
        roomViewModel.players.compactMap { player in
            guard let location = gameViewModel.playerLocations[player.id] else { return nil }
            
            let color: Color
            if player.role == .seeker {
                color = .red  // 追捕者显示红色
            } else if gameViewModel.caughtPlayers.contains(player.id) {
                color = .gray // 已被抓显示灰色
            } else {
                color = .green // 逃跑者显示绿色
            }
            
            return PlayerAnnotation(
                id: player.id,
                name: player.name,
                location: location,
                color: color
            )
        }
    }
    
    // 格式化时间
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // 玩家角色标签
    private func PlayerRoleTag(player: Player) -> some View {
        HStack {
            Image(systemName: getRoleIcon(player))
                .foregroundColor(getRoleColor(player))
            Text(getRoleText(player))
                .bold()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
        )
    }
    
    private func getRoleIcon(_ player: Player) -> String {
        if player.role == .seeker {
            return "eye.fill"
        } else if gameViewModel.caughtPlayers.contains(player.id) {
            return "xmark.circle.fill"
        } else {
            return "figure.run"
        }
    }
    
    private func getRoleColor(_ player: Player) -> Color {
        if player.role == .seeker {
            return .red
        } else if gameViewModel.caughtPlayers.contains(player.id) {
            return .gray
        } else {
            return .green
        }
    }
    
    private func getRoleText(_ player: Player) -> String {
        if player.role == .seeker {
            return "追捕者"
        } else if gameViewModel.caughtPlayers.contains(player.id) {
            return "已被抓获"
        } else {
            return "逃跑者"
        }
    }
}

// 玩家标注模型
struct PlayerAnnotation: Identifiable {
    let id: String
    let name: String
    let location: CLLocationCoordinate2D
    let color: Color
}

// 玩家位置标记视图
struct PlayerLocationMarker: View {
    let playerName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Text(playerName)
                .font(.caption)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
                .shadow(radius: 2)
            
            Image(systemName: "triangle.fill")
                .rotationEffect(.degrees(180))
                .foregroundColor(.white)
                .offset(y: -3)
            
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
                .shadow(radius: 2)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
