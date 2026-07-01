import SwiftUI

struct CellTriangulationView: View {
    @State private var radiusA: Double = 50.0
    @State private var radiusB: Double = 150.0
    @State private var radiusC: Double = 80.0
    @State private var hasLocked = false
    @State private var showLockAlert = false
    
    @State private var logs: [String] = [
        ">> TRILATERATION INTERACTIVE ENGINE SYSTEM ACTIVE",
        ">> STANDBY: SECURING SATELLITE CONNECTION...",
        ">> CONNECTION SECURED. 3 TRANSCEIVER STATIONS DETECTION ON-LINE.",
        ">> REQUIRED COORD FOCUS: GEOLOCATING EMISSION SOURCE AT SECURE COORDINATE."
    ]
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Fixed targets
    let targetA: Double = 100.0
    let targetB: Double = 100.0
    let targetC: Double = 120.0
    
    var body: some View {
        ZStack {
            // Main background matching retro look
            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header block
                VStack(alignment: .leading, spacing: 4) {
                    Text("CELLULAR SIGNAL TRIANGULATION")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.green)
                        .bold()
                    Text("SECTOR GRID: 240x360 // MULTI-TOWER TRILATERATION INTERACTIVE MATRIX")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.6))
                .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                
                // Responsive content container
                if horizontalSizeClass == .compact {
                    ScrollView {
                        VStack(spacing: 20) {
                            mapPanel
                                .frame(height: 380)
                            
                            controlsPanel
                            
                            consolePanel
                        }
                    }
                } else {
                    HStack(alignment: .top, spacing: 20) {
                        // Left side: Triangulation coordinate map grid
                        mapPanel
                            .frame(maxWidth: .infinity)
                            .layoutPriority(1)
                        
                        // Right side: Sliders, console log feed
                        VStack(spacing: 20) {
                            controlsPanel
                            consolePanel
                        }
                        .frame(width: 380)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            
            // Retro Terminal Alert Modal
            if showLockAlert {
                lockAlertModal
            }
        }
        .onChange(of: radiusA) { newValue in checkLockCondition(tower: "ALPHA", val: newValue, target: targetA) }
        .onChange(of: radiusB) { newValue in checkLockCondition(tower: "BETA", val: newValue, target: targetB) }
        .onChange(of: radiusC) { newValue in checkLockCondition(tower: "GAMMA", val: newValue, target: targetC) }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "triangulation_completed") {
                radiusA = targetA
                radiusB = targetB
                radiusC = targetC
                hasLocked = true
            }
        }
    }
    
    // MARK: - Subpanels
    
    private var mapPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Text("REALTIME RADAR VECTOR GRID")
                    .font(.system(.caption, design: .monospaced))
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                if hasLocked {
                    Text("SYSTEM LOCKED")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.green)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .border(Color.green)
                } else {
                    Text("SCANNING FOR BEACON...")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.yellow)
                }
            }
            
            CoordinateMapView(
                radiusA: radiusA,
                radiusB: radiusB,
                radiusC: radiusC,
                isLocked: hasLocked
            )
            .border(hasLocked ? Color.green.opacity(0.6) : Color.green.opacity(0.3), width: 1.5)
            .cornerRadius(4)
        }
    }
    
    private var controlsPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TRANSCEIVER COARSE ADJUSTMENT")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.white)
                .bold()
                .padding(.bottom, 4)
            
            TriangulationSlider(
                name: "TOWER ALPHA (X:40, Y:120)",
                value: $radiusA,
                target: targetA,
                range: 10...200,
                activeColor: .green
            )
            
            TriangulationSlider(
                name: "TOWER BETA (X:200, Y:120)",
                value: $radiusB,
                target: targetB,
                range: 10...200,
                activeColor: .green
            )
            
            TriangulationSlider(
                name: "TOWER GAMMA (X:120, Y:300)",
                value: $radiusC,
                target: targetC,
                range: 10...200,
                activeColor: .green
            )
            
            // Manual Reset & Auto-Tune shortcuts
            HStack(spacing: 12) {
                Button(action: {
                    radiusA = 50.0
                    radiusB = 150.0
                    radiusC = 80.0
                    hasLocked = false
                    logs.append(">> MANUAL RE-CALIBRATION: Radii set back to default standby configurations.")
                }) {
                    Text("RESET PARAMS")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .border(Color.red.opacity(0.5))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        radiusA = targetA
                        radiusB = targetB
                        radiusC = targetC
                    }
                    logs.append(">> INITIATING AUTOTUNE SEQUENCE: Locking transceiver loops.")
                }) {
                    Text("AUTO-TUNE SIGNAL")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .border(Color.green.opacity(0.5))
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .border(Color.green.opacity(0.2))
    }
    
    private var consolePanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CONSOLE MONITOR FEED:")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.gray)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(0..<logs.count, id: \.self) { i in
                            Text(logs[i])
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(logs[i].contains("LOCKED") || logs[i].contains("CONVERGENCE") ? Color(red: 0.0, green: 0.9, blue: 0.2) : (logs[i].contains("LOST") ? .red : (logs[i].contains("WARNING") ? .yellow : .green.opacity(0.8))))
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(i)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 120)
                .background(Color.black)
                .border(hasLocked ? Color.green.opacity(0.5) : Color.green.opacity(0.2))
                .onChange(of: logs.count) { _ in
                    if !logs.isEmpty {
                        withAnimation {
                            proxy.scrollTo(logs.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var lockAlertModal: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Modal Header
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                    Text("DECRYPTED TRIANGULATION SECTOR DATA")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .bold()
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .border(Color.green.opacity(0.5), width: 1)
                
                // Modal Content
                VStack(alignment: .leading, spacing: 15) {
                    Text("TRIANGULATION LOCKED: Warehouse location origin resolved. coordinates mapped to Railway Junction adjacent to Cargo Hangar B.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .bold()
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider().background(Color.green.opacity(0.3))
                    
                    Text("SIGNAL INTEL CLASSIFIED VERIFYING:\nIntercept beacon matching: X: 120.00 / Y: 180.00\nPrecision variance rating: +/- 0.04m\nStructural identity: Industrial warehouse complex, rail logistics depot.\nStatus: Target site identified. Security operations dispatched.")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding()
                
                // Dismiss button
                Button(action: {
                    showLockAlert = false
                }) {
                    Text("ACKNOWLEDGE RESOLUTION")
                        .font(.system(.body, design: .monospaced))
                        .bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .cornerRadius(4)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 500)
            .background(Color(red: 0.05, green: 0.05, blue: 0.08))
            .border(Color.green, width: 2)
            .shadow(color: Color.green.opacity(0.3), radius: 15)
            .padding()
        }
    }
    
    // MARK: - Logic functions
    
    private func checkLockCondition(tower: String, val: Double, target: Double) {
        let diff = Int(val - target)
        if diff == 0 {
            logs.append(">> \(tower) TOWER LOCKED ON TARGET FREQUENCY: Radius calibrated to \(Int(val)) units.")
        } else if abs(diff) == 5 {
            logs.append(">> WARNING: \(tower) TOWER signal fluctuation within +/- 5 units. Keep adjusting.")
        }
        
        // Check if triple convergence is met
        if Int(radiusA) == Int(targetA) && Int(radiusB) == Int(targetB) && Int(radiusC) == Int(targetC) {
            if !hasLocked {
                hasLocked = true
                showLockAlert = true
                UserDefaults.standard.set(true, forKey: "triangulation_completed")
                logs.append("--------------------------------------------------")
                logs.append(">> [!!!] TRIPLE CONVERGENCE IDENTIFIED AT VECTOR (120, 180).")
                logs.append(">> TRIANGULATION LOCKED: Warehouse location origin resolved. coordinates mapped to Railway Junction adjacent to Cargo Hangar B.")
                logs.append("--------------------------------------------------")
            }
        } else {
            if hasLocked {
                hasLocked = false
                logs.append(">> SIGNAL CONVERGENCE LOST: Recalculating vector alignment parameters.")
            }
        }
    }
}

// MARK: - Custom Views for Coordinate Grid Map

struct CoordinateMapView: View {
    let radiusA: Double
    let radiusB: Double
    let radiusC: Double
    let isLocked: Bool
    
    // Fixed logical dimensions matching grid coordinate specs
    let logicalWidth: CGFloat = 240.0
    let logicalHeight: CGFloat = 360.0
    
    // Fixed tower points
    let towerAlpha = CGPoint(x: 40, y: 120)
    let towerBeta = CGPoint(x: 200, y: 120)
    let towerGamma = CGPoint(x: 120, y: 300)
    
    let targetPoint = CGPoint(x: 120, y: 180)
    
    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / logicalWidth
            let scaleY = geo.size.height / logicalHeight
            let scale = min(scaleX, scaleY)
            
            let gridWidth = logicalWidth * scale
            let gridHeight = logicalHeight * scale
            let offsetX = (geo.size.width - gridWidth) / 2
            let offsetY = (geo.size.height - gridHeight) / 2
            
            ZStack {
                // Map Background
                Color.black.opacity(0.8)
                
                // Grid ticks/lines
                GridLines(width: gridWidth, height: gridHeight, numLinesX: 6, numLinesY: 9)
                    .stroke(Color.green.opacity(0.15), lineWidth: 1)
                
                // Axis markers & numbers
                CoordinateLabels(width: gridWidth, height: gridHeight)
                
                // Distance Circles (plotted around each tower)
                // Alpha Circle
                Circle()
                    .stroke(Int(radiusA) == 100 ? Color.green : Color.yellow.opacity(0.4), lineWidth: Int(radiusA) == 100 ? 2 : 1)
                    .background(Circle().fill(Color.green.opacity(Int(radiusA) == 100 ? 0.08 : 0.03)))
                    .frame(width: CGFloat(radiusA * 2) * scale, height: CGFloat(radiusA * 2) * scale)
                    .position(CGPoint(
                        x: offsetX + towerAlpha.x * scale,
                        y: offsetY + towerAlpha.y * scale
                    ))
                
                // Beta Circle
                Circle()
                    .stroke(Int(radiusB) == 100 ? Color.green : Color.yellow.opacity(0.4), lineWidth: Int(radiusB) == 100 ? 2 : 1)
                    .background(Circle().fill(Color.green.opacity(Int(radiusB) == 100 ? 0.08 : 0.03)))
                    .frame(width: CGFloat(radiusB * 2) * scale, height: CGFloat(radiusB * 2) * scale)
                    .position(CGPoint(
                        x: offsetX + towerBeta.x * scale,
                        y: offsetY + towerBeta.y * scale
                    ))
                
                // Gamma Circle
                Circle()
                    .stroke(Int(radiusC) == 120 ? Color.green : Color.yellow.opacity(0.4), lineWidth: Int(radiusC) == 120 ? 2 : 1)
                    .background(Circle().fill(Color.green.opacity(Int(radiusC) == 120 ? 0.08 : 0.03)))
                    .frame(width: CGFloat(radiusC * 2) * scale, height: CGFloat(radiusC * 2) * scale)
                    .position(CGPoint(
                        x: offsetX + towerGamma.x * scale,
                        y: offsetY + towerGamma.y * scale
                    ))
                
                // Draw Tower Points
                TowerIndicator(name: "ALPHA", coordinate: towerAlpha, scale: scale, offsetX: offsetX, offsetY: offsetY, isLocked: Int(radiusA) == 100)
                TowerIndicator(name: "BETA", coordinate: towerBeta, scale: scale, offsetX: offsetX, offsetY: offsetY, isLocked: Int(radiusB) == 100)
                TowerIndicator(name: "GAMMA", coordinate: towerGamma, scale: scale, offsetX: offsetX, offsetY: offsetY, isLocked: Int(radiusC) == 120)
                
                // Intersection Point target reticle (glowing & locking when active)
                let mappedTarget = CGPoint(
                    x: offsetX + targetPoint.x * scale,
                    y: offsetY + targetPoint.y * scale
                )
                TargetIndicator(mappedPoint: mappedTarget, isLocked: isLocked)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Grid Overlay Helper Shape

struct GridLines: Shape {
    let width: CGFloat
    let height: CGFloat
    let numLinesX: Int
    let numLinesY: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let stepX = rect.width / CGFloat(numLinesX)
        for i in 0...numLinesX {
            let x = CGFloat(i) * stepX
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        let stepY = rect.height / CGFloat(numLinesY)
        for i in 0...numLinesY {
            let y = CGFloat(i) * stepY
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

// MARK: - Label Coordinates Overlay View

struct CoordinateLabels: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // X ticks (0, 40, 80, 120, 160, 200, 240)
            ForEach([0, 40, 80, 120, 160, 200, 240], id: \.self) { val in
                let pct = CGFloat(val) / 240.0
                let x = pct * width
                
                Text("\(val)")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.green.opacity(0.5))
                    .position(x: x, y: height - 12)
            }
            
            // Y ticks (0, 60, 120, 180, 240, 300, 360)
            ForEach([0, 60, 120, 180, 240, 300, 360], id: \.self) { val in
                let pct = CGFloat(val) / 360.0
                let y = pct * height
                
                Text("\(val)")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.green.opacity(0.5))
                    .position(x: 18, y: y)
            }
        }
    }
}

// MARK: - Tower Indicator Node

struct TowerIndicator: View {
    let name: String
    let coordinate: CGPoint
    let scale: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let isLocked: Bool
    
    @State private var pulse = false
    
    var body: some View {
        let x = offsetX + coordinate.x * scale
        let y = offsetY + coordinate.y * scale
        
        ZStack {
            // Wave pulse effect
            Circle()
                .stroke(isLocked ? Color.green : Color.yellow.opacity(0.5), lineWidth: 1)
                .scaleEffect(pulse ? 2.5 : 1.0)
                .opacity(pulse ? 0.0 : 0.7)
                .frame(width: 16, height: 16)
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        pulse = true
                    }
                }
            
            // Tower Dot
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 11))
                .foregroundColor(isLocked ? .green : .yellow)
                .padding(4)
                .background(Color.black.opacity(0.85))
                .clipShape(Circle())
                .overlay(Circle().stroke(isLocked ? Color.green : Color.yellow.opacity(0.5), lineWidth: 1))
            
            // Text banner
            Text("\(name)\n[\(Int(coordinate.x)),\(Int(coordinate.y))]")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(isLocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : .gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.8))
                .border(isLocked ? Color.green.opacity(0.4) : Color.gray.opacity(0.2), width: 1)
                .offset(y: -28)
        }
        .position(x: x, y: y)
    }
}

