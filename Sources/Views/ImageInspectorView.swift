import SwiftUI

struct ImageInspectorView: View {
    @Binding var clues: [Clue]
    
    // Canvas dimensions
    let canvasWidth: CGFloat = 360
    let canvasHeight: CGFloat = 260
    
    // Drag state
    @State private var lensPosition = CGPoint(x: 100, y: 100)
    @State private var isDragging = false
    
    // Decryption / Database state
    @State private var isTracerDetected = false
    @State private var isDecrypted = false
    @State private var terminalLogs: [String] = [
        ">> SPECTRAL ANALYSIS WORKSTATION ONLINE",
        ">> SYSTEM SOURCE: lab_blueprint.bin (ISOTOPE SIGNATURE NEEDED)",
        ">> AWAITING DRAG-SCAN TARGETING OVER SCHEMATIC GRID..."
    ]
    
    // Target coordinate bounds
    // Coordinates (X: 140...160, Y: 110...130)
    let targetXRange = 140.0...160.0
    let targetYRange = 110.0...130.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header CRT Board Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("IMAGE SPECTRAL INSPECTOR // RETICLE SCANNER")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .bold()
                    Spacer()
                    Text("ONLINE")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.0, green: 0.9, blue: 0.2))
                }
                Text("INTEGRATED FLUID SYSTEM MAP - SCHEMATIC ANALYSIS PROT: TX-409")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .border(Color.green.opacity(0.3))
            
            HStack(alignment: .top, spacing: 20) {
                // Left Column: The Schematic Canvas & Magnifier
                VStack(spacing: 12) {
                    Text("DRAFT: CODENAME 'ALCHEMIST' GLASS RIG BLUEPRINT")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.green.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack {
                        // Base (faint/dimmed) blueprint schematic
                        BlueprintView()
                            .frame(width: canvasWidth, height: canvasHeight)
                            .opacity(0.55)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
                            )
                        
                        // Draggable Magnifying Lens Overlay (Real-time optical zoom)
                        MagnifiedLensOverlay(
                            lensPosition: lensPosition,
                            lensDiameter: 90,
                            scale: 2.0,
                            canvasWidth: canvasWidth,
                            canvasHeight: canvasHeight
                        )
                        .allowsHitTesting(false) // Let the background container handle the drag gesture
                    }
                    .frame(width: canvasWidth, height: canvasHeight)
                    .background(Color.black)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                let newX = max(0, min(value.location.x, canvasWidth))
                                let newY = max(0, min(value.location.y, canvasHeight))
                                lensPosition = CGPoint(x: newX, y: newY)
                                isDragging = true
                                updateDetectionStatus()
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                    
                    // Real-Time reticle readout
                    HStack {
                        Text("RETICLE COORD: [ X: \(String(format: "%03.1f", lensPosition.x)) | Y: \(String(format: "%03.1f", lensPosition.y)) ]")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.green.opacity(0.8))
                        
                        Spacer()
                        
                        if isDragging {
                            Text("SCANNING...")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.yellow)
                        } else {
                            Text("LENS READY")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .border(Color.green.opacity(0.3))
                
                // Right Column: Scanner Status, DB Controller & Output logs
                VStack(spacing: 16) {
                    // Alert Banner Block
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DETECTION STATUS")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                            .bold()
                        
                        if isTracerDetected {
                            VStack(alignment: .center, spacing: 4) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("ISOTOPE TRACER LOCATED: TX-409-R")
                                        .bold()
                                }
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.yellow)
                                .cornerRadius(2)
                            }
                        } else {
                            Text("SEARCHING SCAN FOR RADIO-ISOTOPES...")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.green.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .border(Color.green.opacity(0.2))
                    
                    // Decrypt Action Trigger
                    VStack(alignment: .leading, spacing: 10) {
                        Text("METADATA DATABASE SYNC")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        if isDecrypted {
                            VStack(alignment: .center, spacing: 6) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("BLUEPRINT CLUE DECRYPTED")
                                }
                                .font(.system(.caption, design: .monospaced))
                                .bold()
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.0, green: 0.9, blue: 0.2))
                                
                                Text("Isotope records synchronized in local SQLite database dossier.")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            Button(action: {
                                executeDecryption()
                            }) {
                                HStack {
                                    Image(systemName: "opticaldisk")
                                    Text("LOG METADATA & DECRYPT CLUE")
                                        .font(.system(.body, design: .monospaced))
                                        .bold()
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isTracerDetected ? Color(red: 0.0, green: 0.9, blue: 0.2) : Color.gray.opacity(0.4))
                                .cornerRadius(4)
                            }
                            .disabled(!isTracerDetected)
                            
                            if !isTracerDetected {
                                Text("*Reticle must be aligned over isotope coordinates (X:140...160, Y:110...130) to retrieve metadata.")
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .border(Color.green.opacity(0.2))
                    
                    // Terminal logs panel
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DIAGNOSTIC LOG MONITOR")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(0..<terminalLogs.count, id: \.self) { idx in
                                        Text(terminalLogs[idx])
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(logColor(for: terminalLogs[idx]))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .id(idx)
                                    }
                                }
                            }
                            .onChange(of: terminalLogs.count) { _ in
                                withAnimation {
                                    proxy.scrollTo(terminalLogs.count - 1, anchor: .bottom)
                                }
                            }
                        }
                        .frame(height: 90)
                        .padding(6)
                        .background(Color.black)
                        .border(Color.green.opacity(0.3))
                    }
                }
            }
            .padding()
            .background(Color(red: 0.04, green: 0.04, blue: 0.06))
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea())
        .onAppear {
            checkDatabaseClueStatus()
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateDetectionStatus() {
        let inXRange = targetXRange.contains(lensPosition.x)
        let inYRange = targetYRange.contains(lensPosition.y)
        
        let found = inXRange && inYRange
        if found && !isTracerDetected {
            isTracerDetected = true
            terminalLogs.append(">> COORD LOCK: [ X: \(String(format: "%03.1f", lensPosition.x)) | Y: \(String(format: "%03.1f", lensPosition.y)) ]")
            terminalLogs.append(">> WARNING: HIGH EXCITATION TRACER DETECTED IN CELL JUNCTION.")
            terminalLogs.append(">> SIGNATURE MATCHES KNOWN ISOTOPE REGISTER: TX-409-R.")
            terminalLogs.append(">> STANDING BY FOR METADATA LOGGING STROBE...")
        } else if !found && isTracerDetected {
            isTracerDetected = false
            terminalLogs.append(">> Reticle lock lost. Continuing scan cycle...")
        }
    }
    
    private func executeDecryption() {
        guard isTracerDetected else { return }
        
        terminalLogs.append(">> INITIALIZING BLUEPRINT DATA DESERIALIZATION...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            terminalLogs.append(">> EXPORTING ISOTOPE ID: TX-409-R...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // Update GRDB Local Database
                let clueId = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
                DatabaseManager.shared.updateClueDiscoveryStatus(clueId: clueId, status: "analyzed")
                
                // Refresh bindings
                if let caseId = clues.first?.caseId {
                    clues = DatabaseManager.shared.fetchClues(caseId: caseId)
                }
                
                isDecrypted = true
                terminalLogs.append(">> DB TRANSACTION COMMIT: CLUE [33333333] UPDATE discoveryStatus TO 'analyzed'")
                terminalLogs.append(">> ENCRYPTED LAB BLUEPRINT FULLY DECRYPTED.")
                terminalLogs.append(">> ANALYSIS PROTOCOLS TERMINATED. SUCCESS.")
            }
        }
    }
    
    private func checkDatabaseClueStatus() {
        let db = DatabaseManager.shared
        let cases = db.fetchCases()
        if let first = cases.first {
            let initialClues = db.fetchClues(caseId: first.id)
            if let clue = initialClues.first(where: { $0.id == UUID(uuidString: "33333333-3333-3333-3333-333333333333")! }) {
                if clue.discoveryStatus == "analyzed" {
                    isDecrypted = true
                    terminalLogs.append(">> INITIAL CHECK: Lab Blueprint was already analyzed.")
                }
            }
        }
    }
    
    private func logColor(for log: String) -> Color {
        if log.contains("WARNING") || log.contains("LOCK") { return .yellow }
        if log.contains("SUCCESS") || log.contains("DECRYPTED") { return Color(red: 0.0, green: 0.9, blue: 0.2) }
        if log.contains("TRANSACTION") { return .orange }
        return .green.opacity(0.7)
    }
}

