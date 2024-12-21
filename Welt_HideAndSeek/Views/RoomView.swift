import SwiftUI

struct RoomView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    @State private var maxPlayers: Double = 8
    @State private var gameDuration: Double = 300
    
    var body: some View {
        VStack {
            Text("房间ID: \(roomViewModel.roomId)")
                .padding()
            
            // 显示玩家列表
            ForEach(roomViewModel.players) { player in
                HStack {
                    Text(player.name)
                    Text(player.isReady ? "已准备" : "未准备")
                        .foregroundColor(player.isReady ? .green : .red)
                    
                    // 房主可以踢出其他玩家
                    if let currentPlayer = roomViewModel.currentPlayer,
                       currentPlayer.isHost && player.id != currentPlayer.id {
                        Button("踢出") {
                            roomViewModel.kickPlayer(player: player)
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding()
            }
            
            // 根据玩家身份显示不同按钮
            if let currentPlayer = roomViewModel.currentPlayer {
                if currentPlayer.isHost {
                    // 房主设置
                    VStack(spacing: 15) {
                        // 房间设置
                        VStack(alignment: .leading) {
                            Text("房间人数: \(Int(maxPlayers))人")
                            Slider(value: $maxPlayers, in: 2...10, step: 1)
                                .onChange(of: maxPlayers) { newValue in
                                    roomViewModel.updateGameSettings(
                                        maxPlayers: Int(newValue),
                                        duration: gameDuration
                                    )
                                }
                            
                            Text("游戏时长: \(Int(gameDuration/60))分钟")
                            Slider(value: $gameDuration, in: 180...600, step: 60)
                                .onChange(of: gameDuration) { newValue in
                                    roomViewModel.updateGameSettings(
                                        maxPlayers: Int(maxPlayers),
                                        duration: newValue
                                    )
                                }
                        }
                        .padding()
                        
                        // 房主按钮
                        Button("开始游戏") {
                            roomViewModel.startGame()
                        }
                        .disabled(!roomViewModel.canStartGame())
                        
                        Button("解散房间") {
                            roomViewModel.leaveRoom()
                        }
                        .foregroundColor(.red)
                    }
                } else {
                    // 普通玩家按钮
                    VStack(spacing: 15) {
                        Button(currentPlayer.isReady ? "取消准备" : "准备") {
                            roomViewModel.setReady(isReady: !currentPlayer.isReady)
                        }
                        .foregroundColor(currentPlayer.isReady ? .red : .blue)
                        
                        Button("退出") {
                            roomViewModel.leaveRoom()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // 初始化房间设置
            maxPlayers = Double(roomViewModel.currentRoom?.maxPlayers ?? 8)
            gameDuration = roomViewModel.currentRoom?.gameDuration ?? 300
        }
    }
}

#Preview {
    RoomView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
