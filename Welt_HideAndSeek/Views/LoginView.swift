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
        ZStack {
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
            if showCreateGameDialog {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showCreateGameDialog = false
                    }
                
                CreateGameDialogView(
                    isPresented: $showCreateGameDialog,
                    maxPlayers: $maxPlayers,
                    gameDuration: $gameDuration,
                    onCreate: createGame
                )
            }
            
            // 加入游戏对话框
            if showJoinGameDialog {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showJoinGameDialog = false
                    }
                
                JoinGameDialogView(
                    isPresented: $showJoinGameDialog,
                    roomId: $roomId,
                    onJoin: joinGame
                )
            }
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

// 创建游戏对话框视图
struct CreateGameDialogView: View {
    @Binding var isPresented: Bool
    @Binding var maxPlayers: String
    @Binding var gameDuration: String
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("创建游戏")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("游戏人数:")
                    .foregroundColor(.gray)
                TextField("2-10人", text: $maxPlayers)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Text("游戏时长:")
                    .foregroundColor(.gray)
                TextField("分钟", text: $gameDuration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            HStack(spacing: 20) {
                Button("取消") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Button("创建") {
                    onCreate()
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
    }
}

// 加入游戏对话框视图
struct JoinGameDialogView: View {
    @Binding var isPresented: Bool
    @Binding var roomId: String
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("加入游戏")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("房间ID:")
                    .foregroundColor(.gray)
                TextField("请输入房间ID", text: $roomId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack(spacing: 20) {
                Button("取消") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Button("加入") {
                    onJoin()
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
    }
}

#Preview {
    LoginView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
