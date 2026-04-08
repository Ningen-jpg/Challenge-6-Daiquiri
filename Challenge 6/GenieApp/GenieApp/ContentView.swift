import SwiftUI

struct ContentView: View {
    @State private var rubCount = 0
    @State private var genieAppeared = false
    @State private var showQuote = false
    @State private var currentQuote = ""
    
    let quotes = [
        "Small steps still move you forward.",
        "You are stronger than your doubts.",
        "Progress matters more than perfection.",
        "Keep going. You are closer than you think.",
        "Every day is a new beginning."
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 52/255, green: 19/255, blue: 92/255),
                    Color(red: 98/255, green: 52/255, blue: 160/255),
                    Color(red: 146/255, green: 93/255, blue: 201/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 22) {
                Spacer()
                
                LampSceneView(
                    rubCount: $rubCount,
                    genieAppeared: $genieAppeared,
                    showQuote: $showQuote,
                    currentQuote: $currentQuote,
                    quotes: quotes
                )
                .frame(height: 500)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                if showQuote {
                    Text(currentQuote)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 30)
                }
                
                Button(action: {
                    rubCount = 0
                    genieAppeared = false
                    showQuote = false
                    currentQuote = ""
                }) {
                    Text("Reset")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
