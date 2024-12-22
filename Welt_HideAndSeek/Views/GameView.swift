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
                Text("剩余时间: \(Int(gameViewModel.gameTimeRemaining))秒")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
                
                Spacer()
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
        .onChange(of: locationManager.location) { location in
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
}

#Preview {
    GameView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
