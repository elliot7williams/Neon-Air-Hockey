//
//  ContentView.swift
//  Neon Air Hockey
//
//  Created by Elliot Williams on 2025-07-03.
//

import SwiftUI
import Combine
import MultipeerConnectivity
import AVFoundation

// Add network case to GameMode
enum GameMode {
    case singlePlayer, twoPlayer, network
}

enum Difficulty {
    case easy, medium, hard
}

struct ParticleBurst: View {
    let position: CGPoint
    @State private var particles: [UUID] = Array(repeating: UUID(), count: 20)
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                let randomColor = Color(hue: Double.random(in: 0...1), saturation: 0.9, brightness: 1.0)
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [randomColor, randomColor.opacity(0.6), .clear]), 
                        center: .center, 
                        startRadius: 0, 
                        endRadius: 15
                    ))
                    .frame(width: CGFloat.random(in: 8...16), height: CGFloat.random(in: 8...16))
                    .position(position)
                    .offset(
                        x: animate ? CGFloat.random(in: -60...60) : 0,
                        y: animate ? CGFloat.random(in: -60...60) : 0
                    )
                    .opacity(animate ? 0 : 0.9)
                    .scaleEffect(animate ? 2.0 : 0.3)
                    .animation(
                        Animation.easeOut(duration: 0.6).delay(Double(index) * 0.02),
                        value: animate
                    )
                    .shadow(color: randomColor, radius: 8, x: 0, y: 0)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct VictoryOverlay: View {
    let winner: Int

    @State private var show = false

    var body: some View {
        ZStack {
            if show {
                Color.black.opacity(0.75)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    PulsingGameOverText(text: winner == 1 ? "PLAYER 1 WINS!" : "PLAYER 2 WINS!", glowColor: .green)
                    GlowingNeonLabel(text: "TAP TO RESTART", fontSize: 20, color: .purple)
                }
                .onTapGesture {
                    show = false
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                show = true
            }
        }
    }
}

// MARK: - Neon Reflection
struct NeonReflection<Content: View>: View {
    let content: Content
    let opacity: Double
    let blur: CGFloat

    init(opacity: Double = 0.3, blur: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.opacity = opacity
        self.blur = blur
    }

    var body: some View {
        content
            .scaleEffect(x: 1, y: -1)
            .opacity(opacity)
            .blur(radius: blur)
            .blendMode(.screen)
    }
}

// MARK: - Enhanced Neon Grid Background
struct NeonGridOverlay: View {
    @State private var offset: CGFloat = 0
    @State private var colorShift: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Horizontal lines with rainbow colors
                ForEach(0..<30) { i in
                    let hue = (Double(i) / 30.0 + colorShift).truncatingRemainder(dividingBy: 1)
                    Rectangle()
                        .fill(Color(hue: hue, saturation: 0.8, brightness: 0.3).opacity(0.15))
                        .frame(height: 2)
                        .offset(y: CGFloat(i) * 20 + offset)
                        .blur(radius: 1)
                        .shadow(color: Color(hue: hue, saturation: 1, brightness: 1), radius: 3, x: 0, y: 0)
                }
                // Vertical lines with rainbow colors
                ForEach(0..<20) { i in
                    let hue = (Double(i) / 20.0 + colorShift + 0.5).truncatingRemainder(dividingBy: 1)
                    Rectangle()
                        .fill(Color(hue: hue, saturation: 0.8, brightness: 0.3).opacity(0.15))
                        .frame(width: 2)
                        .offset(x: CGFloat(i) * 20 + offset)
                        .blur(radius: 1)
                        .shadow(color: Color(hue: hue, saturation: 1, brightness: 1), radius: 3, x: 0, y: 0)
                }
                // Diagonal accent lines
                ForEach(0..<10) { i in
                    let hue = (Double(i) / 10.0 + colorShift * 2).truncatingRemainder(dividingBy: 1)
                    Rectangle()
                        .fill(Color(hue: hue, saturation: 1, brightness: 0.8).opacity(0.08))
                        .frame(width: 1, height: geometry.size.height)
                        .rotationEffect(.degrees(45))
                        .offset(x: CGFloat(i) * 40 + offset * 2)
                        .blur(radius: 2)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                    offset = -20
                }
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    colorShift = 1.0
                }
            }
        }
    }
}

// MARK: - Enhanced Glow Pulse Modifier
struct PulsingGlow: ViewModifier {
    @State private var pulse = false
    @State private var colorShift: Double = 0
    var color: Color = .blue
    var baseRadius: CGFloat = 10

    func body(content: Content) -> some View {
        let dynamicColor = Color(hue: colorShift, saturation: 0.9, brightness: 1.0)
        content
            .shadow(color: dynamicColor.opacity(0.8), radius: pulse ? baseRadius * 2.5 : baseRadius)
            .shadow(color: color.opacity(0.6), radius: pulse ? baseRadius * 1.8 : baseRadius * 0.8)
            .shadow(color: .white.opacity(0.3), radius: pulse ? baseRadius * 0.5 : baseRadius * 0.3)
            .scaleEffect(pulse ? 1.08 : 1)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                    pulse.toggle()
                }
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    colorShift = 1.0
                }
            }
    }
}

extension View {
    func pulsingGlow(color: Color = .cyan, radius: CGFloat = 10) -> some View {
        modifier(PulsingGlow(color: color, baseRadius: radius))
    }
}

// MARK: - Puck Ripple Effect
struct PuckRipple: View {
    let position: CGPoint
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(Color.cyan, lineWidth: 3)
            .frame(width: 60, height: 60)
            .position(position)
            .scaleEffect(animate ? 1.5 : 1)
            .opacity(animate ? 0 : 0.5)
            .blur(radius: 1)
            .onAppear {
                withAnimation(Animation.easeOut(duration: 0.4)) {
                    animate = true
                }
            }
    }
}

// MARK: - Enhanced Neon Aura Background
struct NeonAuraBackground: View {
    @State private var rotation: Double = 0
    @State private var secondaryRotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Primary rotating gradient
            AngularGradient(
                gradient: Gradient(colors: [
                    .blue, .purple, .pink, .orange, .yellow, .green, .cyan, .red, .blue
                ]),
                center: .center,
                angle: .degrees(rotation)
            )
            .scaleEffect(scale)
            .blur(radius: 60)
            
            // Secondary counter-rotating gradient
            AngularGradient(
                gradient: Gradient(colors: [
                    .cyan, .blue, .purple, .pink, .red, .orange, .yellow, .green, .cyan
                ]),
                center: .center,
                angle: .degrees(-secondaryRotation)
            )
            .scaleEffect(scale * 0.8)
            .blur(radius: 40)
            .opacity(0.6)
            
