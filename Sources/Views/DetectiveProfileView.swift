import SwiftUI

public struct DetectiveProfileView: View {
    // Persistent customizable profile fields
    @AppStorage("detective_name") private var investigatorName: String = "AGENT K. VANCE"
    @AppStorage("detective_rank") private var investigatorRank: String = "SENIOR SPECIAL AGENT"
    @AppStorage("detective_badge_id") private var investigatorBadgeID: String = "BX-99420"
    
    // Milestones completion states
    @State private var isDecryptionSpecialistUnlocked = false
    @State private var isAcousticExpertUnlocked = false
    @State private var isMasterTrackerUnlocked = false
    @State private var isCaseClosedUnlocked = false
    
    // Scan animation for the badge photo area
    @State private var scanLineOffset: CGFloat = -40
    @State private var biometricPulse = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerPanel
                badgeCard
                achievementsTitleSection
                achievementsGrid
            }
            .padding()
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea())
        .onAppear {
            updateAchievements()
        }
    }
    
    // MARK: - Subviews
    
    private var headerPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("DETECTIVE PROFILE & CRITERIA ACHIEVEMENTS")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                .bold()
            Text("AGENCY DOSSIER REGISTRATION // SECURITY CREDENTIALS STATUS")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.6))
        .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
    }
    
    private var badgeCard: some View {
        VStack(spacing: 0) {
            // Badge Header
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                
                Text("FEDERAL AGENCY OF COGNITIVE SECURITY")
                    .font(.system(.caption, design: .monospaced))
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("CLASSIFIED STATUS: ACTIVE")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.15))
                    .border(Color.green.opacity(0.5), width: 1)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .border(Color.green.opacity(0.3), width: 1)
            
            // Badge Inner Body
            HStack(alignment: .top, spacing: 20) {
                // Left: Biometric Avatar Scanner
                biometricScanner
                
                // Right: Interactive Credentials Text Fields
                credentialsFields
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            // Barcode Footer
            barcodeFooter
        }
        .border(Color.green.opacity(0.5), width: 1.5)
        .shadow(color: Color.green.opacity(0.08), radius: 10)
    }
    
    private var biometricScanner: some View {
        VStack(spacing: 8) {
            ZStack {
                Color.black
                
                // Glowing background grid
                BiometricGridView()
                
                // Agent avatar drawing
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2).opacity(biometricPulse ? 0.35 : 0.25))
                    .padding(8)
                    .scaleEffect(biometricPulse ? 1.02 : 0.98)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: biometricPulse)
                
                // Biometric circular HUD
                Circle()
                    .stroke(Color.green.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(width: 70, height: 70)
                
                // Animated Scanline
                BiometricScanlineView(scanLineOffset: scanLineOffset)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                            scanLineOffset = 40
                        }
                        biometricPulse = true
                    }
            }
            .frame(width: 90, height: 95)
            .border(Color.green.opacity(0.5), width: 1)
            
            Text("BIOMETRIC SCAN OK")
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                .bold()
        }
    }
    
    private var credentialsFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            CredentialRow(label: "CODENAME:", placeholder: "Investigator Name", text: $investigatorName)
            CredentialRow(label: "RANK:", placeholder: "Investigator Rank", text: $investigatorRank)
            CredentialRow(label: "BADGE ID:", placeholder: "Badge ID", text: $investigatorBadgeID)
            
            HStack {
                Text("CLEARANCE:")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                Text("LEVEL 4 OMNISCIENT")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.yellow)
                Spacer()
                Text("SEC: BLACKBOX")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
    }
    
    private var barcodeFooter: some View {
        VStack(spacing: 2) {
            Divider().background(Color.green.opacity(0.3))
            HStack(spacing: 1.5) {
                ForEach(0..<45, id: \.self) { i in
                    Rectangle()
                        .fill(Color.green.opacity(0.6))
                        .frame(width: CGFloat([1, 2, 3, 1.5][i % 4]), height: 18)
                }
                Spacer()
                Text("SYS REG: \(investigatorBadgeID.uppercased())")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.green.opacity(0.6))
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .background(Color.black.opacity(0.5))
    }
    
    private var achievementsTitleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("INVESTIGATIVE ACHIEVEMENT MILESTONES")
                    .font(.system(.subheadline, design: .monospaced))
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                
                let totalUnlocked = (isDecryptionSpecialistUnlocked ? 1 : 0) +
                                    (isAcousticExpertUnlocked ? 1 : 0) +
                                    (isMasterTrackerUnlocked ? 1 : 0) +
                                    (isCaseClosedUnlocked ? 1 : 0)
                Text("PROGRESS: \(totalUnlocked) / 4 UNLOCKED")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(totalUnlocked == 4 ? Color.green : .yellow)
                    .bold()
            }
            Divider().background(Color.green.opacity(0.3))
        }
        .padding(.top, 10)
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
            // 1. Decryption Specialist
            AchievementCard(
                title: "DECRYPTION SPECIALIST",
                description: "Decrypt the burn phone ledger record database parameters.",
                condition: "Unlocked when ledger is decrypted in DB",
                isUnlocked: isDecryptionSpecialistUnlocked,
                iconName: "key.fill"
            )
            
            // 2. Acoustic Expert
            AchievementCard(
                title: "ACOUSTIC EXPERT",
                description: "Filter background environmental noise and isolate voiceprint tape forensics.",
                condition: "Unlocked when signal is solved",
                isUnlocked: isAcousticExpertUnlocked,
                iconName: "waveform.path.badge.plus"
            )
            
            // 3. Master Tracker
            AchievementCard(
                title: "MASTER TRACKER",
                description: "Align radio tower convergence loops to triangulate warehouse origin vector.",
                condition: "Unlocked when triangulation completed",
                isUnlocked: isMasterTrackerUnlocked,
                iconName: "location.magnifyingglass"
            )
            
            // 4. Case Closed
            AchievementCard(
                title: "CASE CLOSED",
                description: "Indict Vance with matching clue coordinates and close 'The Chemist's Recipe'.",
                condition: "Unlocked when case is solved in DB",
                isUnlocked: isCaseClosedUnlocked,
                iconName: "shield.checkered"
            )
        }
    }
    
    private func updateAchievements() {
        let db = DatabaseManager.shared
        
        // 1. Decryption Specialist
        // The ledger clue ID is hardcoded in the database seeding: "44444444-4444-4444-4444-444444444444"
        let ledgerClueIdStr = "44444444-4444-4444-4444-444444444444"
        if let dbQueue = db.dbQueue {
            let isDecrypted = (try? dbQueue.read { sqliteDb in
                let sql = "SELECT discoveryStatus FROM clue WHERE id = ?"
                if let status = try String.fetchOne(sqliteDb, sql: sql, arguments: [ledgerClueIdStr]) {
                    return status == "unlocked" || status == "analyzed"
                }
                return false
            }) ?? false
            isDecryptionSpecialistUnlocked = isDecrypted
        } else {
            isDecryptionSpecialistUnlocked = false
        }
        
        // 2. Acoustic Expert
        isAcousticExpertUnlocked = UserDefaults.standard.bool(forKey: "signal_solved")
        
        // 3. Master Tracker
        isMasterTrackerUnlocked = UserDefaults.standard.bool(forKey: "triangulation_completed")
        
        // 4. Case Closed
        let cases = db.fetchCases()
        isCaseClosedUnlocked = cases.contains { $0.status == "solved" }
    }
}

