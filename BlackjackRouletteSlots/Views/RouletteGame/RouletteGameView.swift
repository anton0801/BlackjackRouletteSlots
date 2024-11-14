import SwiftUI
import SpriteKit

struct RouletteGameView: View {
    
    @State var rouletteScene: RouletteGameScene!
    
    @Environment(\.presentationMode) var presMode
    
    @State var rulesInfoViewVisible = false
    
    @State var alertVisible = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var timer: Timer = Timer()
    @State var sessionGameTime = 0
    
    var body: some View {
        VStack {
            if let rouletteScene = rouletteScene {
                SpriteView(scene: rouletteScene)
                    .ignoresSafeArea()
            }
            
            if rulesInfoViewVisible {
                infoRulesView
            }
        }
        .onAppear {
            rouletteScene = RouletteGameScene()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.sessionGameTime += 1
            })
        }
        .onDisappear {
            let savedSessionGameTime = UserDefaults.standard.integer(forKey: "roulette_game_time")
            let total = savedSessionGameTime + sessionGameTime
            let formattedTime = formatTime(seconds: total)
            UserDefaults.standard.set(total, forKey: "roulette_game_time")
            UserDefaults.standard.set(formattedTime, forKey: "roulette_game_time_string")
            timer.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("restart_btn"))) { _ in
            rouletteScene = rouletteScene.restartScene()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("open_rules"))) { _ in
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
            
            Text("Playing casino roulette is a gambling game that requires caution and a responsible approach. The main goal is to guess in which sector the ball will stop after turning the wheel. There are two main types of roulette: European with one zero and American with two zeros.")
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
    RouletteGameView()
}