// MARK: - Center Target Indicator Crosshair

struct TargetIndicator: View {
    let mappedPoint: CGPoint
    let isLocked: Bool
    
    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Rotating outer ring
            Circle()
                .stroke(isLocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : Color.yellow.opacity(0.3), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 8]))
                .frame(width: 38, height: 38)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(Animation.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            // Reticle crosshair lines
            Path { path in
                // Horizontal crosshair
                path.move(to: CGPoint(x: -22, y: 0))
                path.addLine(to: CGPoint(x: -6, y: 0))
                path.move(to: CGPoint(x: 6, y: 0))
                path.addLine(to: CGPoint(x: 22, y: 0))
                
                // Vertical crosshair
                path.move(to: CGPoint(x: 0, y: -22))
                path.addLine(to: CGPoint(x: 0, y: -6))
                path.move(to: CGPoint(x: 0, y: 6))
                path.addLine(to: CGPoint(x: 0, y: 22))
            }
            .stroke(isLocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : Color.yellow.opacity(0.5), lineWidth: 1.2)
            
            // Center focal dot
            Circle()
                .fill(isLocked ? Color.green : Color.yellow)
                .frame(width: 6, height: 6)
                .scaleEffect(pulseScale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                        pulseScale = 1.7
                    }
                }
            
            // Reticle values tooltip
            VStack(spacing: 2) {
                Spacer().frame(height: 52)
                Text(isLocked ? "LOCK RESOLVED" : "VECTOR TARGET")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(isLocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : .yellow)
                Text("X: 120 / Y: 180")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(4)
            .background(Color.black.opacity(0.8))
            .cornerRadius(4)
        }
        .position(mappedPoint)
    }
}

