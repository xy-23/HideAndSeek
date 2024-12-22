import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var roomViewModel: RoomViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 添加格式化时间方法
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 结果标题
                VStack(spacing: 15) {
                    Image(systemName: gameViewModel.gameResult == .seekerWin ? "flag.fill" : "figure.run")
                        .font(.system(size: 60))
                        .foregroundColor(gameViewModel.gameResult == .seekerWin ? .red : .green)
                    
                    Text(gameViewModel.gameResult == .seekerWin ? "追捕者胜利！" : "逃跑者胜利！")
                        .font(.title)
                        .bold()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 10)
                )
                
                // 修改游戏统计信息
                VStack(alignment: .leading, spacing: 15) {
                    StatisticRow(
                        icon: "clock.fill",
                        title: "游戏时长",
                        value: formatTime(Int(gameViewModel.gameDuration)),
                        color: .blue
                    )
                    
                    StatisticRow(
                        icon: "person.fill.xmark",
                        title: "被抓获玩家",
                        value: "\(gameViewModel.caughtPlayers.count)人",
                        color: .red
                    )
                    
                    StatisticRow(
                        icon: "person.fill.checkmark",
                        title: "存活玩家",
                        value: "\(getSurvivingRunnersCount())人",
                        color: .green
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 10)
                )
                
                // 返回按钮
                Button(action: {
                    gameViewModel.resetGame()  // 重置游戏状态
                    roomViewModel.currentRoom?.gameStatus = .waiting  // 重置房间状态
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("返回房间")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    // 新增：计算存活的逃跑者数量的方法
    private func getSurvivingRunnersCount() -> Int {
        let totalRunners = gameViewModel.currentPlayers.filter { $0.role == .runner }.count
        return totalRunners - gameViewModel.caughtPlayers.count
    }
}

// 统计信息行视图
struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .bold()
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ResultView()
        .environmentObject(GameViewModel())
        .environmentObject(RoomViewModel(gameViewModel: GameViewModel()))
} 