            // Pulsing radial overlay
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.2),
                    Color.clear
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .scaleEffect(scale)
            .blur(radius: 20)
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(Color.black.opacity(0.3))
        .onAppear {
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(Animation.linear(duration: 12).repeatForever(autoreverses: false)) {
                secondaryRotation = 360
            }
            withAnimation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

// MARK: - Enhanced Neon Label
struct GlowingNeonLabel: View {
    let text: String
    let fontSize: CGFloat
    let color: Color
    @State private var glowIntensity: Double = 0.8
    @State private var colorShift: Double = 0

    var body: some View {
        let dynamicColor = Color(hue: colorShift, saturation: 0.9, brightness: 1.0)
        Text(text)
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: dynamicColor.opacity(glowIntensity), radius: 15)
            .shadow(color: color.opacity(0.8), radius: 8)
            .shadow(color: .white.opacity(0.4), radius: 3)
            .overlay(
                Text(text)
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.clear)
                    .shadow(color: dynamicColor.opacity(0.6), radius: 20)
                    .shadow(color: .white.opacity(0.3), radius: 5)
            )
            .scaleEffect(glowIntensity * 0.1 + 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever()) {
                    glowIntensity = glowIntensity == 0.8 ? 1.4 : 0.8
                }
                withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                    colorShift = 1.0
                }
            }
    }
}

// MARK: - Glowing Score Text
struct GlowingScore: View {
    let score: Int
    let color: Color

    @State private var pulse = false

    var body: some View {
        Text("\(score)")
            .font(.system(size: 40, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: color, radius: pulse ? 20 : 10)
            .scaleEffect(pulse ? 1.1 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                    pulse.toggle()
                }
            }
    }
}

// MARK: - Glowing Game Over Text
struct PulsingGameOverText: View {
    let text: String
    let glowColor: Color

    @State private var glowPulse = false

    var body: some View {
        Text(text)
            .font(.system(size: 36, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: glowColor.opacity(0.6), radius: glowPulse ? 20 : 5)
            .scaleEffect(glowPulse ? 1.1 : 1)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                    glowPulse.toggle()
                }
            }
    }
}

// MARK: - Audio Manager
class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    enum SoundType: String {
        case goal, hit
    }

    func playSound(_ type: SoundType) {
        guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "mp3") else {
            print("Missing sound file: \(type.rawValue).mp3")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    // Safe play function to avoid conflicts
    func safePlay(_ type: SoundType) {
        if player?.isPlaying != true {
            playSound(type)
        }
    }
}

struct NetworkedNeonAirHockey: View {
    @StateObject private var game = AirHockeyGame()
    @State private var showRipple = false
    @State private var puckShake: CGFloat = 0
    @State private var showMenu = true
    @State private var showParticles = false
    @State private var victoryVisible = false
    @State private var scoreSparkle1 = false
    @State private var scoreSparkle2 = false
    @State private var fireworkBurst = false
    @State private var selectedMode: GameMode = .twoPlayer
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showConnectionMenu = false
    @State private var colorShift: Double = 0
    @State private var startPressed = false
    @State private var pressedButtons: [String: Bool] = [:]
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, rate: CGFloat) -> CGFloat {
        return a + (b - a) * rate
    }

    var dynamicPuckColor: Color {
        Color(hue: colorShift.truncatingRemainder(dividingBy: 1), saturation: 0.9, brightness: 1.0)
    }
    
    // New chromatic gradient for paddles
    func paddleGradient(color: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                color.opacity(0.8),
                .white,
                color.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let tableSize = CGSize(width: min(350, screenWidth * 0.9), height: min(550, screenHeight * 0.65))
            let tableOrigin = CGPoint(
                x: (screenWidth - tableSize.width) / 2,
                y: max(80, (screenHeight - tableSize.height) / 2 - 20)
            )

            ZStack {
                // Animated background
                PulsatingGradientBackground()
                NeonAuraBackground()
                NeonGridOverlay()
                
                if showMenu {
                    MenuView(
                        selectedMode: $selectedMode,
                        selectedDifficulty: $selectedDifficulty,
                        showConnectionMenu: $showConnectionMenu,
                        game: game,
                        startPressed: $startPressed,
                        showMenu: $showMenu,
                        dynamicPuckColor: dynamicPuckColor,
                        pressedButtons: $pressedButtons
                    )
                    .sheet(isPresented: $showConnectionMenu) {
                        ConnectionMenuView(game: game)
                    }
                } else {
                    GameScreen(
                        game: game,
                        showMenu: $showMenu,
                        showRipple: $showRipple,
                        puckShake: $puckShake,
                        showParticles: $showParticles,
                        fireworkBurst: $fireworkBurst,
                        dynamicPuckColor: dynamicPuckColor,
                        pressedButtons: $pressedButtons,
                        tableSize: tableSize,
                        tableOrigin: tableOrigin,
                        paddleGradient: paddleGradient,
                        lerp: lerp,
                        colorShift: $colorShift
                    )
                }
            }
        }
        .statusBar(hidden: true)
        .onChange(of: game.player1Score) { _ in
            withAnimation {
                scoreSparkle1 = true
                fireworkBurst = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                scoreSparkle1 = false
                fireworkBurst = false
            }
        }
        .onChange(of: game.player2Score) { _ in
            withAnimation {
                scoreSparkle2 = true
                fireworkBurst = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                scoreSparkle2 = false
                fireworkBurst = false
            }
        }
    }
}

// MARK: - Extracted Subviews

struct MenuView: View {
    @Binding var selectedMode: GameMode
    @Binding var selectedDifficulty: Difficulty
    @Binding var showConnectionMenu: Bool
    @ObservedObject var game: AirHockeyGame
    @Binding var startPressed: Bool
    @Binding var showMenu: Bool
    var dynamicPuckColor: Color
    @Binding var pressedButtons: [String: Bool]
    
    var body: some View {
        VStack(spacing: 30) {
            GlowingNeonLabel(text: "NEON AIR HOCKEY", fontSize: 42, color: dynamicPuckColor)
                .padding(.top, 60)

            Spacer()

            VStack(spacing: 20) {
                Text("SELECT MODE")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))

                VStack(spacing: 15) {
                    NeonMenuButton(
                        text: "VS AI",
                        isSelected: selectedMode == .singlePlayer,
                        selectedColor: .purple,
                        isPressed: pressedButtons["VS AI"] ?? false,
                        action: {
                            selectedMode = .singlePlayer
                            SoundManager.shared.safePlay(.hit)
                        },
                        onPressChanged: { pressed in
                            pressedButtons["VS AI"] = pressed
                        }
                    )
                    
                    NeonMenuButton(
                        text: "2 PLAYERS (LOCAL)",
                        isSelected: selectedMode == .twoPlayer,
                        selectedColor: .cyan,
                        isPressed: pressedButtons["2P"] ?? false,
                        action: {
                            selectedMode = .twoPlayer
                            SoundManager.shared.safePlay(.hit)
                        },
                        onPressChanged: { pressed in
                            pressedButtons["2P"] = pressed
                        }
                    )
                    
                    NeonMenuButton(
                        text: "NETWORK PLAY",
                        isSelected: selectedMode == .network,
                        selectedColor: .orange,
                        isPressed: pressedButtons["NET"] ?? false,
                        action: {
                            selectedMode = .network
                            showConnectionMenu = true
                            SoundManager.shared.safePlay(.hit)
                        },
                        onPressChanged: { pressed in
                            pressedButtons["NET"] = pressed
                        }
                    )
                }
            }

