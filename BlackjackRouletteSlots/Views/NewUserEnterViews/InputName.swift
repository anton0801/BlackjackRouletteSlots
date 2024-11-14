import SwiftUI

struct InputName: View {
    @State private var name: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("fon")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    ZStack {
                        Image("stat")
                            .resizable()
                            .frame(width: 368, height: 156)
                            .clipped()
                        
                        TextField("YOUR NAME", text: $name)
                            .font(.custom("Calistoga-Regular", size: 32))
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    NavigationLink(destination: WelcomeView(name: name)
                        .navigationBarBackButtonHidden()) {
                        Image("next")
                            .resizable()
                            .frame(width: 250, height: 100)
                            .clipped()
                    }
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.7 : 1.0)
                    
                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    InputName()
}

