import SwiftUI

struct HackingMinigameView: View {
    @State private var attempts = 4
    @State private var terminalLogs: [String] = [
        ">> SECURE DECRYPTION CODES DETECTED",
        ">> WARNING: LOCKOUT PROTOCOLS ENABLED (4 ATTEMPTS)",
        ">> SELECT CODE PHRASE TO INITIATE HANDSHAKE..."
    ]
    @State private var isUnlocked = false
    
    let words = [
        "CHEMIST",
        "ALCHEMIST",
        "CATALYST",
        "REACTION",
        "ANTIDOTE",
        "DISTILL",
        "ISOTOPE",
        "SPECTRUM",
        "DOSSIER",
        "MURDER"
    ]
    
    let correctWord = "ALCHEMIST"
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Info
            VStack(alignment: .leading, spacing: 4) {
                Text("DECRYPTION TERMINAL")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.green)
                    .bold()
                Text("TARGET CLUE: BURN PHONE LEDGER RECORD // MEMORY CORE CORRUPT")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.6))
            .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
            
            HStack(alignment: .top, spacing: 20) {
                // Words Column
                VStack(alignment: .leading, spacing: 10) {
                    Text("MEMORY GRID ADDRESSES")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.bottom, 6)
                    
                    ForEach(words, id: \.self) { word in
                        Button(action: {
                            submitGuess(word)
                        }) {
                            Text("0x\(String(word.hashValue, radix: 16).prefix(4).uppercased())  \(word)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(isUnlocked ? .gray : .green)
                        }
                        .disabled(isUnlocked || attempts <= 0)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .border(Color.green.opacity(0.3))
                
                // Logging feedback column
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("DECRYPTION MONITOR")
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                        Text("ATTEMPTS REMAINING: \(attempts)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(attempts <= 1 ? .red : .yellow)
                            .bold()
                    }
                    
                    Divider().background(Color.green.opacity(0.3))
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(terminalLogs, id: \.self) { log in
                                Text(log)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(logColor(for: log))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    if attempts <= 0 && !isUnlocked {
                        Button(action: {
                            resetDecrypter()
                        }) {
                            Text("RESET CODES")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                        }
                    }
                    
                    if isUnlocked {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("CLUE UNLOCKED IN DOSSIER")
                        }
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.9, blue: 0.2))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .border(Color.green.opacity(0.3))
            }
            .frame(maxHeight: 400)
            
            Spacer()
        }
        .padding()
        .onAppear {
            checkIfAlreadyUnlocked()
        }
    }
    
    private func logColor(for log: String) -> Color {
        if log.contains("ACCESS GRANTED") { return Color(red: 0.0, green: 0.9, blue: 0.2) }
        if log.contains("ACCESS DENIED") || log.contains("WARNING") { return .red }
        if log.contains("Likeness") { return .yellow }
        return .green
    }
    
    private func submitGuess(_ word: String) {
        if word == correctWord {
            isUnlocked = true
            terminalLogs.append(">> TESTING: \(word)...")
            terminalLogs.append(">> ACCESS GRANTED. SIGNAL CORE DECRYPTED.")
            terminalLogs.append(">> DB TRANSACTION: UPDATING BURN PHONE LEDGER CLUE STATUS.")
            
            // Decrypt clue in local database!
            let clueId = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
            DatabaseManager.shared.updateClueDiscoveryStatus(clueId: clueId, status: "unlocked")
        } else {
            attempts -= 1
            terminalLogs.append(">> TESTING: \(word)...")
            let likeness = calculateLikeness(guess: word, target: correctWord)
            terminalLogs.append(">> ACCESS DENIED. LIKENESS = \(likeness)/\(correctWord.count)")
            
            if attempts <= 0 {
                terminalLogs.append(">> ERROR: RECOVERY CODE CORES BLOCKED. INITIATE HARDWARE COLD RESET.")
            }
        }
    }
    
    private func calculateLikeness(guess: String, target: String) -> Int {
        var count = 0
        let guessChars = Array(guess)
        let targetChars = Array(target)
        for i in 0..<min(guessChars.count, targetChars.count) {
            if guessChars[i] == targetChars[i] {
                count += 1
            }
        }
        return count
    }
    
    private func resetDecrypter() {
        attempts = 4
        isUnlocked = false
        terminalLogs = [
            ">> SECURE DECRYPTION CODES RE-DETECTED",
            ">> MONITOR INITIALIZED (4 ATTEMPTS RESET)",
            ">> SELECT CODE PHRASE TO INITIATE HANDSHAKE..."
        ]
    }
    
    private func checkIfAlreadyUnlocked() {
        let db = DatabaseManager.shared
        let cases = db.fetchCases()
        if let first = cases.first {
            let clues = db.fetchClues(caseId: first.id)
            if let ledger = clues.first(where: { $0.id == UUID(uuidString: "44444444-4444-4444-4444-444444444444")! }) {
                if ledger.discoveryStatus == "unlocked" || ledger.discoveryStatus == "analyzed" {
                    isUnlocked = true
                    terminalLogs.append(">> STATUS INQUIRY: Core decrypt code was previously executed.")
                }
            }
        }
    }
}