// MARK: - Vector Blueprint View

struct BlueprintView: View {
    var body: some View {
        ZStack {
            // Blueprint Background grid
            Canvas { context, size in
                let spacing: CGFloat = 20
                for x in stride(from: CGFloat(0), to: size.width, by: spacing) {
                    context.stroke(Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                    }, with: .color(Color.green.opacity(0.08)), lineWidth: 0.5)
                }
                for y in stride(from: CGFloat(0), to: size.height, by: spacing) {
                    context.stroke(Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }, with: .color(Color.green.opacity(0.08)), lineWidth: 0.5)
                }
            }
            .background(Color(red: 0.02, green: 0.04, blue: 0.02)) // dark cyber-green background
            
            // Distillation Rig Vector Drawing
            Group {
                // 1. Support stand
                // Base
                Path { p in
                    p.move(to: CGPoint(x: 50, y: 220))
                    p.addLine(to: CGPoint(x: 310, y: 220))
                }
                .stroke(Color.green.opacity(0.5), lineWidth: 3)
                
                // Vertical rods
                Path { p in
                    p.move(to: CGPoint(x: 90, y: 220))
                    p.addLine(to: CGPoint(x: 90, y: 50))
                    
                    p.move(to: CGPoint(x: 270, y: 220))
                    p.addLine(to: CGPoint(x: 270, y: 70))
                }
                .stroke(Color.green.opacity(0.4), lineWidth: 2)
                
                // Clamps
                Path { p in
                    // Left clamp
                    p.move(to: CGPoint(x: 90, y: 120))
                    p.addLine(to: CGPoint(x: 110, y: 120))
                    // Right clamp
                    p.move(to: CGPoint(x: 270, y: 140))
                    p.addLine(to: CGPoint(x: 250, y: 140))
                }
                .stroke(Color.green.opacity(0.6), lineWidth: 2)
                
                // 2. Heating Mantle & Boiling Flask (Left side)
                // Mantle (Base heater)
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.green.opacity(0.6), lineWidth: 2)
                    .background(Color.green.opacity(0.1))
                    .frame(width: 60, height: 30)
                    .position(x: 120, y: 195)
                
