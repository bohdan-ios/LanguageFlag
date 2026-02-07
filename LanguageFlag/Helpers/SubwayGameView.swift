import SwiftUI

/// SwiftUI view for the mob runner mini-game
struct SubwayGameView: View {

    
    // MARK: - Properties
    
    @StateObject private var gameState = SubwayGameState()
    @State private var lastUpdate = Date()
    @State private var keyMonitor: Any?
    
    private let gameWidth: CGFloat = 600
    private let gameHeight: CGFloat = 300
    
    // MARK: - Views
    
    var body: some View {
        VStack(spacing: 16) {
            // HUD - Crowd size and progress
            HStack {
                HStack(spacing: 8) {
                    Text("👥")
                        .font(.title2)
                    Text("\(gameState.crowdSize)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Progress bar
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.primary.opacity(0.1))
                                .frame(height: 8)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geo.size.width * gameState.progress, height: 8)
                        }
                        .cornerRadius(4)
                    }
                    .frame(width: 150, height: 8)
                }
            }
            .padding(.horizontal)
            
            // Game canvas
            ZStack {
                // Background
                Rectangle()
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        Rectangle()
                            .stroke(Color.primary.opacity(0.2), lineWidth: 2)
                    )
                
                // Game elements
                if gameState.isPlaying || gameState.gameOver {
                    gameContent
                } else {
                    startScreen
                }
            }
            .frame(width: gameWidth, height: gameHeight)
            
            // Controls and instructions
            HStack {
                if gameState.gameOver {
                    if gameState.crowdSize > 0 {
                        Text("🎉 You Won! Final Crowd: \(gameState.crowdSize)")
                            .font(.headline)
                            .foregroundColor(.green)
                    } else {
                        Text("Game Over - Crowd Lost!")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Button("Restart") {
                        gameState.start()
                    }
                    .buttonStyle(.borderedProminent)
                } else if !gameState.isPlaying {
                    Button("Start Game") {
                        gameState.start()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
            
            Text("Use Arrow Keys (↑/↓) or W/S to switch lanes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onAppear {
            lastUpdate = Date()
            setupKeyboardMonitoring()
        }
        .onDisappear {
            gameState.stop()
            removeKeyboardMonitoring()
        }
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardMonitoring() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Arrow keys: 126 = up, 125 = down
            // W/S keys: 13 = w, 1 = s
            if event.keyCode == 126 || event.keyCode == 13 { // Up or W
                self.gameState.moveUp()
                return nil
            } else if event.keyCode == 125 || event.keyCode == 1 { // Down or S
                self.gameState.moveDown()
                return nil
            }
            return event
        }
    }
    
    private func removeKeyboardMonitoring() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
    
    // MARK: - Subviews
    
    private var gameContent: some View {
        TimelineView(.animation) { timeline in
            ZStack(alignment: .bottomLeading) {
                // Lane dividers
                VStack(spacing: 0) {
                    Spacer().frame(height: 50)
                    Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                    Spacer().frame(height: 74)
                    Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                    Spacer().frame(height: 74)
                    Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                    Spacer().frame(height: 50)
                }
                
                // Gates
                ForEach(gameState.gates) { gate in
                    gateView(for: gate)
                }
                
                // Player
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("👤")
                            .font(.caption)
                    )
                    .position(
                        x: 80,
                        y: gameHeight - gameState.playerY
                    )
                    .animation(.easeInOut(duration: 0.2), value: gameState.playerLane)
                
                // Game over overlay
                if gameState.gameOver {
                    VStack(spacing: 12) {
                        if gameState.crowdSize > 0 {
                            Text("🎉 Victory!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Final Crowd: \(gameState.crowdSize)")
                                .font(.title2)
                        } else {
                            Text("Game Over!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Crowd Lost")
                                .font(.title2)
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(NSColor.controlBackgroundColor).opacity(0.95))
                            .shadow(radius: 20)
                    )
                }
            }
            .onChange(of: timeline.date) { newDate in
                let deltaTime = newDate.timeIntervalSince(lastUpdate)
                gameState.update(deltaTime: deltaTime)
                lastUpdate = newDate
            }
        }
    }
    
    private func gateView(for gate: Gate) -> some View {
        let gateY: CGFloat
        switch gate.lane {
        case .top: gateY = gameHeight - 200
        case .middle: gateY = gameHeight - 125
        case .bottom: gateY = gameHeight - 50
        }
        
        let gateColor = gate.operation.isPositive ? Color.blue : Color.red
        
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(gateColor, lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(gateColor.opacity(0.2))
                )
                .frame(width: 60, height: 60)
            
            Text(gate.operation.displayText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(gateColor)
        }
        .opacity(gate.passed ? 0.3 : 1.0)
        .position(x: gate.x, y: gateY)
    }
    
    private var startScreen: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundColor(.primary.opacity(0.6))
            
            Text("Mob Runner")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                Text("Build your crowd through gates!")
                    .font(.body)
                
                HStack(spacing: 12) {
                    Text("🟦 +10, ×2")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("🟥 -5, ÷2")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

struct SubwayGameView_Previews: PreviewProvider {

    static var previews: some View {
        SubwayGameView()
            .frame(width: 650, height: 450)
            .padding()
    }
}