            if selectedMode == .singlePlayer {
                DifficultySelector(
                    selectedDifficulty: $selectedDifficulty,
                    pressedButtons: $pressedButtons
                )
            }

            Spacer()

            Button(action: {
                startPressed = true
                game.gameMode = selectedMode
                game.difficulty = selectedDifficulty
                withAnimation {
                    showMenu = false
                    game.resetGame()
                    game.startGame()
                    SoundManager.shared.safePlay(.goal)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    startPressed = false
                }
            }) {
                GlowingNeonLabel(text: "START GAME", fontSize: 28, color: dynamicPuckColor)
                    .scaleEffect(startPressed ? 1.1 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: startPressed)
            }
            .disabled(selectedMode == .network && !game.multipeerSession.connected)
            .opacity((selectedMode == .network && !game.multipeerSession.connected) ? 0.5 : 1)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

struct DifficultySelector: View {
    @Binding var selectedDifficulty: Difficulty
    @Binding var pressedButtons: [String: Bool]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("DIFFICULTY")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 15) {
                Button(action: {
                    selectedDifficulty = .easy
                    SoundManager.shared.safePlay(.hit)
                }) {
                    Text("EASY")
                        .bold()
                        .padding(10)
                        .frame(width: 100)
                        .background(
                            Capsule()
                                .fill(selectedDifficulty == .easy ? .green : Color.gray.opacity(0.3))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedDifficulty == .easy ? .green : Color.gray, lineWidth: 2)
                        )
                        .foregroundColor(selectedDifficulty == .easy ? .black : .white)
                        .scaleEffect(pressedButtons["EASY"] ?? false ? 0.9 : 1.0)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in pressedButtons["EASY"] = true }
                        .onEnded { _ in pressedButtons["EASY"] = false }
                )
                
                Button(action: {
                    selectedDifficulty = .medium
                    SoundManager.shared.safePlay(.hit)
                }) {
                    Text("MEDIUM")
                        .bold()
                        .padding(10)
                        .frame(width: 100)
                        .background(
                            Capsule()
                                .fill(selectedDifficulty == .medium ? .orange : Color.gray.opacity(0.3))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedDifficulty == .medium ? .orange : Color.gray, lineWidth: 2)
                        )
                        .foregroundColor(selectedDifficulty == .medium ? .black : .white)
                        .scaleEffect(pressedButtons["MED"] ?? false ? 0.9 : 1.0)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in pressedButtons["MED"] = true }
                        .onEnded { _ in pressedButtons["MED"] = false }
                )
                
                Button(action: {
                    selectedDifficulty = .hard
                    SoundManager.shared.safePlay(.hit)
                }) {
                    Text("HARD")
                        .bold()
                        .padding(10)
                        .frame(width: 100)
                        .background(
                            Capsule()
                                .fill(selectedDifficulty == .hard ? .red : Color.gray.opacity(0.3))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedDifficulty == .hard ? .red : Color.gray, lineWidth: 2)
                        )
                        .foregroundColor(selectedDifficulty == .hard ? .black : .white)
                        .scaleEffect(pressedButtons["HARD"] ?? false ? 0.9 : 1.0)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in pressedButtons["HARD"] = true }
                        .onEnded { _ in pressedButtons["HARD"] = false }
                )
            }
        }
    }
}

struct GameScreen: View {
    @ObservedObject var game: AirHockeyGame
    @Binding var showMenu: Bool
    @Binding var showRipple: Bool
    @Binding var puckShake: CGFloat
    @Binding var showParticles: Bool
    @Binding var fireworkBurst: Bool
    var dynamicPuckColor: Color
    @Binding var pressedButtons: [String: Bool]
    var tableSize: CGSize
    var tableOrigin: CGPoint
    var paddleGradient: (Color) -> LinearGradient
    var lerp: (CGFloat, CGFloat, CGFloat) -> CGFloat
    @Binding var colorShift: Double
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Connection status
                if game.gameMode == .network {
                    HStack {
                        Image(systemName: game.multipeerSession.connected ? "wifi" : "wifi.slash")
                            .foregroundColor(game.multipeerSession.connected ? .green : .red)
                        Text(game.multipeerSession.connected ? "Connected" : "Disconnected")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if !game.multipeerSession.connected {
                            Button(action: {
                                showMenu = true
                            }) {
                                Text("Reconnect")
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Capsule().fill(Color.white.opacity(0.2)))
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                
                // Player scores
                HStack {
                    GlowingScore(score: game.player1Score, color: dynamicPuckColor)
                    Spacer()
                    GlowingScore(score: game.player2Score, color: dynamicPuckColor)
                }
                .padding(.horizontal, 40)
                .padding(.top, game.gameMode == .network ? 0 : 20)
                
                // Game field - centered
                Spacer()
                HStack {
                    Spacer()
                    GameFieldView(
                        game: game,
                        showRipple: $showRipple,
                        puckShake: $puckShake,
                        showParticles: $showParticles,
                        fireworkBurst: $fireworkBurst,
                        dynamicPuckColor: dynamicPuckColor,
                        tableSize: tableSize,
                        tableOrigin: CGPoint(x: 0, y: 0), // Reset origin since we're centering with HStack
                        paddleGradient: paddleGradient
                    )
                    .frame(width: tableSize.width, height: tableSize.height)
                    Spacer()
                }
                Spacer()
                
                // Controls at bottom
                GameControlsView(
                    game: game,
                    showMenu: $showMenu,
                    showRipple: $showRipple,
                    showParticles: $showParticles,
                    fireworkBurst: $fireworkBurst,
                    dynamicPuckColor: dynamicPuckColor,
                    pressedButtons: $pressedButtons
                )
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
            }
        }
        .onAppear {
            // Start the color shift animation
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                colorShift = 1.0
            }
        }
    }
}

struct GameFieldView: View {
    @ObservedObject var game: AirHockeyGame
    @Binding var showRipple: Bool
    @Binding var puckShake: CGFloat
    @Binding var showParticles: Bool
    @Binding var fireworkBurst: Bool
    var dynamicPuckColor: Color
    var tableSize: CGSize
    var tableOrigin: CGPoint
    var paddleGradient: (Color) -> LinearGradient
    
