import SwiftUI

struct LoginView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    @State private var playerName: String = ""
    @State private var isHost: Bool = false
    @State private var roomId: String = ""
    @State private var showRoomIdInput: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("输入你的名字", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("选择身份", selection: $isHost) {
                Text("普通玩家").tag(false)
                Text("房主").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if !isHost && showRoomIdInput {
                TextField("输入房间ID", text: $roomId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            Button(action: {
                if !playerName.isEmpty {
                    roomViewModel.createPlayer(name: playerName, isHost: isHost)
                    if !isHost {
                        showRoomIdInput = true
                    }
                }
            }) {
                Text(isHost ? "创建房间" : "加入房间")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
} 