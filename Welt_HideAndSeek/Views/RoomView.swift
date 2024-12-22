import SwiftUI

struct RoomView: View {
    @EnvironmentObject var roomViewModel: RoomViewModel
    
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
                    // 房间ID显示
                    VStack(spacing: 5) {
                        Text("房间ID")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(roomViewModel.roomId)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .tracking(2)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // 游戏时长显示
                    if let duration = roomViewModel.currentRoom?.gameDuration {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("游戏时长：\(Int(duration/60))分钟")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // 玩家列表
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 12) {
                        // 已加入的玩家
                        ForEach(roomViewModel.players) { player in
                            PlayerCard(
                                player: player,
                                isCurrentPlayer: player.id == roomViewModel.currentPlayer?.id,
                                canKick: roomViewModel.currentPlayer?.isHost == true && player.id != roomViewModel.currentPlayer?.id,
                                onKick: { roomViewModel.kickPlayer(player: player) }
                            )
                        }
                        
                        // 空位显示
                        if let maxPlayers = roomViewModel.currentRoom?.maxPlayers {
                            ForEach(roomViewModel.players.count..<maxPlayers, id: \.self) { _ in
                                EmptyPlayerSlot()
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
                
                // 控制按钮
                if let currentPlayer = roomViewModel.currentPlayer {
                    if currentPlayer.isHost {
                        HostControlsView(
                            onStartGame: { roomViewModel.startGame() },
                            onDismissRoom: { roomViewModel.leaveRoom() },
                            canStartGame: roomViewModel.players.count >= 2
                        )
                    } else {
                        PlayerControlsView(
                            onLeave: { roomViewModel.leaveRoom() }
                        )
                    }
                }
            }
            .padding()
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

// 空位卡片视图
struct EmptyPlayerSlot: View {
    var body: some View {
        HStack {
            Image(systemName: "person.fill.questionmark")
                .foregroundColor(.gray.opacity(0.5))
                .font(.title3)
            
            Text("等待加入...")
                .foregroundColor(.gray.opacity(0.5))
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// 房主控制视图
struct HostControlsView: View {
    let onStartGame: () -> Void
    let onDismissRoom: () -> Void
    let canStartGame: Bool
    
    var body: some View {
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

// 普通玩家控制视图
struct PlayerControlsView: View {
    let onLeave: () -> Void
    
    var body: some View {
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

#Preview {
    RoomView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