    var body: some View {
        ZStack {
            // Air hockey table with animated border
            AnimatedNeonTable()
                .frame(width: tableSize.width, height: tableSize.height)
                .position(CGPoint(x: tableSize.width/2, y: tableSize.height/2))
            
            // Center line with chromatic effect
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .blue, .green, .purple, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: tableSize.width, height: 4)
                .blur(radius: 1)
                .position(CGPoint(x: tableSize.width/2, y: tableSize.height/2))
            
            // Center circle
            AnimatedNeonCircle()
                .frame(width: 60, height: 60)
                .position(CGPoint(x: tableSize.width/2, y: tableSize.height/2))
            
            // Ripple effect
            if showRipple {
                PuckRipple(position: CGPoint(
                    x: game.puckPosition.x,
                    y: game.puckPosition.y
                ))
                .transition(.opacity)
            }
            
            // Particle effect
            if showParticles {
                ParticleBurst(position: CGPoint(
                    x: game.puckPosition.x,
                    y: game.puckPosition.y
                ))
                .transition(.scale)
            }
            
            // Firework effect
            if fireworkBurst {
                FireworkStreak(position: CGPoint(
                    x: tableSize.width/2,
                    y: tableSize.height/2
                ))
                .transition(.opacity)
            }

            // Enhanced puck with improved trail effect
            EnhancedPuckView(
                game: game,
                puckShake: $puckShake,
                dynamicPuckColor: dynamicPuckColor,
                tableOrigin: CGPoint(x: 0, y: 0)
            )
            
            // Player 1 paddle (bottom) with chromatic glow
            PaddleView(
                position: game.player1Position,
                color: .green,
                tableOrigin: CGPoint(x: 0, y: 0),
                paddleGradient: paddleGradient,
                isEnabled: game.isLocalPlayerTurn
            ) { location in
                game.movePlayer1(to: location)
            }

            // Player 2 paddle (top) with chromatic glow
            PaddleView(
                position: game.player2Position,
                color: .orange,
                tableOrigin: CGPoint(x: 0, y: 0),
                paddleGradient: paddleGradient,
                isEnabled: game.isLocalPlayerTurn
            ) { location in
                game.movePlayer2(to: location)
            }
            
            // Goal areas
            // Player 1 goal (top)
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.red.opacity(0.3), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 120, height: 20)
                .position(x: tableSize.width/2, y: 20)
            
            // Player 2 goal (bottom)
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.red.opacity(0.3), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                ))
                .frame(width: 120, height: 20)
                .position(x: tableSize.width/2, y: tableSize.height - 20)
        }
    }
}

// MARK: - Puck Shake Effect Wrapper

struct ShakingView<Content: View>: View {
    var intensity: CGFloat
    var content: () -> Content
    @Binding var shake: CGFloat  // Changed from Bool to CGFloat

    var body: some View {
        content()
            .offset(x: shake * CGFloat.random(in: -1...1) * intensity,
                    y: shake * CGFloat.random(in: -1...1) * intensity)
    }
}

struct EnhancedPuckView: View {
    @ObservedObject var game: AirHockeyGame
    @Binding var puckShake: CGFloat
    var dynamicPuckColor: Color
    var tableOrigin: CGPoint
    @State private var trailColorShift: Double = 0
    
    var body: some View {
        ZStack {
            // Enhanced puck trail effect with rainbow colors
            ForEach(0..<10, id: \.self) { i in
                let trailColor = Color(hue: (trailColorShift + Double(i) * 0.1).truncatingRemainder(dividingBy: 1), saturation: 0.9, brightness: 1.0)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [trailColor, trailColor.opacity(0.6), .clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 25 + CGFloat(i * 3), height: 25 + CGFloat(i * 3))
                    .opacity(1 - Double(i) * 0.1)
                    .position(
                        x: tableOrigin.x + game.puckPosition.x + game.puckVelocity.dx * CGFloat(i) * -0.4,
                        y: tableOrigin.y + game.puckPosition.y + game.puckVelocity.dy * CGFloat(i) * -0.4
                    )
                    .blur(radius: CGFloat(i) * 0.6)
                    .shadow(color: trailColor.opacity(0.8), radius: 5, x: 0, y: 0)
            }
            
            // Main puck with enhanced shake effect
            ShakingView(intensity: 6, content: {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(dynamicPuckColor.opacity(0.4))
                        .frame(width: 80, height: 80)
                        .blur(radius: 15)
                        .shadow(color: dynamicPuckColor.opacity(0.8), radius: 25, x: 0, y: 0)
                    
                    // Middle glow
                    Circle()
                        .fill(dynamicPuckColor.opacity(0.6))
                        .frame(width: 50, height: 50)
                        .blur(radius: 8)
                        .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    // Main puck body
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.white, dynamicPuckColor.opacity(0.8), dynamicPuckColor]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [.white, dynamicPuckColor, .white]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 3)
                                .blur(radius: 0.5)
                        )
                        .shadow(color: dynamicPuckColor.opacity(0.9), radius: 20, x: 0, y: 0)
                        .shadow(color: .white.opacity(0.6), radius: 8, x: 0, y: 0)
                }
            }, shake: $puckShake)
            .position(x: tableOrigin.x + game.puckPosition.x, y: tableOrigin.y + game.puckPosition.y)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                trailColorShift = 1.0
            }
        }
    }
}

struct TrailCircle: View {
    let index: Int
    @ObservedObject var game: AirHockeyGame
    var tableOrigin: CGPoint
    var dynamicPuckColor: Color
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [.white, dynamicPuckColor.opacity(0.1)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 15
                )
            )
            .frame(width: 30 + CGFloat(index * 4), height: 30 + CGFloat(index * 4))
            .opacity(1 - Double(index) * 0.2)
            .position(
                x: tableOrigin.x + game.puckPosition.x + game.puckVelocity.dx * CGFloat(index) * -0.3,
                y: tableOrigin.y + game.puckPosition.y + game.puckVelocity.dy * CGFloat(index) * -0.3
            )
            .blur(radius: CGFloat(index) * 0.8)
    }
}

struct MainPuckCircle: View {
    var dynamicPuckColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(dynamicPuckColor.opacity(0.3))
                .frame(width: 60, height: 60)
                .offset(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -2...2))
                .blur(radius: 10)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white, dynamicPuckColor]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [.white, dynamicPuckColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 2)
                        .blur(radius: 1)
                )
                .shadow(color: dynamicPuckColor.opacity(0.9), radius: 15, x: 0, y: 0)
        }
    }
}

struct PaddleView: View {
    var position: CGPoint
    var color: Color
    var tableOrigin: CGPoint
    var paddleGradient: (Color) -> LinearGradient
    var isEnabled: Bool
    var onDrag: (CGPoint) -> Void
    @State private var glowPulse: CGFloat = 1.0
    @State private var colorShift: Double = 0
    
