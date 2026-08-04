import SwiftUI

public struct PixelMascotView: View {
    public var usagePercentage: Double
    public var isError: Bool
    public var size: CGFloat
    
    @State private var animFrame: Int = 0
    @State private var isBlinking: Bool = false
    @State private var zzzOffset: CGFloat = 0
    @State private var glowPulse: Bool = false
    
    private var emotion: MascotEmotion {
        MascotEmotion.emotion(for: usagePercentage, isError: isError)
    }
    
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    private let blinkTimer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()
    
    public init(usagePercentage: Double = 0.20, isError: Bool = false, size: CGFloat = 120) {
        self.usagePercentage = usagePercentage
        self.isError = isError
        self.size = size
    }
    
    // ───────────────────────────────────────────────────────────────
    // Detailed Pixel Matrix for Blue Cloud Mascot (16 cols x 16 rows)
    // 0 = Transparent
    // 1 = Black Outline (#0B0E14)
    // 2 = Blue Cloud Outer Fill (#426EEB)
    // 3 = Blue Cloud Shading (#3156C8)
    // 4 = Blue Body Base (#3D64DE)
    // 5 = Screen Dark Fill (#181C2E)
    // 6 = Screen Cyan Text ">"  (#4CE3FB)
    // 7 = Screen Cyan Text "_" / Eye Line (#4CE3FB)
    // 8 = Chest Cyan Text "> _" (#E0F8FF)
    // 9 = Blue Feet (#2746AD)
    // ───────────────────────────────────────────────────────────────
    
    private var gridAwakeA: [[Int]] {
        let isClosed = isBlinking
        let eyeVal = isClosed ? 1 : 7
        return [
            [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0], // Row 0: Cloud top outline
            [0,0,1,1,2,2,2,2,2,2,2,2,1,1,0,0], // Row 1: Cloud top fill
            [0,1,2,2,2,2,2,2,2,2,2,2,2,2,1,0], // Row 2
            [1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1], // Row 3: Screen top border
            [1,2,1,5,5,5,5,5,5,5,5,5,5,1,2,1], // Row 4: Screen interior
            [1,2,1,5,6,6,5,5,5,eyeVal,eyeVal,5,5,1,2,1], // Row 5: > and _ (or eye)
            [1,2,1,5,5,6,5,5,5,5,5,5,5,1,2,1], // Row 6: Chevron tip
            [1,2,1,5,5,5,5,5,5,5,5,5,5,1,2,1], // Row 7: Screen bottom
            [1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1], // Row 8: Screen bottom outline
            [0,1,2,2,2,2,2,2,2,2,2,2,2,2,1,0], // Row 9: Neck / upper body
            [0,1,1,4,4,8,8,8,8,8,4,4,1,1,0,0], // Row 10: Chest with > - symbol
            [0,1,4,4,4,4,4,4,4,4,4,4,4,1,0,0], // Row 11: Belly
            [0,0,1,4,4,4,4,4,4,4,4,4,1,0,0,0], // Row 12: Hip
            [0,0,1,9,9,1,0,0,1,9,9,1,0,0,0,0], // Row 13: Legs
            [0,0,1,9,9,1,0,0,1,9,9,1,0,0,0,0], // Row 14: Feet
            [0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0], // Row 15: Feet bottom
        ]
    }
    
    private var gridAwakeB: [[Int]] {
        // Frame B (Walking/Breathing leg shift)
        var grid = gridAwakeA
        grid[13] = [0,0,1,9,9,1,0,0,0,1,9,9,1,0,0,0]
        grid[14] = [0,0,1,9,9,1,0,0,0,1,9,9,1,0,0,0]
        return grid
    }
    
