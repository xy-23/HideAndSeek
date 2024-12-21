struct GameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var roomViewModel: RoomViewModel
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            // 地图视图占位
            Text("地图视图")
            
            VStack {
                Text("剩余时间: \(Int(gameViewModel.gameTimeRemaining))秒")
                    .padding()
            }
        }
        .onAppear {
            locationManager.requestAuthorization()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation,
               let playerId = roomViewModel.currentPlayer?.id {
                gameViewModel.updateLocation(playerId: playerId, location: location)
            }
        }
    }
} 