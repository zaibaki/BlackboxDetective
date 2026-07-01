import SwiftUI

public struct NotepadView: View {
    let caseId: UUID
    
    @State private var note: InvestigatorNote?
    @State private var contentText: String = ""
    @State private var lastSaved: Date?
    @State private var savingStatus: String = "ONLINE"
    
    // Reference database items
    @State private var clues: [Clue] = []
    @State private var suspects: [Suspect] = []
    
    @State private var notificationText = ""
    @State private var showNotification = false
    @State private var saveTask: Task<Void, Never>? = nil
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    public init(caseId: UUID) {
        self.caseId = caseId
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // Main Notepad Area
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.green)
                        Text("INVESTIGATOR NOTEPAD CONSOLE")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.green)
                            .bold()
                        Spacer()
                        Text("SECURE OS v4.09")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green.opacity(0.6))
                    }
                    Text("ACTIVE CASE ID: \(caseId.uuidString.prefix(8).uppercased())... // RETRO WRITE BUFFER")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                
                // Stats Header bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OPERATOR: AGENT_DETECTION_CORE")
                        Text("STORAGE PIPELINE: SQLITE.investigatorNote")
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("BYTES WRITTEN: \(contentText.utf8.count)")
                        Text("LINE COUNT: \(contentText.components(separatedBy: .newlines).count)")
                    }
                }
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.green.opacity(0.7))
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.2))
                .border(Color.green.opacity(0.15), width: 1)
                
                // Notepad Editor
                ZStack(alignment: .topTrailing) {
                    TextEditor(text: $contentText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                        .scrollContentBackground(.hidden)
                        .background(Color.black.opacity(0.4))
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.green.opacity(0.1), radius: 10)
                        .onChange(of: contentText) { newValue in
                            triggerAutosave(newValue)
                        }
                    
                    if showNotification {
                        Text(notificationText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .border(Color.white.opacity(0.8))
                            .padding()
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .padding()
                
                // Bottom Console status bar
                HStack(spacing: 12) {
                    Text("SYSTEM STATUS:")
                    Text(savingStatus)
                        .foregroundColor(savingStatus == "SAVING..." ? .yellow : .green)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(savingStatus == "SAVING..." ? Color.yellow.opacity(0.1) : Color.green.opacity(0.1))
                        .border(savingStatus == "SAVING..." ? Color.yellow.opacity(0.3) : Color.green.opacity(0.3))
                    
                    Spacer()
                    
                    if let lastSaved = lastSaved {
                        Text("DB BLOCK WRITTEN: \(dateFormatter.string(from: lastSaved))")
                            .foregroundColor(.gray)
                    } else {
                        Text("NO BACKUPS WRITTEN")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        triggerManualSave()
                    }) {
                        Text("FORCE SYNC")
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green)
                    }
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                .background(Color.black.opacity(0.6))
                .border(Color.green.opacity(0.3), width: 1)
            }
            
            Divider().background(Color.green.opacity(0.3))
            
            // Side Reference Intel Panel
            VStack(alignment: .leading, spacing: 16) {
                Text("CASE REFERENCE INTEL")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.white)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                Text("CLICK CHIPS TO APPEND TO NOTES")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Suspects list
                        VStack(alignment: .leading, spacing: 8) {
                            Text("--- SUSPECTS ---")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.green.opacity(0.8))
                                .bold()
                            
                            if suspects.isEmpty {
                                Text("NO SUSPECT DATA")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(suspects) { suspect in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suspect.name)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.white)
                                            .bold()
                                        
                                        HStack(spacing: 8) {
                                            Button(action: {
                                                appendReferenceText("Suspect: \(suspect.name)")
                                            }) {
                                                Text("[NAME]")
                                                    .font(.system(.caption2, design: .monospaced))
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .border(Color.green.opacity(0.4))
                                            }
                                            
                                            Button(action: {
                                                appendReferenceText("Suspect Profile (\(suspect.name)): \(suspect.profileNotes)")
                                            }) {
                                                Text("[PROFILE]")
                                                    .font(.system(.caption2, design: .monospaced))
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .border(Color.green.opacity(0.4))
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.green.opacity(0.05))
                                    .border(Color.green.opacity(0.2))
                                }
                            }
                        }
                        
                        // Clues list
                        VStack(alignment: .leading, spacing: 8) {
                            Text("--- EVIDENCE CLUES ---")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.green.opacity(0.8))
                                .bold()
                            
                            let unlockedClues = clues.filter { $0.discoveryStatus != "hidden" }
                            if unlockedClues.isEmpty {
                                Text("NO UNLOCKED CLUES")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(unlockedClues) { clue in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(clue.title)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.white)
                                            .bold()
                                        
                                        HStack(spacing: 8) {
                                            Button(action: {
                                                appendReferenceText("Evidence Clue: \(clue.title)")
                                            }) {
                                                Text("[TITLE]")
                                                    .font(.system(.caption2, design: .monospaced))
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .border(Color.green.opacity(0.4))
                                            }
                                            
                                            Button(action: {
                                                appendReferenceText("Clue Transcript (\(clue.title)): \(clue.transcript)")
                                            }) {
                                                Text("[TRANSCRIPT]")
                                                    .font(.system(.caption2, design: .monospaced))
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .border(Color.green.opacity(0.4))
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.green.opacity(0.05))
                                    .border(Color.green.opacity(0.2))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(width: 300)
            .background(Color.black.opacity(0.3))
        }
        .onAppear {
            loadNote()
        }
        .onDisappear {
            // Save one last time on view disappear to ensure no text is lost
            saveNoteContent(contentText)
        }
    }
    
    private func loadNote() {
        if let fetched = DatabaseManager.shared.fetchNote(caseId: caseId) {
            self.note = fetched
            self.contentText = fetched.content
            self.lastSaved = fetched.updatedAt
            showNotification(text: "BUFFER LOADED: \(fetched.content.utf8.count) BYTES")
        } else {
            let newNote = InvestigatorNote(id: UUID(), caseId: caseId, content: "", updatedAt: Date())
            self.note = newNote
            self.contentText = ""
            DatabaseManager.shared.saveNote(newNote)
            self.lastSaved = newNote.updatedAt
            showNotification(text: "NEW MEMORY BUFFER SEEDED")
        }
        
        // Fetch Intel references
        self.clues = DatabaseManager.shared.fetchClues(caseId: caseId)
        self.suspects = DatabaseManager.shared.fetchSuspects(caseId: caseId)
    }
    
    private func triggerAutosave(_ text: String) {
        savingStatus = "SAVING..."
        saveTask?.cancel()
        saveTask = Task {
            do {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec debounce
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    saveNoteContent(text)
                }
            } catch {}
        }
    }
    
    private func saveNoteContent(_ text: String) {
        guard var currentNote = note else { return }
        currentNote.content = text
        currentNote.updatedAt = Date()
        DatabaseManager.shared.saveNote(currentNote)
        self.note = currentNote
        self.lastSaved = currentNote.updatedAt
        savingStatus = "SYNCHRONIZED"
    }
    
    private func triggerManualSave() {
        saveTask?.cancel()
        saveNoteContent(contentText)
        showNotification(text: "SQLITE BUFFER SYNCHRONIZED")
    }
    
    private func appendReferenceText(_ text: String) {
        let prefix = contentText.isEmpty ? "" : "\n\n"
        contentText += "\(prefix)>> \(text)"
        showNotification(text: "INTEL INSERTED")
    }
    
    private func showNotification(text: String) {
        notificationText = text
        withAnimation {
            showNotification = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showNotification = false
            }
        }
    }
}