    var body: some View {
        let dynamicGlowColor = Color(hue: colorShift, saturation: 0.8, brightness: 1.0)
        ZStack {
            // Outer glow ring
            Circle()
                .fill(dynamicGlowColor.opacity(0.3))
                .frame(width: 90 * glowPulse, height: 90 * glowPulse)
                .blur(radius: 15)
                .shadow(color: dynamicGlowColor.opacity(0.8), radius: 30, x: 0, y: 0)
            
            // Middle glow
            Circle()
                .fill(paddleGradient(color))
                .frame(width: 70, height: 70)
                .blur(radius: 8)
                .shadow(color: color.opacity(0.9), radius: 20, x: 0, y: 0)
            
            // Main paddle body
            Circle()
                .fill(paddleGradient(color))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [.white, color, .white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 3)
                        .blur(radius: 0.5)
                )
                .shadow(color: color.opacity(0.9), radius: 15, x: 0, y: 0)
                .shadow(color: .white.opacity(0.4), radius: 8, x: 0, y: 0)
                .scaleEffect(isEnabled ? 1.0 : 0.95)
        }
        .position(x: tableOrigin.x + position.x, y: tableOrigin.y + position.y)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if isEnabled {
                        let location = CGPoint(
                            x: value.location.x - tableOrigin.x,
                            y: value.location.y - tableOrigin.y
                        )
                        onDrag(location)
                    }
                }
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowPulse = 1.15
            }
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                colorShift = 1.0
            }
        }
    }
}

struct GameControlsView: View {
    @ObservedObject var game: AirHockeyGame
    @Binding var showMenu: Bool
    @Binding var showRipple: Bool
    @Binding var showParticles: Bool
    @Binding var fireworkBurst: Bool
    var dynamicPuckColor: Color
    @Binding var pressedButtons: [String: Bool]
    
    var body: some View {
        VStack(spacing: 20) {
            // Game status
            Text(game.gameStatus)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: dynamicPuckColor, radius: 5, x: 0, y: 0)
            
            // Game controls
            HStack(spacing: 30) {
                ForEach(["RESET", "PAUSE", "MENU"], id: \.self) { label in
                    Button(action: {
                        SoundManager.shared.safePlay(.hit)
                        switch label {
                        case "RESET":
                            game.resetGame()
                            // Trigger effects
                            withAnimation {
                                showRipple = true
                                showParticles = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showRipple = false
                                showParticles = false
                            }
                        case "PAUSE":
                            game.isPaused.toggle()
                            if !game.isPaused {
                                withAnimation {
                                    fireworkBurst = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    fireworkBurst = false
                                }
                            }
                        case "MENU":
                            withAnimation { showMenu = true }
                        default: break
                        }
                    }) {
                        Text(label)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(dynamicPuckColor.opacity(0.6)))
                            .shadow(color: dynamicPuckColor.opacity(0.6), radius: 5)
                            .scaleEffect(pressedButtons[label] ?? false ? 0.9 : 1.0)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in pressedButtons[label] = true }
                            .onEnded { _ in pressedButtons[label] = false }
                    )
                }
            }
        }
    }
}

