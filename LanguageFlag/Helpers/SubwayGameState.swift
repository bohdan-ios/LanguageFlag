import SwiftUI

/// Manages the state and logic for the mob runner mini-game
class SubwayGameState: ObservableObject {

    
    // MARK: - Published Properties
    
    @Published var isPlaying: Bool = false
    @Published var crowdSize: Int = 1
    @Published var playerLane: Lane = .middle
    @Published var gates: [Gate] = []
    @Published var distance: CGFloat = 0
    @Published var gameOver: Bool = false
    
    // MARK: - Constants
    
    private let baseGateSpeed: CGFloat = 150
    private let gameWidth: CGFloat = 500
    private let finishDistance: CGFloat = 10000             // Doubled distance - harder to complete
    private let speedIncreaseInterval: TimeInterval = 2  // Faster speed increases
    private let speedIncreaseMultiplier: CGFloat = 1.25    // 15% faster each time

    private var gateTimer: Timer?
    private var speedMultiplier: CGFloat = 1.0
    private var timeSinceLastSpeedIncrease: TimeInterval = 0
    
    // MARK: - Computed Properties
    
    var currentSpeed: CGFloat {
        baseGateSpeed * speedMultiplier
    }
    
    var playerY: CGFloat {
        switch playerLane {
        case .top: return 200
        case .middle: return 125
        case .bottom: return 50
        }
    }
    
    var progress: CGFloat {
        min(distance / finishDistance, 1.0)
    }
    
    // MARK: - Public Methods
    
    /// Starts or restarts the game
    func start() {
        reset()
        isPlaying = true
        gameOver = false
        startGateGeneration()
    }
    
    /// Moves player up one lane
    func moveUp() {
        guard isPlaying && !gameOver else { return }
        switch playerLane {
        case .bottom: playerLane = .middle
        case .middle: playerLane = .top
        case .top: break
        }
    }
    
    /// Moves player down one lane
    func moveDown() {
        guard isPlaying && !gameOver else { return }
        switch playerLane {
        case .top: playerLane = .middle
        case .middle: playerLane = .bottom
        case .bottom: break
        }
    }
    
    /// Updates game state - should be called every frame
    func update(deltaTime: TimeInterval) {
        guard isPlaying && !gameOver else { return }
        
        // Increase speed over time
        timeSinceLastSpeedIncrease += deltaTime
        if timeSinceLastSpeedIncrease >= speedIncreaseInterval {
            speedMultiplier *= speedIncreaseMultiplier
            timeSinceLastSpeedIncrease = 0
            print("🚀 Speed increased! Multiplier: \(String(format: "%.2f", speedMultiplier))")
        }
        
        // Update distance traveled (using current speed)
        distance += currentSpeed * deltaTime
        
        // Check if reached finish
        if distance >= finishDistance {
            endGame()
            return
        }
        
        // Update gates (using current speed)
        var updatedGates: [Gate] = []
        
        for gate in gates {
            var updated = gate
            updated.x -= currentSpeed * deltaTime
            
            // Keep gates that are still visible
            if updated.x > -100 {
                updatedGates.append(updated)
            }
        }
        
        gates = updatedGates
        
        // Check gate collisions
        checkGateCollisions()
    }
    
    /// Stops the game
    func stop() {
        isPlaying = false
        gateTimer?.invalidate()
        gateTimer = nil
    }
    
    // MARK: - Private Methods
    
    private func reset() {
        crowdSize = 1
        playerLane = .middle
        gates = []
        distance = 0
        speedMultiplier = 1.0
        timeSinceLastSpeedIncrease = 0
        gateTimer?.invalidate()
        gateTimer = nil
    }
    
    private func startGateGeneration() {
        gateTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            self?.spawnGates()
        }
    }
    
    private func spawnGates() {
        guard isPlaying && !gameOver else { return }
        
        // Spawn 2-3 gates at different lanes
        let lanes = Lane.allCases.shuffled()
        let gateCount = Int.random(in: 2...3)
        
        for index in 0..<gateCount {
            let lane = lanes[index]
            let operation = GateOperation.random()
            
            let gate = Gate(
                x: gameWidth + CGFloat(index * 80),
                lane: lane,
                operation: operation
            )
            gates.append(gate)
        }
    }
    
    private func checkGateCollisions() {
        let playerX: CGFloat = 80
        
        for index in gates.indices {
            if gates[index].passed { continue }
            
            // Check if gate is in player's lane and collision range
            if gates[index].lane == playerLane 
                && abs(gates[index].x - playerX) < 40 {
                
                // Apply operation
                let oldSize = crowdSize
                crowdSize = gates[index].operation.apply(to: crowdSize)
                gates[index].passed = true
                
                print("🎯 Passed gate \(gates[index].operation.displayText): \(oldSize) → \(crowdSize)")
                
                // Game over if crowd reaches 0
                if crowdSize <= 0 {
                    endGame()
                }
            }
        }
    }
    
    private func endGame() {
        gameOver = true
        isPlaying = false
        gateTimer?.invalidate()
        gateTimer = nil
    }
}

// MARK: - Lane Model

enum Lane: CaseIterable {

    case top, middle, bottom
}

// MARK: - Gate Model

struct Gate: Identifiable {

    let id = UUID()
    var x: CGFloat
    let lane: Lane
    let operation: GateOperation
    var passed: Bool = false
}

// MARK: - Gate Operation

enum GateOperation {

    case multiply(Int)
    case add(Int)
    case subtract(Int)
    case divide(Int)
    
    var displayText: String {
        switch self {
        case .multiply(let value): return "×\(value)"
        case .add(let value): return "+\(value)"
        case .subtract(let value): return "-\(value)"
        case .divide(let value): return "÷\(value)"
        }
    }
    
    var isPositive: Bool {
        switch self {
        case .multiply, .add: return true
        case .subtract, .divide: return false
        }
    }
    
    func apply(to value: Int) -> Int {
        switch self {
        case .multiply(let multiplier): return value * multiplier
        case .add(let amount): return value + amount
        case .subtract(let amount): return max(0, value - amount)
        case .divide(let divisor): return divisor > 0 ? value / divisor : value
        }
    }
    
    static func random() -> GateOperation {
        let operations: [GateOperation] = [
            .multiply(2), .multiply(3),
            .add(5), .add(10), .add(15),
            .subtract(5), .subtract(10),
            .divide(2)
        ]
        return operations.randomElement() ?? .add(5)
    }
}
