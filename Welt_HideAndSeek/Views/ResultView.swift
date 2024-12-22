import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var roomViewModel: RoomViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // 游戏结果标题
            Text(gameViewModel.gameResult == .seekerWin ? "抓捕者胜利！" : "逃跑者胜利！")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(gameViewModel.gameResult == .seekerWin ? .red : .blue)
            
            // 玩家列表
            VStack(spacing: 15) {
                ForEach(roomViewModel.players) { player in
                    PlayerResultCard(
                        playerName: player.name,
                        role: player.role,
                        wasCaught: gameViewModel.caughtPlayers.contains(player.id)
                    )
                }
            }
            .padding()
            
            // 返回按钮
            Button(action: {
                // 重置游戏状态
                gameViewModel.resetGame()
                roomViewModel.currentRoom?.gameStatus = .waiting
                // 不再需要重置准备状态
                gameViewModel.showResult = false
            }) {
                Text("返回房间")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct PlayerResultCard: View {
    let playerName: String
    let role: Player.PlayerRole
    let wasCaught: Bool
    
    var body: some View {
        HStack {
            // 玩家角色图标
            Image(systemName: role == .seeker ? "eye.fill" : "figure.run")
                .foregroundColor(role == .seeker ? .red : .blue)
            
            // 玩家名称
            Text(playerName)
                .bold()
            
            Spacer()
            
            // 状态显示
            if role == .runner {
                Text(wasCaught ? "被抓获" : "逃脱成功")
                    .foregroundColor(wasCaught ? .red : .green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ResultView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
