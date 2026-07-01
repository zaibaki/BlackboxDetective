import SwiftUI

struct AccusationView: View {
    let caseId: UUID
    let onCaseSolved: () -> Void
    
    @State private var suspects: [Suspect] = []
    @State private var clues: [Clue] = []
    
    // Selection States
    @State private var selectedSuspect: Suspect?
    @State private var selectedClue: Clue?
    @State private var selectedLocation: String?
    
    // Game/Progress States
    @State private var threatLevel = 0
    @State private var showSuccessBanner = false
    @State private var showFailureDialog = false
    @State private var failureMessage = ""
    
    // Retro Terminal Static Locations list
    let locations = [
        "Terminal 4 Warehouse",
        "Rostova Art Gallery",
        "Apex Labs Facility",
        "Cargo Train Depot",
        "University Chemistry Department",
        "Warehouse 4",
        "Border Checkpoint",
        "Rostova Art Logistics"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Protocol Banner
                VStack(alignment: .leading, spacing: 4) {
                    Text("CRIMINAL ACCUSATION PORTAL")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .bold()
                    Text("SUBMIT FORMAL INDICTMENT CHARGES // QUANTUM ENCRYPTED TRANSMISSION")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.6))
                .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                
                // Threat Level Monitor Indicator
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("HOSTILE INTERCEPT THREAT LEVEL:")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                            .bold()
                        Spacer()
                        Text(threatLevelStatusText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(threatLevelColor)
                            .bold()
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Rectangle()
                                .fill(index <= threatLevel ? Color.red : Color.green.opacity(0.2))
                                .frame(height: 12)
                                .overlay(
                                    Rectangle()
                                        .stroke(index <= threatLevel ? Color.red.opacity(0.8) : Color.green.opacity(0.4), lineWidth: 1)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("WARNING: Five failed submission attempts will trigger security lockout protocols.")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .border(threatLevel > 0 ? Color.red.opacity(0.5) : Color.green.opacity(0.2))
                
                if showSuccessBanner {
                    // Success Banner
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🟢 INDICTMENT CONFIRMED & TRANSMITTED")
                                    .font(.system(.headline, design: .monospaced))
                                    .foregroundColor(.green)
                                    .bold()
                                Text("The incriminating evidence points directly to the suspect at the verified location. Warrant issued successfully.")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        Divider().background(Color.green.opacity(0.5))
                        
                        Button(action: {
                            onCaseSolved()
                        }) {
                            Text("PROCEED TO NEXT INTEL DOSSIER")
                                .font(.system(.subheadline, design: .monospaced))
                                .bold()
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 24)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .border(Color.green, lineWidth: 2)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Form Fields Section
                HStack(alignment: .top, spacing: 16) {
                    
                    // Column 1: Guilty Suspect Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. GUILTY SUSPECT")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.white)
                            .bold()
                        
                        ForEach(suspects) { suspect in
                            Button(action: {
                                if !showSuccessBanner {
                                    selectedSuspect = suspect
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Circle()
                                        .stroke(selectedSuspect?.id == suspect.id ? Color.green : Color.gray, lineWidth: 2)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Circle()
                                                .fill(selectedSuspect?.id == suspect.id ? Color.green : Color.clear)
                                                .frame(width: 8, height: 8)
                                        )
                                    
                                    Text(suspect.name)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(selectedSuspect?.id == suspect.id ? .green : .white.opacity(0.8))
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(selectedSuspect?.id == suspect.id ? Color.green.opacity(0.15) : Color.black.opacity(0.2))
                                .border(selectedSuspect?.id == suspect.id ? Color.green : Color.green.opacity(0.2))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    // Column 2: Incriminating Clue Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. INCRIMINATING CLUE")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.white)
                            .bold()
                        
                        ForEach(clues) { clue in
                            Button(action: {
                                if !showSuccessBanner {
                                    selectedClue = clue
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Circle()
                                        .stroke(selectedClue?.id == clue.id ? Color.green : Color.gray, lineWidth: 2)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Circle()
                                                .fill(selectedClue?.id == clue.id ? Color.green : Color.clear)
                                                .frame(width: 8, height: 8)
                                        )
                                    
                                    Text(clue.title)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(selectedClue?.id == clue.id ? .green : .white.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(selectedClue?.id == clue.id ? Color.green.opacity(0.15) : Color.black.opacity(0.2))
                                .border(selectedClue?.id == clue.id ? Color.green : Color.green.opacity(0.2))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    // Column 3: Location Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("3. CRIME LOCATION")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.white)
                            .bold()
                        
                        ForEach(locations, id: \.self) { location in
                            Button(action: {
                                if !showSuccessBanner {
                                    selectedLocation = location
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Circle()
                                        .stroke(selectedLocation == location ? Color.green : Color.gray, lineWidth: 2)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Circle()
                                                .fill(selectedLocation == location ? Color.green : Color.clear)
                                                .frame(width: 8, height: 8)
                                        )
                                    
                                    Text(location)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(selectedLocation == location ? .green : .white.opacity(0.8))
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(selectedLocation == location ? Color.green.opacity(0.15) : Color.black.opacity(0.2))
                                .border(selectedLocation == location ? Color.green : Color.green.opacity(0.2))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                
                // Submit Button / Execution Console
                VStack(spacing: 12) {
                    Button(action: {
                        submitCharges()
                    }) {
                        Text("SUBMIT CHARGES")
                            .font(.system(.title3, design: .monospaced))
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isSubmitEnabled ? Color.green : Color.green.opacity(0.3))
                            .cornerRadius(4)
                            .shadow(color: isSubmitEnabled ? .green.opacity(0.5) : .clear, radius: 8)
                    }
                    .disabled(!isSubmitEnabled || showSuccessBanner)
                    
                    if showFailureDialog {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("❌ TRANSMISSION ERROR: DATA HASH MISMATCH")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.red)
                                .bold()
                            Text(failureMessage)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.15))
                        .border(Color.red)
                        .transition(.opacity)
                    }
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
    }
    
    private var isSubmitEnabled: Bool {
        selectedSuspect != nil && selectedClue != nil && selectedLocation != nil
    }
    
    private var threatLevelStatusText: String {
        switch threatLevel {
        case 0: return "SECURE // UNDETECTED"
        case 1: return "WARNING // MINOR SIGNALS DETECTED"
        case 2: return "ALERT // ACTIVE TRACE DETECTED"
        case 3: return "DANGER // ENEMY SYSTEMS LOCKING ON"
        case 4: return "CRITICAL // FIREWALL COMPROMISE IMMINENT"
        default: return "COMPROMISED // SECURITY COUNTERMEASURES LAUNCHED"
        }
    }
    
    private var threatLevelColor: Color {
        switch threatLevel {
        case 0: return .green
        case 1, 2: return .yellow
        default: return .red
        }
    }
    
    private func loadData() {
        let db = DatabaseManager.shared
        suspects = db.fetchSuspects(caseId: caseId)
        clues = db.fetchClues(caseId: caseId)
    }
    
    private func submitCharges() {
        guard let suspect = selectedSuspect,
              let clue = selectedClue,
              let location = selectedLocation else {
            return
        }
        
        let correctSuspect = "Dr. Aris Vance"
        let correctClue = "Burn Phone Ledger Record"
        let correctLocation = "Terminal 4 Warehouse"
        
        withAnimation {
            if suspect.name == correctSuspect && clue.title == correctClue && location == correctLocation {
                // Correct!
                showSuccessBanner = true
                showFailureDialog = false
                DatabaseManager.shared.solveCase(caseId: caseId)
            } else {
                // Incorrect!
                threatLevel += 1
                failureMessage = "SUBMITTED ACCUSATION DATA SUMMARY MATCH FAILURE. Indicted suspect: '\(suspect.name)'. Claimed Incriminating Evidence: '\(clue.title)'. Suspected Location: '\(location)'. Core mainframe did not accept indictment verification hash. System tracer has traced this node's footprint. Hostile Threat level is now \(threatLevel)/5."
                showFailureDialog = true
            }
        }
    }
}
