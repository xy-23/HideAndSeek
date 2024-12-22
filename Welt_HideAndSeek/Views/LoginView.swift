import SwiftUI

struct LoginView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    @State private var playerName: String = ""
    
    // 控制对话框显示
    @State private var showCreateGameDialog = false
    @State private var showJoinGameDialog = false
    
    // 游戏设置
    @State private var maxPlayers: String = "8"
    @State private var gameDuration: String = "5"
    @State private var roomId: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 玩家名称输入
            TextField("输入你的名字", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // 创建游戏按钮
            Button(action: {
                if !playerName.isEmpty {
                    showCreateGameDialog = true
                }
            }) {
                Text("创建游戏")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(playerName.isEmpty)
            
            // 加入游戏按钮
            Button(action: {
                if !playerName.isEmpty {
                    showJoinGameDialog = true
                }
            }) {
                Text("加入游戏")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(playerName.isEmpty)
        }
        .padding()
        // 创建游戏对话框
        .alert("创建游戏", isPresented: $showCreateGameDialog) {
            TextField("游戏人数 (2-10)", text: $maxPlayers)
                .keyboardType(.numberPad)
            TextField("游戏时长 (分钟)", text: $gameDuration)
                .keyboardType(.numberPad)
            Button("取消", role: .cancel) {}
            Button("创建") {
                createGame()
            }
        } message: {
            Text("请设置游戏参数")
        }
        // 加入游戏对话框
        .alert("加入游戏", isPresented: $showJoinGameDialog) {
            TextField("房间ID", text: $roomId)
            Button("取消", role: .cancel) {}
            Button("加入") {
                joinGame()
            }
        } message: {
            Text("请输入房间ID")
        }
        // 错误提示对话框
        .alert("错误", isPresented: $roomViewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(roomViewModel.errorMessage)
        }
    }
    
    // 创建游戏方法
    private func createGame() {
        guard let maxPlayersInt = Int(maxPlayers),
              let durationMinutes = Int(gameDuration),
              maxPlayersInt >= 2 && maxPlayersInt <= 10,
              durationMinutes > 0 else {
            roomViewModel.errorMessage = "请输入有效的游戏参数"
            roomViewModel.showError = true
            return
        }
        
        roomViewModel.createPlayer(name: playerName, isHost: true)
        roomViewModel.createRoom()
        if let room = roomViewModel.currentRoom {
            roomViewModel.updateGameSettings(
                maxPlayers: maxPlayersInt,
                duration: TimeInterval(durationMinutes * 60)
            )
        }
    }
    
    // 加入游戏方法
    private func joinGame() {
        guard !roomId.isEmpty else {
            roomViewModel.errorMessage = "请输入房间ID"
            roomViewModel.showError = true
            return
        }
        
        roomViewModel.createPlayer(name: playerName, isHost: false)
        roomViewModel.joinRoom(roomId: roomId)
    }
}

#Preview {
    LoginView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