    private var gridSleeping: [[Int]] {
        return [
            [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
            [0,0,1,1,2,2,2,2,2,2,2,2,1,1,0,0],
            [0,1,2,2,2,2,2,2,2,2,2,2,2,2,1,0],
            [1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1],
            [1,2,1,5,5,5,5,5,5,5,5,5,5,1,2,1],
            [1,2,1,5,7,7,5,5,5,7,7,5,5,1,2,1], // Sleeping eyes (curved lines v v)
            [1,2,1,5,5,5,5,5,5,5,5,5,5,1,2,1],
            [1,2,1,5,5,5,5,5,5,5,5,5,5,1,2,1],
            [1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1],
            [0,1,2,2,2,2,2,2,2,2,2,2,2,2,1,0],
            [0,1,1,4,4,8,8,8,8,8,4,4,1,1,0,0],
            [0,1,4,4,4,4,4,4,4,4,4,4,4,1,0,0],
            [0,0,1,4,4,4,4,4,4,4,4,4,1,0,0,0],
            [0,0,1,9,9,1,0,0,1,9,9,1,0,0,0,0],
            [0,0,1,9,9,1,0,0,1,9,9,1,0,0,0,0],
            [0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0],
        ]
    }
    
    public var body: some View {
        let cols = 16
        let rows = 16
        let pixelSize = size / CGFloat(cols)
        let currentGrid = (emotion == .sleeping) ? gridSleeping : ((animFrame % 2 == 0) ? gridAwakeA : gridAwakeB)
        
        ZStack {
            // Ambient Glow Aura
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            emotion.themeColor.opacity(glowPulse ? 0.45 : 0.25),
                            emotion.themeColor.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: size * 0.15,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }
            
            // Canvas Vector Pixel Art Engine
            Canvas { context, canvasSize in
                for r in 0..<rows {
                    for c in 0..<cols {
                        let val = currentGrid[r][c]
                        if val > 0 {
                            let rect = CGRect(
                                x: CGFloat(c) * pixelSize,
                                y: CGFloat(r) * pixelSize,
                                width: pixelSize + 0.4,
                                height: pixelSize + 0.4
                            )
                            
                            let pixelColor: Color
                            switch val {
                            case 1: // Black Outline
                                pixelColor = Color(red: 0.05, green: 0.07, blue: 0.12)
                            case 2: // Blue Cloud Outer Fill
                                pixelColor = (emotion == .sleeping) ? Color(red: 0.35, green: 0.45, blue: 0.70) : Color(red: 0.26, green: 0.43, blue: 0.92)
                            case 3: // Blue Cloud Shadow
                                pixelColor = Color(red: 0.19, green: 0.33, blue: 0.78)
                            case 4: // Body Base Blue
                                pixelColor = Color(red: 0.24, green: 0.39, blue: 0.87)
                            case 5: // Screen Dark Fill
                                pixelColor = Color(red: 0.09, green: 0.11, blue: 0.18)
                            case 6, 7: // Screen Cyan Text / Eyes
                                pixelColor = (emotion == .sweating) ? Color(red: 1.0, green: 0.8, blue: 0.2) : Color(red: 0.30, green: 0.89, blue: 0.98)
                            case 8: // Chest Symbol
                                pixelColor = Color(red: 0.88, green: 0.97, blue: 1.0)
                            case 9: // Feet
                                pixelColor = Color(red: 0.15, green: 0.27, blue: 0.68)
                            default:
                                pixelColor = .clear
                            }
                            
                            context.fill(Path(rect), with: .color(pixelColor))
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .offset(y: (animFrame % 2 == 0 && emotion != .sleeping) ? -2 : 2)
            
            // Sweat Drop overlay for High Usage (> 80%)
            if emotion == .sweating {
                Circle()
                    .fill(Color(red: 0.3, green: 0.6, blue: 1.0))
                    .frame(width: pixelSize * 2.0, height: pixelSize * 2.0)
                    .offset(x: size * 0.38, y: -size * 0.10 + (animFrame % 2 == 0 ? 0 : 4))
            }
            
            // Sleeping Zzz
            if emotion == .sleeping {
                VStack(spacing: 2) {
                    Text("Z")
                        .font(.system(size: size * 0.16, weight: .black, design: .monospaced))
                        .foregroundColor(emotion.themeColor)
                        .offset(x: 12 + zzzOffset, y: -zzzOffset)
                    Text("z")
                        .font(.system(size: size * 0.11, weight: .bold, design: .monospaced))
                        .foregroundColor(emotion.themeColor.opacity(0.7))
                        .offset(x: 6 + zzzOffset / 2, y: -zzzOffset / 2)
                }
                .offset(x: size * 0.35, y: -size * 0.32)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        zzzOffset = 10
                    }
                }
            }
            
            // Exhausted "!" warning (> 95%)
            if emotion == .exhausted {
                Text("!")
                    .font(.system(size: size * 0.18, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                    .offset(x: 0, y: -size * 0.48)
                    .opacity(animFrame % 2 == 0 ? 1.0 : 0.4)
            }
        }
        .onReceive(timer) { _ in
            if emotion != .sleeping {
                animFrame += 1
            }
        }
        .onReceive(blinkTimer) { _ in
            if emotion != .sleeping {
                isBlinking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isBlinking = false
                }
            }
        }
    }
}
