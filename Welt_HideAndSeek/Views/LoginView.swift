import SwiftUI

struct LoginView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    @State private var playerName: String = ""
    
    // 控制对话框显示
    @State private var showCreateGameDialog = false
    @State private var showJoinGameDialog = false
    
    // 游戏设置
    @State private var maxPlayers: String = "4"
    @State private var gameDuration: String = "5"
    @State private var roomId: String = ""
    
    @State private var showEmptyNameAlert = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 标题
                Text("捉迷藏")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 50)
                
                // 输入区域
                VStack(spacing: 25) {
                    // 玩家名称输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("玩家名称")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        TextField("请输入您的名字", text: $playerName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                    }
                    
                    // 按钮组
                    VStack(spacing: 15) {
                        // 创建游戏按钮
                        Button(action: {
                            if playerName.isEmpty {
                                showEmptyNameAlert = true
                            } else {
                                showCreateGameDialog = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("创建游戏")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        
                        // 加入游戏按钮
                        Button(action: {
                            if playerName.isEmpty {
                                showEmptyNameAlert = true
                            } else {
                                showJoinGameDialog = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("加入游戏")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                Spacer()
            }
            .padding()
            
            // 对话框
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
        .alert("提示", isPresented: $showEmptyNameAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("请输入您的名字")
        }
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

// 自定义文本框样式
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5)
            )
    }
}

// 创建游戏对话框视图
struct CreateGameDialogView: View {
    @Binding var isPresented: Bool
    @Binding var maxPlayers: String
    @Binding var gameDuration: String
    let onCreate: () -> Void
    
    // 添加用于滑块的状态变量
    @State private var playersCount: Double = 4  // 默认4人
    @State private var durationMinutes: Double = 5  // 默认5分钟
    
    var body: some View {
        VStack(spacing: 20) {
            Text("创建游戏")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 20) {
                // 游戏人数滑块
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("游戏人数:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(playersCount))人")
                            .foregroundColor(.blue)
                            .bold()
                    }
                    
                    Slider(value: $playersCount, in: 2...10, step: 1)
                        .accentColor(.blue)
                        .onChange(of: playersCount) { newValue in
                            maxPlayers = String(Int(newValue))
                        }
                    
                    Text("可选范围：2-10人")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // 游戏时长滑块
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("游戏时长:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(durationMinutes))分钟")
                            .foregroundColor(.blue)
                            .bold()
                    }
                    
                    Slider(value: $durationMinutes, in: 1...30, step: 1)
                        .accentColor(.blue)
                        .onChange(of: durationMinutes) { newValue in
                            gameDuration = String(Int(newValue))
                        }
                    
                    Text("可选范围：1-30分钟")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical)
            
            HStack(spacing: 20) {
                Button("取消") {
                    isPresented = false
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                Button("创建") {
                    maxPlayers = String(Int(playersCount))
                    gameDuration = String(Int(durationMinutes))
                    onCreate()
                    isPresented = false
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal, 40)
        .onAppear {
            // 初始化滑块值
            if let players = Int(maxPlayers) {
                playersCount = Double(players)
            }
            if let duration = Int(gameDuration) {
                durationMinutes = Double(duration)
            }
        }
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
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("房间ID:")
                    .foregroundColor(.gray)
                TextField("请输入房间ID", text: $roomId)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            HStack(spacing: 20) {
                Button("取消") {
                    isPresented = false
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                Button("加入") {
                    onJoin()
                    isPresented = false
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal, 40)
    }
}

#Preview {
    LoginView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