// MARK: - Achievement Card Component

struct AchievementCard: View {
    let title: String
    let description: String
    let condition: String
    let isUnlocked: Bool
    let iconName: String
    
    private var badgeColor: Color {
        isUnlocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : Color.red
    }
    
    private var badgeShadowColor: Color {
        isUnlocked ? Color.green.opacity(0.8) : Color.clear
    }
    
    private var imageSystemName: String {
        isUnlocked ? iconName : "lock.fill"
    }
    
    private var cardBorderColor: Color {
        isUnlocked ? Color.green.opacity(0.4) : Color.red.opacity(0.2)
    }
    
    private var imageBorderColor: Color {
        isUnlocked ? Color.green.opacity(0.6) : Color.red.opacity(0.3)
    }
    
    private var imageBackgroundColor: Color {
        isUnlocked ? Color.green.opacity(0.05) : Color.red.opacity(0.02)
    }
    
    private var cardBackground: Color {
        Color.black
    }
    
    private var cardOpacity: Double {
        isUnlocked ? 0.3 : 0.15
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                // Glow badge icon
                ZStack {
                    Color.black
                    Image(systemName: imageSystemName)
                        .font(.system(size: 20))
                        .foregroundColor(badgeColor)
                        .shadow(color: badgeShadowColor, radius: 4)
                }
                .frame(width: 44, height: 44)
                .border(imageBorderColor, width: 1.5)
                .background(imageBackgroundColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.caption, design: .monospaced))
                        .bold()
                        .foregroundColor(isUnlocked ? .white : .gray)
                    
                    Text(isUnlocked ? "[ UNLOCKED ]" : "[ LOCKED ]")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(isUnlocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : .red)
                }
                Spacer()
            }
            
            Divider().background(isUnlocked ? Color.green.opacity(0.2) : Color.red.opacity(0.1))
            
            Text(description)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(isUnlocked ? .white.opacity(0.85) : .gray)
                .lineLimit(3)
                .frame(height: 40, alignment: .topLeading)
            
            Text("REQUIREMENT: \(condition)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(isUnlocked ? .green.opacity(0.6) : .gray.opacity(0.6))
        }
        .padding()
        .background(cardBackground.opacity(cardOpacity))
        .border(cardBorderColor, width: 1)
        .overlay(
            VStack {
                if isUnlocked {
                    Rectangle()
                        .fill(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .frame(height: 2)
                }
                Spacer()
            }
        )
    }
}

// MARK: - Biometric Scanner Helper Views

struct BiometricGridView: View {
    var body: some View {
        Canvas { context, size in
            let lines = 5
            let stepX = size.width / CGFloat(lines)
            let stepY = size.height / CGFloat(lines)
            for i in 0...lines {
                let x = CGFloat(i) * stepX
                var pX = Path()
                pX.move(to: CGPoint(x: x, y: 0))
                pX.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(pX, with: .color(Color.green.opacity(0.08)), lineWidth: 1)
                
                let y = CGFloat(i) * stepY
                var pY = Path()
                pY.move(to: CGPoint(x: 0, y: y))
                pY.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(pY, with: .color(Color.green.opacity(0.08)), lineWidth: 1)
            }
        }
    }
}

struct BiometricScanlineView: View {
    let scanLineOffset: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, Color.green.opacity(0.5), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 6)
            .offset(y: scanLineOffset)
    }
}

struct CredentialRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 70, alignment: .leading)
            
            TextField(placeholder, text: $text)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.white)
                .bold()
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.5))
                .border(Color.green.opacity(0.4), width: 1)
        }
    }
}

