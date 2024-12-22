import SwiftUI

struct RoomView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    @State private var maxPlayers: Double = 8
    @State private var gameDuration: Double = 300
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // 房间信息卡片
                VStack(spacing: 10) {
                    Text("房间ID")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(roomViewModel.roomId)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // 玩家列表
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(roomViewModel.players) { player in
                            PlayerCard(
                                player: player,
                                isCurrentPlayer: player.id == roomViewModel.currentPlayer?.id,
                                canKick: roomViewModel.currentPlayer?.isHost == true && player.id != roomViewModel.currentPlayer?.id,
                                onKick: { roomViewModel.kickPlayer(player: player) }
                            )
                        }
                    }
                }
                
                // 房主设置或玩家准备按钮
                if let currentPlayer = roomViewModel.currentPlayer {
                    if currentPlayer.isHost {
                        HostSettingsView(
                            maxPlayers: $maxPlayers,
                            gameDuration: $gameDuration,
                            onSettingsChanged: { roomViewModel.updateGameSettings(maxPlayers: Int(maxPlayers), duration: gameDuration) },
                            onStartGame: { roomViewModel.startGame() },
                            onDismissRoom: { roomViewModel.leaveRoom() },
                            canStartGame: roomViewModel.canStartGame()
                        )
                    } else {
                        PlayerControlsView(
                            isReady: currentPlayer.isReady,
                            onReadyToggle: { roomViewModel.setReady(isReady: !currentPlayer.isReady) },
                            onLeave: { roomViewModel.leaveRoom() }
                        )
                    }
                }
            }
            .padding()
        }
        .onAppear {
            maxPlayers = Double(roomViewModel.currentRoom?.maxPlayers ?? 8)
            gameDuration = roomViewModel.currentRoom?.gameDuration ?? 300
        }
    }
}

// 玩家卡片视图
struct PlayerCard: View {
    let player: Player
    let isCurrentPlayer: Bool
    let canKick: Bool
    let onKick: () -> Void
    
    var body: some View {
        HStack {
            // 玩家角色图标
            Image(systemName: player.isHost ? "crown.fill" : "person.fill")
                .foregroundColor(player.isHost ? .yellow : .blue)
                .font(.title3)
            
            // 玩家名称
            Text(player.name + (isCurrentPlayer ? " (我)" : ""))
                .bold(isCurrentPlayer)
            
            Spacer()
            
            // 准备状态
            if !player.isHost {
                Text(player.isReady ? "已准备" : "未准备")
                    .foregroundColor(player.isReady ? .green : .red)
                    .font(.subheadline)
            }
            
            // 踢出按钮
            if canKick {
                Button(action: onKick) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// 房主设置视图
struct HostSettingsView: View {
    @Binding var maxPlayers: Double
    @Binding var gameDuration: Double
    let onSettingsChanged: () -> Void
    let onStartGame: () -> Void
    let onDismissRoom: () -> Void
    let canStartGame: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 设置卡片
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("房间人数: \(Int(maxPlayers))人")
                        .font(.headline)
                    Slider(value: $maxPlayers, in: 2...10, step: 1)
                        .accentColor(.blue)
                        .onChange(of: maxPlayers) { _ in onSettingsChanged() }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("游戏时长: \(Int(gameDuration/60))分钟")
                        .font(.headline)
                    Slider(value: $gameDuration, in: 180...600, step: 60)
                        .accentColor(.blue)
                        .onChange(of: gameDuration) { _ in onSettingsChanged() }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3)
            
            // 控制按钮
            HStack(spacing: 15) {
                Button(action: onStartGame) {
                    Text("开始游戏")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canStartGame ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!canStartGame)
                
                Button(action: onDismissRoom) {
                    Text("解散房间")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }
}

// 普通玩家控制视图
struct PlayerControlsView: View {
    let isReady: Bool
    let onReadyToggle: () -> Void
    let onLeave: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onReadyToggle) {
                Text(isReady ? "取消准备" : "准备")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isReady ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button(action: onLeave) {
                Text("退出")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    RoomView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