// MARK: - Firework Streak Effect
struct FireworkStreak: View {
    let position: CGPoint
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hue: Double(i)/20, saturation: 1, brightness: 1),
                                .clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 10, height: 10)
                    .position(position)
                    .offset(
                        x: animate ? CGFloat.random(in: -100...100) : 0,
                        y: animate ? CGFloat.random(in: -100...100) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 1)
                            .delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConnectionMenuView: View {
    @ObservedObject var game: AirHockeyGame
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("NETWORK PLAY")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("Your Device: \(game.multipeerSession.myPeerID.displayName)")
                    .foregroundColor(.blue)
                    .padding()
                
                if game.multipeerSession.connected {
                    VStack {
                        Text("Connected to:")
                            .foregroundColor(.white)
                        Text(game.multipeerSession.connectedPeers.first?.displayName ?? "Unknown")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                    .padding()
                    
                    Button(action: {
                        game.multipeerSession.session.disconnect()
                    }) {
                        NeonButtonLabel(title: "Disconnect", color: .red)
                    }
                } else {
                    VStack(spacing: 20) {
                        Button(action: {
                            game.multipeerSession.advertiseSelf()
                        }) {
                            HStack {
                                Image(systemName: game.multipeerSession.isAdvertising ? "checkmark.circle" : "wifi")
                                Text(game.multipeerSession.isAdvertising ? "Advertising..." : "Host Game")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(game.multipeerSession.isAdvertising ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(game.multipeerSession.isAdvertising ? Color.green : Color.blue, lineWidth: 2)
                                    )
                            )
                        }
                        
                        Button(action: {
                            game.multipeerSession.browseForPeers()
                        }) {
                            HStack {
                                Image(systemName: game.multipeerSession.isBrowsing ? "checkmark.circle" : "magnifyingglass")
                                Text(game.multipeerSession.isBrowsing ? "Searching..." : "Join Game")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(game.multipeerSession.isBrowsing ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(game.multipeerSession.isBrowsing ? Color.green : Color.orange, lineWidth: 2)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // List of available peers
                    if game.multipeerSession.isBrowsing && !game.multipeerSession.availablePeers.isEmpty {
                        Text("Available Players:")
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        List(game.multipeerSession.availablePeers, id: \.self) { peer in
                            Button(action: {
                                game.multipeerSession.serviceBrowser.invitePeer(peer, to: game.multipeerSession.session, withContext: nil, timeout: 30)
                            }) {
                                HStack {
                                    Text(peer.displayName)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "network")
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 200)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            game.multipeerSession.resetSession()
        }
    }
}

// Game logic with multiplayer support
class AirHockeyGame: ObservableObject {
    // Game elements positions
    @Published var player1Position = CGPoint(x: 175, y: 500)
    @Published var player2Position = CGPoint(x: 175, y: 50)
    @Published var puckPosition = CGPoint(x: 175, y: 275)
    
    // Game state
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var isPaused = false
    @Published var puckVelocity = CGVector(dx: 0, dy: 0)
    
    // Network state
    @Published var isLocalPlayerTurn = true
    let multipeerSession = MultipeerSession()
    
    // Game settings
    let tableSize = CGSize(width: 350, height: 550)
    let paddleSize: CGFloat = 25
    let puckSize: CGFloat = 15
    let maxSpeed: CGFloat = 25
    
    // Game state
    enum GameState {
        case menu, playing, gameOver
    }
    
    @Published var gameState: GameState = .playing
    @Published var winner: Int = 0
    
    // Game modes and difficulty
    @Published var gameMode: GameMode = .twoPlayer
    @Published var difficulty: Difficulty = .medium
    
    // AI properties
    private var aiTargetPosition: CGPoint = .zero
    private var aiReactionTime: TimeInterval = 0.0
    private var aiMoveTimer: Timer?
    
    // Game timer
    private var gameTimer: Timer?
    
    var gameStatus: String {
        if gameState == .gameOver {
            if gameMode == .network {
                return winner == 1 ? "YOU WIN!" : "YOU LOSE!"
            }
            return winner == 1 ? "PLAYER 1 WINS!" : gameMode == .singlePlayer ? "YOU WIN!" : "PLAYER 2 WINS!"
        }
        return "\(player1Score) : \(player2Score)"
    }
    
    init() {
        // Set up network handlers
        multipeerSession.dataReceivedHandler = { [weak self] data in
            self?.handleReceivedData(data)
        }
        
        multipeerSession.connectedHandler = { [weak self] in
            // When connected, decide who goes first
            self?.isLocalPlayerTurn = self?.multipeerSession.isHost ?? false
            if self?.isLocalPlayerTurn == true {
                self?.resetPuck()
            }
        }
    }
    
    func startGame() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !self.isPaused && self.gameState == .playing {
                self.updateGame()
                // Update AI if in single player mode
                if self.gameMode == .singlePlayer {
                    self.updateAI()
                }
                
                // Send game state to opponent in network mode
                if self.gameMode == .network && self.multipeerSession.connected {
                    self.sendGameState()
                }
            }
        }
    }
    
    func resetGame() {
        player1Score = 0
        player2Score = 0
        resetPuck()
        gameState = .playing
        isPaused = false
        
        if gameMode == .network {
            isLocalPlayerTurn = multipeerSession.isHost
        }
    }
    
    func resetPuck() {
        puckPosition = CGPoint(x: tableSize.width / 2, y: tableSize.height / 2)
        // Random initial direction
        let angle = CGFloat.random(in: 0..<CGFloat.pi * 2)
        let speed: CGFloat = difficulty == .easy ? 7 : difficulty == .medium ? 10 : 13
        puckVelocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
        
        // Send puck reset to opponent
        if gameMode == .network && multipeerSession.connected {
            sendPuckReset()
        }
    }
    
    func movePlayer1(to position: CGPoint) {
        guard gameState == .playing && !isPaused else { return }
        guard gameMode != .network || isLocalPlayerTurn else { return }
        
        var newPosition = position
        
        // Constrain to bottom half
        newPosition.y = max(newPosition.y, tableSize.height / 2 + 40)
        newPosition.y = min(newPosition.y, tableSize.height - 30)
        
        // Constrain to table width
        newPosition.x = max(newPosition.x, 30)
        newPosition.x = min(newPosition.x, tableSize.width - 30)
        
        player1Position = newPosition
        
        // Send position update to opponent
        if gameMode == .network && multipeerSession.connected {
            sendPositionUpdate(player: 1, position: newPosition)
        }
    }
    
    func movePlayer2(to position: CGPoint) {
        guard gameState == .playing && !isPaused else { return }
        guard gameMode != .network || isLocalPlayerTurn else { return }
        
        var newPosition = position
        
        // Constrain to top half
        newPosition.y = max(newPosition.y, 30)
        newPosition.y = min(newPosition.y, tableSize.height / 2 - 40)
        
        // Constrain to table width
        newPosition.x = max(newPosition.x, 30)
        newPosition.x = min(newPosition.x, tableSize.width - 30)
        
        player2Position = newPosition
        
        // Send position update to opponent
        if gameMode == .network && multipeerSession.connected {
            sendPositionUpdate(player: 2, position: newPosition)
        }
    }
    
    func updateGame() {
        // Only the host updates the puck in network mode
        if gameMode == .network && !isLocalPlayerTurn {
            return
        }
        
        // Update puck position
        puckPosition.x += puckVelocity.dx
        puckPosition.y += puckVelocity.dy
        
        // Puck collisions with walls
        if puckPosition.x <= puckSize || puckPosition.x >= tableSize.width - puckSize {
            puckVelocity.dx *= -0.95 // Reverse X direction with some damping
            puckPosition.x = puckPosition.x <= puckSize ? puckSize : tableSize.width - puckSize
            SoundManager.shared.playSound(.hit)
        }
        
        // Puck collisions with top and bottom (goals)
        if puckPosition.y <= 20 {
            // Player 2 scores (ball went into player 1's goal)
            SoundManager.shared.playSound(.goal)
            player2Score += 1
            checkGameOver()
            resetPuck()
            return
        } else if puckPosition.y >= tableSize.height - 20 {
            // Player 1 scores (ball went into player 2's goal)
            SoundManager.shared.playSound(.goal)
            player1Score += 1
            checkGameOver()
            resetPuck()
            return
        } else if puckPosition.y <= puckSize || puckPosition.y >= tableSize.height - puckSize {
            puckVelocity.dy *= -0.95 // Reverse Y direction with some damping
            puckPosition.y = puckPosition.y <= puckSize ? puckSize : tableSize.height - puckSize
            SoundManager.shared.playSound(.hit)
        }
        
        // Puck collisions with paddles
        let distanceToPlayer1 = distance(puckPosition, player1Position)
        let distanceToPlayer2 = distance(puckPosition, player2Position)
        
        // Collision with player 1 paddle
        if distanceToPlayer1 < paddleSize + puckSize {
            handlePaddleCollision(paddlePosition: player1Position)
            // Move puck outside paddle to prevent sticking
            movePuckAwayFromPaddle(paddlePosition: player1Position)
        }
        
        // Collision with player 2 paddle
        if distanceToPlayer2 < paddleSize + puckSize {
            handlePaddleCollision(paddlePosition: player2Position)
            // Move puck outside paddle to prevent sticking
            movePuckAwayFromPaddle(paddlePosition: player2Position)
        }
        
        // Slow down puck slightly over time
        puckVelocity.dx *= 0.995
        puckVelocity.dy *= 0.995
    }
    
    private func handlePaddleCollision(paddlePosition: CGPoint) {
        let dx = puckPosition.x - paddlePosition.x
        let dy = puckPosition.y - paddlePosition.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // Normalize and scale
        let nx = dx / distance
        let ny = dy / distance
        
        SoundManager.shared.playSound(.hit)
        
        // Calculate reflection
        let dotProduct = puckVelocity.dx * nx + puckVelocity.dy * ny
        puckVelocity.dx = puckVelocity.dx - 2 * dotProduct * nx
        puckVelocity.dy = puckVelocity.dy - 2 * dotProduct * ny
        
        // Add paddle velocity effect
        puckVelocity.dx += (paddlePosition.x - puckPosition.x) * 0.2
        puckVelocity.dy += (paddlePosition.y - puckPosition.y) * 0.2
        
        // Add speed boost on collision
        let boost: CGFloat = 1.1
        puckVelocity.dx *= boost
        puckVelocity.dy *= boost
        
        // Limit maximum speed
        let speed = sqrt(puckVelocity.dx * puckVelocity.dx + puckVelocity.dy * puckVelocity.dy)
        if speed > maxSpeed {
            puckVelocity.dx = puckVelocity.dx / speed * maxSpeed
            puckVelocity.dy = puckVelocity.dy / speed * maxSpeed
        }
    }
    
    private func movePuckAwayFromPaddle(paddlePosition: CGPoint) {
        let dx = puckPosition.x - paddlePosition.x
        let dy = puckPosition.y - paddlePosition.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // Normalize
        let nx = dx / distance
        let ny = dy / distance
        
        // Move puck outside paddle to prevent sticking
        let overlap = paddleSize + puckSize - distance
        puckPosition.x += nx * overlap * 1.1
        puckPosition.y += ny * overlap * 1.1
    }
    
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
    }
    
    private func checkGameOver() {
        if player1Score >= 7 {
            winner = 1
            gameState = .gameOver
            sendGameOver(winner: 1)
        } else if player2Score >= 7 {
            winner = 2
            gameState = .gameOver
            sendGameOver(winner: 2)
        }
    }
    
    // AI Logic
    private func updateAI() {
        // Only update AI if puck is moving towards AI or in AI's half
        guard puckPosition.y < tableSize.height / 2 + 50 || puckVelocity.dy < 0 else { return }
        
        // Predict puck position
        let predictionPoint = predictPuckPosition()
        
        // Calculate AI reaction time and smoothing based on difficulty
        var smoothingFactor: CGFloat
        switch difficulty {
        case .easy:
            smoothingFactor = 0.03
        case .medium:
            smoothingFactor = 0.05
        case .hard:
            smoothingFactor = 0.08
        }
        
        // Smooth AI movement to reduce jittering
        let currentX = player2Position.x
        let targetX = predictionPoint.x
        let newX = currentX + (targetX - currentX) * smoothingFactor
        
        // Update AI position smoothly
        let smoothedPosition = CGPoint(x: newX, y: predictionPoint.y)
        movePlayer2(to: smoothedPosition)
    }
    
    private func predictPuckPosition() -> CGPoint {
        // Simple prediction: move to where the puck is heading
        var predictedX = puckPosition.x + puckVelocity.dx * 0.7
        var predictedY = puckPosition.y + puckVelocity.dy * 0.7
        
        // Constrain to top half
        predictedY = max(predictedY, 30)
        predictedY = min(predictedY, tableSize.height / 2 - 40)
        
        // Constrain to table width
        predictedX = max(predictedX, 30)
        predictedX = min(predictedX, tableSize.width - 30)
        
        // Add some error based on difficulty
        let errorRange: CGFloat
        switch difficulty {
        case .easy:
            errorRange = 50
        case .medium:
            errorRange = 25
        case .hard:
            errorRange = 10
        }
        
        // Apply random error
        predictedX += CGFloat.random(in: -errorRange...errorRange)
        
        return CGPoint(x: predictedX, y: predictedY)
    }
    
    // MARK: - Network Communication
    
    private func sendPositionUpdate(player: Int, position: CGPoint) {
        let message: [String: Any] = [
            "type": "position",
            "player": player,
            "x": position.x,
            "y": position.y
        ]
        multipeerSession.sendData(data: try! JSONSerialization.data(withJSONObject: message))
    }
    
    private func sendPuckReset() {
        let message: [String: Any] = [
            "type": "puckReset"
        ]
        multipeerSession.sendData(data: try! JSONSerialization.data(withJSONObject: message))
    }
    
    private func sendGameOver(winner: Int) {
        let message: [String: Any] = [
            "type": "gameOver",
            "winner": winner
        ]
        multipeerSession.sendData(data: try! JSONSerialization.data(withJSONObject: message))
    }
    
    private func sendGameState() {
        let message: [String: Any] = [
            "type": "gameState",
            "puckX": puckPosition.x,
            "puckY": puckPosition.y,
            "velX": puckVelocity.dx,
            "velY": puckVelocity.dy
        ]
        multipeerSession.sendData(data: try! JSONSerialization.data(withJSONObject: message))
    }
    
    private func handleReceivedData(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return
        }
        
        switch type {
        case "position":
            guard let player = json["player"] as? Int,
                  let x = json["x"] as? CGFloat,
                  let y = json["y"] as? CGFloat else {
                return
            }
            
            DispatchQueue.main.async {
                if player == 1 {
                    self.player1Position = CGPoint(x: x, y: y)
                } else {
                    self.player2Position = CGPoint(x: x, y: y)
                }
            }
            
        case "puckReset":
            DispatchQueue.main.async {
                self.resetPuck()
                self.isLocalPlayerTurn = !self.isLocalPlayerTurn
            }
            
        case "gameOver":
            guard let winner = json["winner"] as? Int else { return }
            DispatchQueue.main.async {
                self.winner = winner
                self.gameState = .gameOver
            }
            
        case "gameState":
            guard let puckX = json["puckX"] as? CGFloat,
                  let puckY = json["puckY"] as? CGFloat,
                  let velX = json["velX"] as? CGFloat,
                  let velY = json["velY"] as? CGFloat else {
                return
            }
            
            DispatchQueue.main.async {
                self.puckPosition = CGPoint(x: puckX, y: puckY)
                self.puckVelocity = CGVector(dx: velX, dy: velY)
            }
            
        default:
            break
        }
    }
}

// Multipeer Connectivity Session
class MultipeerSession: NSObject, ObservableObject {
    private let serviceType = "neon-airhockey"
    var myPeerID: MCPeerID // Changed from private to internal
    
    @Published var connected = false
    @Published var availablePeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    
    var isAdvertising = false
    var isBrowsing = false
    var isHost = false
    
    var dataReceivedHandler: ((Data) -> Void)?
    var connectedHandler: (() -> Void)?
    
    lazy var session: MCSession = {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    
    override init() {
        // Generate a unique peer ID with device name
        let deviceName = UIDevice.current.name
        myPeerID = MCPeerID(displayName: "\(deviceName)-\(UUID().uuidString.prefix(4))")
        super.init()
    }
    
    func resetSession() {
        session.disconnect()
        connected = false
        availablePeers = []
        connectedPeers = []
        isAdvertising = false
        isBrowsing = false
    }
    
    func advertiseSelf() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        isAdvertising = true
        isHost = true
    }
    
    func browseForPeers() {
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
        isHost = false
    }
    
    func sendData(data: Data) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data: \(error)")
        }
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connected = true
                self.connectedPeers = session.connectedPeers
                self.connectedHandler?()
                print("Connected to: \(peerID.displayName)")
                
            case .connecting:
                print("Connecting to: \(peerID.displayName)")
                
            case .notConnected:
                print("Disconnected from: \(peerID.displayName)")
                self.connected = false
                self.connectedPeers = []
                
            @unknown default:
                print("Unknown state: \(state)")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.dataReceivedHandler?(data)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !availablePeers.contains(peerID) {
            availablePeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        availablePeers.removeAll(where: { $0 == peerID })
    }
}

// Enhanced UI Components with animations
struct PulsatingGradientBackground: View {
    @State private var gradientRotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.4),
                        Color(red: 0.3, green: 0.1, blue: 0.5),
                        Color(red: 0.1, green: 0.2, blue: 0.6),
                        Color(red: 0.1, green: 0.1, blue: 0.4)
                    ]),
                    center: .center,
                    angle: .degrees(gradientRotation))
            )
            .edgesIgnoringSafeArea(.all)
            .blur(radius: 50)
            .overlay(
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 15).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
    }
}

