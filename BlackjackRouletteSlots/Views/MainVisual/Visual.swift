import SwiftUI

struct Visual: View {
    
    @State var userBalance = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("fon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    HStack {
                        VStack{
                            
                            Button(action: {
                            }) {
                                VStack {
                                    Image("compas")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                    
                                    Image("statButton")
                                        .resizable()
                                        .frame(width: 80, height: 40)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Image("score")
                                .resizable()
                                .frame(width: 140, height: 100)
                            
                            Text("\(userBalance)")
                                .font(.custom("Calistoga-Regular", size: 32))
                                .foregroundColor(.white)
                                .offset(x: 15)
                        }
                        
                        Spacer()
                        
                        VStack{
                            Button(action: {
                            }) {
                                Image("settingsPicture")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            }
                            Button(action: {
                            }) {
                                Image("settings")
                                    .resizable()
                                    .frame(width: 80, height: 40)
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
//                    NavigationLink(destination: BlackjackGameView()
//                        .navigationBarBackButtonHidden()) {
//                            Image("blackjackVisual")
//                                .resizable()
//                                .frame(width: 200, height: 110)
//                                .padding(.trailing, 10)
//                        }
                    
                    Spacer()
                    
                    HStack {
                        NavigationLink(destination: RouletteGameView()
                            .navigationBarBackButtonHidden()) {
                                Image("ruletteVisual")
                                    .resizable()
                                    .frame(width: 220, height: 124)
                            }
                        
                        Spacer()
                        
//                        Button(action: {
//                        }) {
//                            Image("slotgameVisual")
//                                .resizable()
//                                .frame(width: 200, height: 100)
//                        }
                        NavigationLink(destination: BlackjackGameView()
                            .navigationBarBackButtonHidden()) {
                                Image("blackjackVisual")
                                    .resizable()
                                    .frame(width: 200, height: 110)
                                    .padding(.trailing, 10)
                            }
                    }
                    .frame(width: 500)
                }
            }
            .onAppear {
                userBalance = UserDefaults.standard.integer(forKey: "userBalance")
                if userBalance == 0 {
                    userBalance = 1000
                    UserDefaults.standard.set(1000, forKey: "userBalance")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    Visual()
}



