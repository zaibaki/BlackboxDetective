import SwiftUI

struct DashboardView: View {
    let activeCase: Case
    @Binding var clues: [Clue]
    @Binding var suspects: [Suspect]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Top Terminal Banner
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("CASE DOSSIER:")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.gray)
                        Text(activeCase.title.uppercased())
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                    }
                    HStack {
                        Text("TARGET CODENAME:")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("\"\(activeCase.codename.uppercased())\"")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.yellow)
                            .bold()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.4))
                .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                
                // Case Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("OBJECTIVE SUMMARY")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .bold()
                    Text(activeCase.summary)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(4)
                
                HStack(alignment: .top, spacing: 20) {
                    // SUSPECTS SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SUBJECT PROFILES")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 4)
                        
                        ForEach(suspects) { suspect in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    // Simulated Photo
                                    ZStack {
                                        Color.black
                                        Image(systemName: suspect.isGuilty ? "person.crop.circle.badge.questionmark" : "person.crop.circle")
                                            .font(.system(size: 32))
                                            .foregroundColor(.green.opacity(0.8))
                                    }
                                    .frame(width: 60, height: 60)
                                    .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suspect.name)
                                            .font(.system(.headline, design: .monospaced))
                                            .foregroundColor(.white)
                                        Text("STATUS: SUSPECT")
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.yellow)
                                    }
                                }
                                
                                Divider().background(Color.green.opacity(0.3))
                                
                                Text("**ALIBI:** \(suspect.alibi)")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("**NOTES:** \(suspect.profileNotes)")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .overlay(Rectangle().stroke(Color.green.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // EVIDENCE LOCKER SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("EVIDENCE LOGS")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 4)
                        
                        ForEach(clues) { clue in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: clueIcon(for: clue.type))
                                        .foregroundColor(clueColor(for: clue.discoveryStatus))
                                    Text(clue.title)
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Text(clue.discoveryStatus.uppercased())
                                        .font(.system(.caption2, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(clueColor(for: clue.discoveryStatus).opacity(0.2))
                                        .foregroundColor(clueColor(for: clue.discoveryStatus))
                                }
                                
                                if clue.discoveryStatus == "hidden" {
                                    Button(action: {
                                        revealClue(clue)
                                    }) {
                                        HStack {
                                            Image(systemName: "lock.open.fill")
                                            Text("DECRYPT DATA")
                                                .font(.system(.caption, design: .monospaced))
                                        }
                                        .foregroundColor(.black)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color(red: 0.0, green: 0.9, blue: 0.2))
                                        .cornerRadius(2)
                                    }
                                } else {
                                    Text(clue.transcript)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineSpacing(2)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .overlay(Rectangle().stroke(Color.green.opacity(clue.discoveryStatus == "hidden" ? 0.1 : 0.3), lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
    }
    
    private func clueIcon(for type: String) -> String {
        switch type {
        case "audio": return "waveform"
        case "document": return "doc.text.fill"
        case "image": return "photo"
        default: return "folder.fill"
        }
    }
    
    private func clueColor(for status: String) -> Color {
        switch status {
        case "hidden": return .red
        case "unlocked": return .yellow
        case "analyzed": return Color(red: 0.0, green: 0.9, blue: 0.2)
        default: return .gray
        }
    }
    
    private func revealClue(_ clue: Clue) {
        DatabaseManager.shared.updateClueDiscoveryStatus(clueId: clue.id, status: "unlocked")
        // Refresh local bindings
        if let caseId = clues.first?.caseId {
            clues = DatabaseManager.shared.fetchClues(caseId: caseId)
        }
    }
}