// MARK: - Specialized Triangulation Slider Control

struct TriangulationSlider: View {
    let name: String
    @Binding var value: Double
    let target: Double
    let range: ClosedRange<Double>
    let activeColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                    .bold()
                
                Spacer()
                
                let diff = Int(value - target)
                if diff == 0 {
                    Text("LOCK")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(activeColor)
                } else {
                    Text("ERR: \(diff > 0 ? "+\(diff)" : "\(diff)")")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.yellow)
                }
            }
            
            HStack(spacing: 8) {
                // Precision adjustment buttons
                Button(action: {
                    if value > range.lowerBound {
                        value = max(range.lowerBound, value - 1)
                    }
                }) {
                    Image(systemName: "minus.square")
                        .font(.system(size: 18))
                        .foregroundColor(Int(value - target) == 0 ? activeColor : .green.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Slider
                Slider(value: $value, in: range, step: 1.0)
                    .tint(Int(value - target) == 0 ? activeColor : .yellow)
                
                Button(action: {
                    if value < range.upperBound {
                        value = min(range.upperBound, value + 1)
                    }
                }) {
                    Image(systemName: "plus.square")
                        .font(.system(size: 18))
                        .foregroundColor(Int(value - target) == 0 ? activeColor : .green.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Digital numeric indicator
                Text("\(Int(value)) / \(Int(target))")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Int(value - target) == 0 ? activeColor : .white)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.4))
            .border(Int(value - target) == 0 ? activeColor.opacity(0.4) : Color.gray.opacity(0.2), width: 1)
        }
    }
}
