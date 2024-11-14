import SwiftUI

struct WelcomeView: View {
    
    var name: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("fon")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Image("men")
                        .resizable()
                        .frame(width: 300, height: 300)
                }
                .edgesIgnoringSafeArea(.bottom)
                
                VStack(spacing: 20) {
                    ZStack{
                        Image("message")
                            .resizable()
                            .frame(width: 230, height: 130)
                        Text("Hi, \(name)! I'm Bob your guide, go to the next step to choose a game")
                            .font(.custom("Calistoga-Regular", size: 16))
                            .foregroundColor(Color(red: 164 / 255, green: 68 / 255, blue: 26 / 255))
                            .multilineTextAlignment(.center)
                            .frame(width: 180)
                            .offset(y: -20)
                    }
                    .frame(width: 230, height: 130)
                    .offset(x: 100)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: HaveGoodGame()
                            .navigationBarBackButtonHidden()) {
                            Image("next")
                                .resizable()
                                .frame(width: 250, height: 100)
                                .clipped()
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    WelcomeView(name: "Test")
}
