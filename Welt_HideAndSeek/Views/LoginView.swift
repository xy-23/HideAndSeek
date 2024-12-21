import SwiftUI

struct LoginView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    @State private var playerName: String = ""
    @State private var roomId: String = ""
    @State private var showRoomIdInput: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("输入你的名字", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if showRoomIdInput {
                TextField("输入房间ID", text: $roomId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    if !playerName.isEmpty {
                        roomViewModel.createPlayer(name: playerName, isHost: true)
                    }
                }) {
                    Text("创建房间")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                joinRoomButton
            }
            .padding()
        }
        .padding()
        .alert("加入房间失败", isPresented: $roomViewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(roomViewModel.errorMessage)
        }
    }
    
    var joinRoomButton: some View {
        Button(action: {
            if !playerName.isEmpty {
                roomViewModel.createPlayer(name: playerName, isHost: false)
                showRoomIdInput = true
                if !roomId.isEmpty {
                    roomViewModel.joinRoom(roomId: roomId)
                }
            }
        }) {
            Text("加入房间")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
