import SwiftUI

struct InterrogationView: View {
    let caseId: UUID
    @Binding var suspects: [Suspect]
    
    @State private var selectedSuspect: Suspect?
    @State private var conversationLogs: [InterrogationLog] = []
    @State private var currentMessageText = ""
    @State private var isSending = false
    @State private var showSettings = false
    
    // Azure Credentials State
    @StateObject private var aiService = AzureOpenAIService.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Column: Suspect Selector
            VStack(alignment: .leading, spacing: 16) {
                Text("SUSPECT INDEX")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.gray)
                    .bold()
                    .padding(.horizontal)
                
                List(suspects, id: \.id) { suspect in
                    Button(action: {
                        selectSuspect(suspect)
                    }) {
                        HStack {
                            ZStack {
                                Color.black
                                Image(systemName: "person.crop.square")
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedSuspect?.id == suspect.id ? .green : .gray)
                            }
                            .frame(width: 40, height: 40)
                            .border(selectedSuspect?.id == suspect.id ? Color.green : Color.gray.opacity(0.4))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suspect.name)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(.white)
                                    .bold()
                                Text("LIMIT: \(suspect.questionsAsked)/\(suspect.interrogationLimit)")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(suspect.questionsAsked >= suspect.interrogationLimit ? .red : .yellow)
                            }
                        }
                    }
                    .listRowBackground(selectedSuspect?.id == suspect.id ? Color.green.opacity(0.1) : Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .frame(width: 250)
            .background(Color.black.opacity(0.3))
            
            Divider().background(Color.green.opacity(0.3))
            
            // Right Column: Interrogation Board
            if let suspect = selectedSuspect {
                if !aiService.isConfigured {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.red.opacity(0.8))
                            .padding()
                        Text("SECURE UPLINK INACTIVE")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.red)
                            .bold()
                        Text("SUSPECT INTERROGATION PORTAL IS LOCK-DISABLED UNTIL ENCRYPTED AZURE OPENAI SECURE COMM LINKS ARE CONFIGURED.")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text("CONFIGURE SECURE COMMS")
                            }
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(red: 0.0, green: 0.9, blue: 0.2))
                            .cornerRadius(4)
                        }
                        .padding(.top, 24)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // Header Status Info
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("INTERROGATING: \(suspect.name.uppercased())")
                                        .font(.system(.headline, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(aiService.isConfigured ? Color.green : Color.yellow)
                                            .frame(width: 8, height: 8)
                                        Text(aiService.isConfigured ? "ONLINE (AZURE GPT)" : "OFFLINE (MOCK SIMULATOR)")
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundColor(aiService.isConfigured ? .green : .yellow)
                                    }
                                }
                                
                                Spacer()
                                
                                // Remaining Questions Bar
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("INTERROGATION RATIO")
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(.gray)
                                    
                                    ProgressView(value: Double(suspect.questionsAsked), total: Double(suspect.interrogationLimit))
                                        .tint(suspect.questionsAsked >= suspect.interrogationLimit ? .red : .green)
                                        .frame(width: 120)
                                    
                                    Text("\(suspect.questionsAsked) / \(suspect.interrogationLimit) QUESTIONS")
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(suspect.questionsAsked >= suspect.interrogationLimit ? .red : .white)
                                }
                                
                                Button(action: {
                                    showSettings = true
                                }) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.green)
                                        .padding(.leading, 12)
                                }
                            }
                            .padding()
                            
                            Divider().background(Color.green.opacity(0.3))
                        }
                        .background(Color.black.opacity(0.5))
                        
                        // Messages Timeline
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(conversationLogs) { log in
                                        HStack {
                                            if log.sender == "detective" {
                                                Spacer()
                                                VStack(alignment: .trailing, spacing: 4) {
                                                    Text("DETECTIVE")
                                                        .font(.system(.caption2, design: .monospaced))
                                                        .foregroundColor(.green)
                                                        .bold()
                                                    Text(log.message)
                                                        .font(.system(.body, design: .monospaced))
                                                        .padding(12)
                                                        .background(Color.green.opacity(0.15))
                                                        .border(Color.green.opacity(0.5))
                                                        .foregroundColor(.white)
                                                }
                                                .frame(maxWidth: 500, alignment: .trailing)
                                            } else {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(suspect.name.uppercased())
                                                        .font(.system(.caption2, design: .monospaced))
                                                        .foregroundColor(.yellow)
                                                        .bold()
                                                    Text(log.message)
                                                        .font(.system(.body, design: .monospaced))
                                                        .padding(12)
                                                        .background(Color.black.opacity(0.4))
                                                        .border(Color.yellow.opacity(0.3))
                                                        .foregroundColor(.white.opacity(0.9))
                                                }
                                                .frame(maxWidth: 500, alignment: .leading)
                                                Spacer()
                                            }
                                        }
                                        .id(log.id)
                                    }
                                    
                                    if isSending {
                                        HStack {
                                            Text("SUSPECT IS TYPING...")
                                                .font(.system(.caption2, design: .monospaced))
                                                .foregroundColor(.yellow)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: conversationLogs.count) { _ in
                                if let lastLog = conversationLogs.last {
                                    withAnimation {
                                        proxy.scrollTo(lastLog.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        
                        Divider().background(Color.green.opacity(0.3))
                        
                        // Footer: Input box
                        HStack(spacing: 12) {
                            TextField(
                                suspect.questionsAsked >= suspect.interrogationLimit ? "LAW COUNSEL INTERVENED - LIMIT EXCEEDED" : "Confront suspect or request statements...",
                                text: $currentMessageText
                            )
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.black)
                            .border(Color.green.opacity(0.3))
                            .foregroundColor(.green)
                            .disabled(suspect.questionsAsked >= suspect.interrogationLimit || isSending)
                            
                            Button(action: {
                                sendMessage()
                            }) {
                                if isSending {
                                    ProgressView()
                                        .tint(.black)
                                        .frame(width: 80, height: 48)
                                        .background(Color.green)
                                } else {
                                    Text("SEND")
                                        .font(.system(.body, design: .monospaced))
                                        .bold()
                                        .foregroundColor(.black)
                                        .frame(width: 80, height: 48)
                                        .background(suspect.questionsAsked >= suspect.interrogationLimit ? Color.gray : Color.green)
                                }
                            }
                            .disabled(currentMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || suspect.questionsAsked >= suspect.interrogationLimit || isSending)
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                    }
                }
            } else {
                VStack {
                    Image(systemName: "hand.raised.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green.opacity(0.4))
                        .padding()
                    Text("NO ACTIVE PROFILE LOGGED")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.green.opacity(0.6))
                    Text("SELECT SUSPECT FROM INDEX FILE TO START INTERROGATION")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if let first = suspects.first {
                selectSuspect(first)
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("AZURE OPENAI CREDENTIALS")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ENDPOINT URL")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                        TextField("e.g. https://your-resource.openai.azure.com", text: $aiService.endpoint)
                            .font(.system(.body, design: .monospaced))
                            .padding(10)
                            .background(Color.black)
                            .border(Color.green.opacity(0.4))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("API KEY")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                        SecureField("Azure API Key", text: $aiService.apiKey)
                            .font(.system(.body, design: .monospaced))
                            .padding(10)
                            .background(Color.black)
                            .border(Color.green.opacity(0.4))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DEPLOYMENT NAME")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                        TextField("e.g. gpt-4o", text: $aiService.deploymentName)
                            .font(.system(.body, design: .monospaced))
                            .padding(10)
                            .background(Color.black)
                            .border(Color.green.opacity(0.4))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Button("SAVE PROTOCOL") {
                        showSettings = false
                    }
                    .font(.system(.body, design: .monospaced))
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.black)
                }
                .padding()
                .background(Color(red: 0.05, green: 0.05, blue: 0.07))
                .preferredColorScheme(.dark)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("DISMISS") {
                            showSettings = false
                        }
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func selectSuspect(_ suspect: Suspect) {
        selectedSuspect = suspect
        conversationLogs = DatabaseManager.shared.fetchInterrogationLogs(suspectId: suspect.id)
    }
    
    private func sendMessage() {
        guard let suspect = selectedSuspect else { return }
        let trimmedMessage = currentMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // 1. Save user query locally in SQLite
        let userLog = InterrogationLog(
            id: UUID(),
            suspectId: suspect.id,
            sender: "detective",
            message: trimmedMessage,
            timestamp: Date()
        )
        DatabaseManager.shared.saveInterrogationLog(userLog)
        DatabaseManager.shared.incrementQuestionsAsked(suspectId: suspect.id)
        
        // Update view bindings
        conversationLogs.append(userLog)
        currentMessageText = ""
        isSending = true
        
        // 2. Fetch answer from Azure OpenAI / Offline Simulator
        aiService.sendInterrogationMessage(suspect: suspect, history: conversationLogs, userMessage: trimmedMessage) { result in
            DispatchQueue.main.async {
                isSending = false
                switch result {
                case .success(let answer):
                    let responseLog = InterrogationLog(
                        id: UUID(),
                        suspectId: suspect.id,
                        sender: "suspect",
                        message: answer,
                        timestamp: Date()
                    )
                    DatabaseManager.shared.saveInterrogationLog(responseLog)
                    conversationLogs.append(responseLog)
                    
                case .failure(let error):
                    let errorLog = InterrogationLog(
                        id: UUID(),
                        suspectId: suspect.id,
                        sender: "suspect",
                        message: "[TRANSMISSION DEGRADED: Check settings. Error: \(error.localizedDescription)]",
                        timestamp: Date()
                    )
                    conversationLogs.append(errorLog)
                }
                
                // Refresh local status of suspects to update question ratios
                suspects = DatabaseManager.shared.fetchSuspects(caseId: caseId)
                if let updated = suspects.first(where: { $0.id == suspect.id }) {
                    selectedSuspect = updated
                }
            }
        }
    }
}
