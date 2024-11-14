import SwiftUI

struct Stat: View {
    
    @Environment(\.presentationMode) var presMode
    
    var body: some View {
        ZStack {
            Image("fon")
               .resizable()
               .blur(radius: 5)
               .ignoresSafeArea()
            
            Rectangle()
                .fill(
                    Color.black.opacity(0.4)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                HStack{
                    Button(action: {
                        presMode.wrappedValue.dismiss()
                    }) {
                        VStack {
                            Image("square")
                                .resizable()
                                .frame(width: 80, height: 80)
                            
                            Image("menu")
                                .resizable()
                                .frame(width: 80, height: 40)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Image("stat")
                            .resizable()
                            .frame(width: 300, height: 120)
                        
                        Text("STAT")
                            .font(.custom("Calistoga-Regular", size: 40))
                            .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                    }
                    
                    Spacer()
                    
                    Image("square")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .opacity(0)
                }
                
                HStack(spacing: 32) {
                    HStack {
                        Image("roulette")
                            .resizable()
                            .frame(width: 80, height: 80)
                        VStack {
                            Text("ROULETTE")
                                .font(.custom("Calistoga-Regular", size: 20))
                                .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                            
                            Text(UserDefaults.standard.string(forKey: "roulette_game_time_string") ?? "0 H 0 MIN")
                                .font(.custom("Calistoga-Regular", size: 20))
                                .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                        }
                    }
                    
                    HStack {
                        Image("blackjack")
                            .resizable()
                            .frame(width: 80, height: 80)
                        VStack {
                            Text("BLACK JACK")
                                .font(.custom("Calistoga-Regular", size: 20))
                                .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                            
                            Text(UserDefaults.standard.string(forKey: "blackjack_game_time_string") ?? "0 H 0 MIN")
                                .font(.custom("Calistoga-Regular", size: 20))
                                .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                        }
                    }
                }
                
                HStack {
                    Image("slotgame")
                        .resizable()
                        .frame(width: 80, height: 80)
                    VStack {
                        Text("SLOT GAME")
                                   .font(.custom("Calistoga-Regular", size: 20))
                                   .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                        
                        Text(UserDefaults.standard.string(forKey: "slots_game_time_string") ?? "0 H 0 MIN")
                            .font(.custom("Calistoga-Regular", size: 20))
                            .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                    }
                }
                
            }
        }
    }
}

#Preview {
    Stat()
}