                // Boiling Flask
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .background(Circle().fill(Color.green.opacity(0.15)))
                    .frame(width: 50, height: 50)
                    .position(x: 120, y: 160)
                
                // Flask neck
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 14, height: 25)
                    .position(x: 120, y: 128)
                
                // 3. Fractionating / Condenser Column (Diagonal tube from top of boiling flask to receiving flask)
                // Let's make a condenser going from top-left (120, 115) to bottom-right (230, 150)
                // Outer jacket
                Path { p in
                    p.move(to: CGPoint(x: 120, y: 115))
                    p.addLine(to: CGPoint(x: 220, y: 145))
                }
                .stroke(Color.green, lineWidth: 8)
                .opacity(0.3)
                
                // Outer jacket line details
                Path { p in
                    p.move(to: CGPoint(x: 120, y: 111))
                    p.addLine(to: CGPoint(x: 220, y: 141))
                    p.move(to: CGPoint(x: 120, y: 119))
                    p.addLine(to: CGPoint(x: 220, y: 149))
                }
                .stroke(Color.green, lineWidth: 1.5)
                
                // Inner cooling tube / coil
                Path { p in
                    p.move(to: CGPoint(x: 120, y: 115))
                    p.addLine(to: CGPoint(x: 220, y: 145))
                }
                .stroke(Color.green, lineWidth: 1.5)
                
                // Cooling water inlets/outlets
                Path { p in
                    // Inlet (lower)
                    p.move(to: CGPoint(x: 205, y: 140))
                    p.addLine(to: CGPoint(x: 205, y: 155))
                    // Outlet (upper)
                    p.move(to: CGPoint(x: 135, y: 120))
                    p.addLine(to: CGPoint(x: 135, y: 105))
                }
                .stroke(Color.green, lineWidth: 1.5)
                
                // 4. Thermometer and top adapter
                Path { p in
                    // Adapter body
                    p.move(to: CGPoint(x: 120, y: 115))
                    p.addLine(to: CGPoint(x: 120, y: 80))
                    // Thermometer bulb/stem inside
                    p.move(to: CGPoint(x: 120, y: 95))
                    p.addLine(to: CGPoint(x: 120, y: 70))
                }
                .stroke(Color.green, lineWidth: 1.5)
                
                // Thermometer head
                Circle()
                    .stroke(Color.green, lineWidth: 1.5)
                    .frame(width: 6, height: 6)
                    .position(x: 120, y: 67)
                
                // 5. Receiving side (Right)
                // Adapter tube leading down
                Path { p in
                    p.move(to: CGPoint(x: 220, y: 145))
                    p.addLine(to: CGPoint(x: 250, y: 155))
                    p.addLine(to: CGPoint(x: 250, y: 175))
                }
                .stroke(Color.green, lineWidth: 1.5)
                
                // Receiving Flask
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .background(Circle().fill(Color.green.opacity(0.1)))
                    .frame(width: 40, height: 40)
                    .position(x: 250, y: 190)
                
                // 6. Tracer Location (Isotope annotation)
                // Drawn at coordinates X: 150, Y: 120. (Which falls in range X:140...160, Y:110...130)
                // We'll place the tracer text or a small glowing radiation symbol / chemical node here.
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    
                    Circle()
                        .stroke(Color.green, lineWidth: 1.0)
                        .frame(width: 14, height: 14)
                        .scaleEffect(1.2)
                    
                    Text("TX-409-R")
                        .font(.system(size: 6, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .offset(y: -10)
                }
                .position(x: 150, y: 120)
                
                // Other decorative blueprint annotations
                Text("VANCE DISTILLATION APPARATUS v2.1")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.green.opacity(0.6))
                    .position(x: 170, y: 25)
                
                Text("SPEC: TRACER DETECTION REGION")
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.green.opacity(0.4))
                    .position(x: 180, y: 35)
                
                Text("HEATING ELEMENT: 180°C")
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.green.opacity(0.4))
                    .position(x: 75, y: 235)
                
                Text("COLLECTOR CAP: 500ML")
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.green.opacity(0.4))
                    .position(x: 275, y: 235)
            }
        }
    }
}

