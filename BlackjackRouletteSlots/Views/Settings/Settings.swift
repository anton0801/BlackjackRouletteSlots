import SwiftUI

struct Settings: View {
    @State private var isSoundOn = true
    @State private var isMusicOn = true
    
    var body: some View {
        ZStack {
            Image("fon")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    VStack{
                        Button(action: {
                        }) {
                            Image("square")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        Button(action: {
                        }) {
                            Image("menu")
                                .resizable()
                                .frame(width: 100, height: 50)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Image("stat")
                            .resizable()
                            .frame(width: 368, height: 156)
                        
                        Text("SETTINGS")
                            .font(.custom("Calistoga-Regular", size: 40))
                            .foregroundColor(Color(red: 248 / 255, green: 230 / 255, blue: 109 / 255))
                    }
                    
                    Spacer()
                    
                    Image("square")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .opacity(0)
                }
                
                HStack(spacing: 50) {
                    VStack{
                        Button(action: {
                            isSoundOn.toggle()
                        }) {
                            VStack {
                                Image(isSoundOn ? "soundOn" : "soundOff")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                Image("sound")
                                    .resizable()
                                    .frame(width: 100, height: 50)
                            }
                        }
                    }
                    
                    VStack{
                        Button(action: {
                            isMusicOn.toggle()
                        }) {
                            VStack {
                                Image(isMusicOn ? "musicOn" : "musicOff")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                Image("music")
                                    .resizable()
                                    .frame(width: 100, height: 50)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Settings()
}

