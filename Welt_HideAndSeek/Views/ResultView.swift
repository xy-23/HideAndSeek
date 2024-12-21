import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var roomViewModel: RoomViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(gameViewModel.gameResult == .seekerWin ? "抓捕者胜利！" : "逃跑者胜利！")
                .font(.title)
                .padding()
            
            // 游戏统计信息
            VStack(alignment: .leading, spacing: 10) {
                Text("游戏时长: \(Int(gameViewModel.gameTimeRemaining))秒")
                Text("被抓获玩家: \(gameViewModel.caughtPlayers.count)人")
                Text("存活玩家: \(roomViewModel.players.count - gameViewModel.caughtPlayers.count)人")
            }
            .padding()
            
            Button("返回房间") {
                // 重置游戏状态
                gameViewModel.resetGame()
                roomViewModel.currentRoom?.gameStatus = .waiting
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    ResultView()
        .environmentObject(RoomViewModel())
        .environmentObject(GameViewModel())
} 
