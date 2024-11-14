import SwiftUI
import SpriteKit

struct BlackjackGameView: View {
    
    @Environment(\.presentationMode) var presMode
    
    @State var blackjackScene: BlackjackGameScene!
    
    @State var rulesInfoViewVisible = false
    
    @State var alertVisible = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var timer: Timer = Timer()
    @State var sessionGameTime = 0
    
    var body: some View {
        ZStack {
            if let blackjackScene = blackjackScene {
                SpriteView(scene: blackjackScene)
                    .ignoresSafeArea()
            }
            
            if rulesInfoViewVisible {
                infoRulesView
            }
        }
        .onAppear {
            blackjackScene = BlackjackGameScene()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.sessionGameTime += 1
            })
        }
        .onDisappear {
            let savedSessionGameTime = UserDefaults.standard.integer(forKey: "blackjack_game_time")
            let total = savedSessionGameTime + sessionGameTime
            let formattedTime = formatTime(seconds: total)
            UserDefaults.standard.set(total, forKey: "blackjack_game_time")
            UserDefaults.standard.set(formattedTime, forKey: "blackjack_game_time_string")
            timer.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("restart_btn"))) { _ in
            blackjackScene = blackjackScene.restartScene()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("open_info"))) { _ in
            withAnimation(.easeInOut) {
                rulesInfoViewVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("go_menu"))) { _ in
            presMode.wrappedValue.dismiss()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("show_alert"))) { notification in
            if let info = notification.userInfo as? [String: Any],
                let title = info["title"] as? String,
                let message = info["message"] as? String {
                self.alertTitle = title
                self.alertMessage = message
                self.alertVisible = true
            }
        }
        .alert(isPresented: $alertVisible) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
    }
    
    private var infoRulesView: some View {
        VStack {
            Image("rules_title")
                .resizable()
                .frame(width: 250, height: 100)
            
            Text("The goal of the game is to collect a combination of cards with a total of close to 21, without exceeding this maximum. A higher number of points means a loss. Each player is dealt two cards at the beginning of the round. If the total number of points exceeds 21, the player \"overdid\" and lost. If it is less than 17, it is advisable to take another card. If the amount is close to 17, you should stop.")
                .font(.custom("Calistoga-Regular", size: 20))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Button {
                withAnimation(.linear) {
                    rulesInfoViewVisible = false
                }
            } label: {
                Image("resume_btn")
                    .resizable()
                    .frame(width: 200, height: 70)
            }
        }
    }
    
}

#Preview {
    BlackjackGameView()
}

func formatTime(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    
    var formattedTime = ""
    
    if hours > 0 {
        formattedTime += "\(hours) H "
    }
    if minutes > 0 || hours > 0 {
        formattedTime += "\(minutes) MIN"
    }
    
    return formattedTime.isEmpty ? "0 MIN" : formattedTime
}