struct AnimatedNeonTable: View {
    @State private var glowIntensity: CGFloat = 0.8
    @State private var colorRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.4),
                        Color(red: 0.08, green: 0.08, blue: 0.25),
                        Color(red: 0.02, green: 0.02, blue: 0.1)
                    ]),
                    center: .center,
                    startRadius: 50,
                    endRadius: 300
                )
            )
            .overlay(
                // Multiple border layers for enhanced glow
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.red.opacity(glowIntensity),
                                Color.orange.opacity(glowIntensity),
                                Color.yellow.opacity(glowIntensity),
                                Color.green.opacity(glowIntensity),
                                Color.blue.opacity(glowIntensity),
                                Color.purple.opacity(glowIntensity),
                                Color.red.opacity(glowIntensity)
                            ]),
                            center: .center,
                            angle: .degrees(colorRotation)
                        ), lineWidth: 8
                    )
                    .blur(radius: 3)
                    .scaleEffect(pulseScale)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.cyan.opacity(0.8),
                                Color.white.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 2
                    )
                    .blur(radius: 1)
            )
            .shadow(color: Color.cyan.opacity(glowIntensity * 0.8), radius: 30, x: 0, y: 0)
            .shadow(color: Color.blue.opacity(glowIntensity * 0.6), radius: 15, x: 0, y: 0)
            .shadow(color: Color.purple.opacity(glowIntensity * 0.4), radius: 8, x: 0, y: 0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever()) {
                    glowIntensity = glowIntensity == 0.8 ? 1.5 : 0.8
                }
                withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: false)) {
                    colorRotation = 360
                }
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.02
                }
            }
    }
}