// MARK: - Magnified Lens Overlay

struct MagnifiedLensOverlay: View {
    let lensPosition: CGPoint
    let lensDiameter: CGFloat
    let scale: CGFloat
    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
    
    var body: some View {
        BlueprintView()
            .frame(width: canvasWidth, height: canvasHeight)
            .scaleEffect(scale, anchor: .topLeading)
            .offset(
                x: lensDiameter / 2 - lensPosition.x * scale,
                y: lensDiameter / 2 - lensPosition.y * scale
            )
            .frame(width: lensDiameter, height: lensDiameter, alignment: .topLeading)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .shadow(color: Color.green.opacity(0.6), radius: 4)
            )
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear, Color.green.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                ZStack {
                    Path { p in
                        p.move(to: CGPoint(x: lensDiameter/2, y: 4))
                        p.addLine(to: CGPoint(x: lensDiameter/2, y: 15))
                        
                        p.move(to: CGPoint(x: lensDiameter/2, y: lensDiameter - 15))
                        p.addLine(to: CGPoint(x: lensDiameter/2, y: lensDiameter - 4))
                        
                        p.move(to: CGPoint(x: 4, y: lensDiameter/2))
                        p.addLine(to: CGPoint(x: 15, y: lensDiameter/2))
                        
                        p.move(to: CGPoint(x: lensDiameter - 15, y: lensDiameter/2))
                        p.addLine(to: CGPoint(x: lensDiameter - 4, y: lensDiameter/2))
                    }
                    .stroke(Color.green.opacity(0.8), lineWidth: 1)
                    
                    Circle()
                        .stroke(Color.green.opacity(0.6), lineWidth: 1)
                        .frame(width: 12, height: 12)
                }
            )
            .position(lensPosition)
    }
}
