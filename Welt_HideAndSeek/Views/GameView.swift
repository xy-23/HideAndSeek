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
            Map(coordinateRegion: $region, 
                showsUserLocation: true,
                userTrackingMode: .constant(.follow))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // 游戏信息显示在地图上方
                Text("剩余时间: \(Int(gameViewModel.gameTimeRemaining))秒")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
                
                Spacer()
            }
        }
        .onAppear {
            locationManager.requestAuthorization()
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                // 更新地图中心点为当前位置
                region.center = location
                
                // 更新游戏中的位置信息
                if let playerId = roomViewModel.currentPlayer?.id {
                    gameViewModel.updateLocation(playerId: playerId, location: location)
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
