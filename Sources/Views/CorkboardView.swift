import SwiftUI

struct CorkboardView: View {
    let caseId: UUID
    @Binding var clues: [Clue]
    
    @State private var connections: [EvidenceConnection] = []
    @State private var selectedClueA: Clue?
    @State private var selectedClueB: Clue?
    @State private var showConnectionDialog = false
    @State private var connectionNoteText = ""
    
    // Store positions locally in UserDefaults for persistence
    @State private var positions: [UUID: CGPoint] = [:]
    
    var body: some View {
        ZStack {
            // Dark Corkboard Background Grid
            Canvas { context, size in
                // Draw background grid lines
                let gridSpacing: CGFloat = 40
                var x: CGFloat = 0
                while x < size.width {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: x, y: 0))
                            p.addLine(to: CGPoint(x: x, y: size.height))
                        },
                        with: .color(Color.green.opacity(0.04)),
                        lineWidth: 1
                    )
                    x += gridSpacing
                }
                var y: CGFloat = 0
                while y < size.height {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: size.width, y: y))
                        },
                        with: .color(Color.green.opacity(0.04)),
                        lineWidth: 1
                    )
                    y += gridSpacing
                }
                
                // Draw Red Strings connecting the clues
                for connection in connections {
                    if let posA = positions[connection.sourceClueId],
                       let posB = positions[connection.targetClueId] {
                        context.stroke(
                            Path { p in
                                p.move(to: posA)
                                p.addLine(to: posB)
                            },
                            with: .color(.red.opacity(0.8)),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [4, 2])
                        )
                    }
                }
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.07))
            
            // Connected lines details/notes overlay
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CORKBOARD PROTOCOL v1.0")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("SELECT TWO EVIDENCE NODES TO DRAW A LINKING HYPOTHESIS")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                    if selectedClueA != nil {
                        Button(action: {
                            selectedClueA = nil
                            selectedClueB = nil
                        }) {
                            Text("CLEAR SELECTION")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .border(Color.red.opacity(0.5))
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.6))
                
                Spacer()
                
                // Active Connections Inspector
                if !connections.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(connections) { conn in
                                let sourceName = clueTitle(for: conn.sourceClueId)
                                let targetName = clueTitle(for: conn.targetClueId)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("\(sourceName) 🔗 \(targetName)")
                                            .font(.system(.caption, design: .monospaced))
                                            .bold()
                                            .foregroundColor(.green)
                                        Spacer()
                                        Button(action: {
                                            deleteLink(conn)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .font(.system(size: 10))
                                        }
                                    }
                                    Text(conn.connectionNote)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(width: 250)
                                .background(Color.black.opacity(0.8))
                                .border(Color.green.opacity(0.4))
                            }
                        }
                        .padding()
                    }
                    .frame(height: 80)
                }
            }
            
            // Clue Cards Rendered on Coordinates
            let visibleClues = clues.filter { $0.discoveryStatus != "hidden" }
            ForEach(visibleClues) { clue in
                let pos = positions[clue.id] ?? defaultPosition(for: clue.id)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: clueIcon(for: clue.type))
                            .foregroundColor(selectionColor(for: clue))
                        Text(clue.title)
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Divider().background(Color.green.opacity(0.3))
                    Text(clue.transcript)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                .padding(8)
                .frame(width: 180, height: 90)
                .background(selectionBg(for: clue))
                .border(selectionColor(for: clue), width: selectedClueA?.id == clue.id || selectedClueB?.id == clue.id ? 2 : 1)
                .position(pos)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            positions[clue.id] = gesture.location
                            savePosition(clueId: clue.id, position: gesture.location)
                        }
                )
                .onTapGesture {
                    selectClue(clue)
                }
            }
        }
        .onAppear {
            loadPositions()
            loadConnections()
        }
        .sheet(isPresented: $showConnectionDialog) {
            VStack(spacing: 20) {
                Text("ESTABLISH EVIDENCE CONNECTION")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.green)
                
                if let clueA = selectedClueA, let clueB = selectedClueB {
                    Text("Linking:\n**\(clueA.title)**\nand\n**\(clueB.title)**")
                        .font(.system(.subheadline, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                
                TextField("Specify connecting theory/notes...", text: $connectionNoteText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.black)
                    .border(Color.green.opacity(0.5))
                    .foregroundColor(.green)
                
                HStack(spacing: 20) {
                    Button("CANCEL") {
                        showConnectionDialog = false
                    }
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.red)
                    
                    Button("DRAW STRING") {
                        createLink()
                    }
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.05, green: 0.05, blue: 0.07))
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Logic & Helper Methods
    
    private func clueIcon(for type: String) -> String {
        switch type {
        case "audio": return "waveform"
        case "document": return "doc.text.fill"
        case "image": return "photo"
        default: return "folder.fill"
        }
    }
    
    private func clueTitle(for id: UUID) -> String {
        return clues.first(where: { $0.id == id })?.title ?? "Unknown clue"
    }
    
    private func selectionColor(for clue: Clue) -> Color {
        if selectedClueA?.id == clue.id {
            return .yellow
        } else if selectedClueB?.id == clue.id {
            return .orange
        }
        return Color.green.opacity(0.8)
    }
    
    private func selectionBg(for clue: Clue) -> Color {
        if selectedClueA?.id == clue.id || selectedClueB?.id == clue.id {
            return Color.yellow.opacity(0.15)
        }
        return Color.black.opacity(0.8)
    }
    
    private func selectClue(_ clue: Clue) {
        if selectedClueA == nil {
            selectedClueA = clue
        } else if selectedClueA?.id == clue.id {
            selectedClueA = nil
        } else if selectedClueB == nil {
            selectedClueB = clue
            connectionNoteText = ""
            showConnectionDialog = true
        } else if selectedClueB?.id == clue.id {
            selectedClueB = nil
        }
    }
    
    private func createLink() {
        guard let clueA = selectedClueA, let clueB = selectedClueB else { return }
        
        let posA = positions[clueA.id] ?? defaultPosition(for: clueA.id)
        let posB = positions[clueB.id] ?? defaultPosition(for: clueB.id)
        
        let newConn = EvidenceConnection(
            id: UUID(),
            caseId: caseId,
            sourceClueId: clueA.id,
            targetClueId: clueB.id,
            connectionNote: connectionNoteText,
            xPosSource: Double(posA.x),
            yPosSource: Double(posA.y),
            xPosTarget: Double(posB.x),
            yPosTarget: Double(posB.y)
        )
        
        DatabaseManager.shared.saveConnection(newConn)
        loadConnections()
        
        selectedClueA = nil
        selectedClueB = nil
        showConnectionDialog = false
    }
    
    private func deleteLink(_ conn: EvidenceConnection) {
        DatabaseManager.shared.deleteConnection(id: conn.id)
        loadConnections()
    }
    
    private func loadConnections() {
        connections = DatabaseManager.shared.fetchConnections(caseId: caseId)
    }
    
    // Position Persistence Logic
    private func savePosition(clueId: UUID, position: CGPoint) {
        let xKey = "pos_\(clueId.uuidString)_x"
        let yKey = "pos_\(clueId.uuidString)_y"
        UserDefaults.standard.set(Double(position.x), forKey: xKey)
        UserDefaults.standard.set(Double(position.y), forKey: yKey)
    }
    
    private func defaultPosition(for id: UUID) -> CGPoint {
        // Distribute nicely along the canvas dynamically based on UUID hash
        let hash = abs(id.hashValue)
        let x = CGFloat(100 + (hash % 400))
        let y = CGFloat(150 + ((hash / 400) % 300))
        return CGPoint(x: x, y: y)
    }
    
    private func loadPositions() {
        var loaded: [UUID: CGPoint] = [:]
        for clue in clues {
            let xKey = "pos_\(clue.id.uuidString)_x"
            let yKey = "pos_\(clue.id.uuidString)_y"
            if let xVal = UserDefaults.standard.object(forKey: xKey) as? Double,
               let yVal = UserDefaults.standard.object(forKey: yKey) as? Double {
                loaded[clue.id] = CGPoint(x: xVal, y: yVal)
            } else {
                let def = defaultPosition(for: clue.id)
                loaded[clue.id] = def
                savePosition(clueId: clue.id, position: def)
            }
        }
        self.positions = loaded
    }
}