struct AnimatedNeonCircle: View {
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.cyan.opacity(0.7), .blue.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 4, dash: [5, 5], dashPhase: dashPhase)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    dashPhase -= 20
                }
            }
    }
}

struct AnimatedPaddle: View {
    var position: CGPoint
    var color: Color
    @State private var glowSize: CGFloat = 15
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.2)]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 25
                )
            )
            .frame(width: 50, height: 50)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color, .white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 3)
                    .blur(radius: 1)
            )
            .shadow(color: color.opacity(0.8), radius: glowSize, x: 0, y: 0)
            .position(position)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                    glowSize = glowSize == 15 ? 25 : 15
                }
            }
    }
}

struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 15)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color.opacity(0.3) : Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? color : Color.gray, lineWidth: 3)
                                .blur(radius: 1)
                        )
                )
                .shadow(color: isSelected ? color.opacity(0.7) : .clear, radius: 10, x: 0, y: 0)
        }
    }
}

struct DifficultyButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? color.opacity(0.3) : Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isSelected ? color : Color.gray, lineWidth: 2)
                                .blur(radius: 1)
                        )
                )
                .shadow(color: isSelected ? color.opacity(0.7) : .clear, radius: 5, x: 0, y: 0)
        }
    }
}

struct PlayerScoreView: View {
    let score: Int
    let isPlayer1: Bool
    
    var body: some View {
        VStack {
            Text(isPlayer1 ? "PLAYER 1" : "PLAYER 2")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(isPlayer1 ? .green : .orange)
                .shadow(color: isPlayer1 ? .green : .orange, radius: 5, x: 0, y: 0)
            
            Text("\(score)")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: isPlayer1 ? .green : .orange, radius: 10, x: 0, y: 0)
        }
    }
}

struct NeonButtonLabel: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [color, .white]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 2)
                            .blur(radius: 1)
                    )
            )
            .shadow(color: color.opacity(0.7), radius: 10, x: 0, y: 0)
    }
}

struct GameOverView: View {
    @ObservedObject var game: AirHockeyGame
    @Binding var showMenu: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if game.winner == 1 {
                    Text(game.gameMode == .singlePlayer ? "VICTORY!" : game.gameMode == .network ? "YOU WIN!" : "PLAYER 1 WINS!")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .green, radius: 20, x: 0, y: 0)
                } else {
                    Text(game.gameMode == .singlePlayer ? "DEFEAT!" : game.gameMode == .network ? "YOU LOSE!" : "PLAYER 2 WINS!")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 20, x: 0, y: 0)
                }
                
                Text("Final Score: \(game.player1Score) - \(game.player2Score)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    Button(action: {
                        game.resetGame()
                    }) {
                        NeonButtonLabel(title: "Play Again", color: .blue)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showMenu = true
                        }
                    }) {
                        NeonButtonLabel(title: "Menu", color: .purple)
                    }
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 4)
                            .blur(radius: 2)
                    )
            )
            .padding(40)
            .shadow(color: .blue.opacity(0.5), radius: 30, x: 0, y: 0)
        }
    }
}

// MARK: - Enhanced Neon Menu Button
struct NeonMenuButton: View {
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let isPressed: Bool
    let action: () -> Void
    let onPressChanged: (Bool) -> Void
    
    @State private var glowPulse: CGFloat = 1.0
    @State private var colorShift: Double = 0
    
    var body: some View {
        let dynamicGlowColor = Color(hue: colorShift, saturation: 0.8, brightness: 1.0)
        
        Button(action: action) {
            Text(text)
                .font(.title2)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? selectedColor.opacity(0.6) : Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(isSelected ? dynamicGlowColor.opacity(0.3) : Color.clear)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? selectedColor : Color.gray, lineWidth: isSelected ? 4 : 2)
                        .blur(radius: isSelected ? 3 : 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isSelected ? dynamicGlowColor.opacity(0.8) : Color.clear, lineWidth: 2)
                                .blur(radius: 8)
                        )
                )
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .scaleEffect(isPressed ? 0.95 : (isSelected ? glowPulse : 1.0))
                .shadow(color: isSelected ? selectedColor.opacity(0.8) : .clear, radius: 15, x: 0, y: 0)
                .shadow(color: isSelected ? dynamicGlowColor.opacity(0.6) : .clear, radius: 25, x: 0, y: 0)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPressChanged(true) }
                .onEnded { _ in onPressChanged(false) }
        )
        .onAppear {
            if isSelected {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glowPulse = 1.05
                }
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    colorShift = 1.0
                }
            }
        }
    }
}

// Preview
struct NetworkedNeonAirHockey_Previews: PreviewProvider {
    static var previews: some View {
        NetworkedNeonAirHockey()
            .preferredColorScheme(.dark)
    }
}
