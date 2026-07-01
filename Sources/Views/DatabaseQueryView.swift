import SwiftUI

struct DatabaseQueryView: View {
    @State private var queryText = ""
    @State private var selectedCategory: SearchCategory = .personnel
    @State private var isScanning = false
    @State private var searchResults: [TerminalLog] = []
    
    enum SearchCategory: String, CaseIterable {
        case personnel = "PERSONNEL"
        case vehicles = "VEHICLES"
        case communications = "COMMUNICATION LOGS"
    }
    
    struct TerminalLog: Identifiable {
        let id = UUID()
        let text: String
        let color: Color
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("FEDERAL DATABASE ACCESS PROTOCOL")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.green)
                    .bold()
                Text("SECURE CONNECTION ACTIVE // CLASSIFIED INTEL")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.6))
            .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
            
            // Query Bar
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(SearchCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedCategory == category ? Color.green : Color.clear)
                                .foregroundColor(selectedCategory == category ? .black : .green)
                                .border(Color.green.opacity(0.5))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    TextField("Enter search parameter (e.g., Vance, Alchemist, TX-409-R)...", text: $queryText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.black)
                        .border(Color.green.opacity(0.4))
                        .foregroundColor(.green)
                        .onSubmit {
                            performSearch()
                        }
                    
                    Button(action: {
                        performSearch()
                    }) {
                        if isScanning {
                            ProgressView()
                                .tint(.black)
                                .frame(width: 120, height: 48)
                                .background(Color.green)
                        } else {
                            Text("RUN QUERY")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .foregroundColor(.black)
                                .frame(width: 120, height: 48)
                                .background(Color.green)
                        }
                    }
                    .disabled(queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isScanning)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            Divider().background(Color.green.opacity(0.3))
            
            // Terminal Output Console
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if searchResults.isEmpty {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "terminal.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green.opacity(0.3))
                                Text("AWAITING INTEL QUERY INPUT...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.green.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                        } else {
                            ForEach(searchResults) { log in
                                Text(log.text)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(log.color)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(log.id)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: searchResults.count) { _ in
                    if let last = searchResults.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(red: 0.03, green: 0.03, blue: 0.05))
        }
    }
    
    private func performSearch() {
        let parameter = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !parameter.isEmpty else { return }
        
        isScanning = true
        searchResults = [
            TerminalLog(text: ">> INITIALIZING SECURE RECORD LOOKUP...", color: .green),
            TerminalLog(text: ">> ESTABLISHING SHADOW HANDSHAKE PROTOCOL WITH AGENCY MAIN ENGINES...", color: .green)
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            searchResults.append(TerminalLog(text: ">> CONNECTED. RETRIEVING ARCHIVES FOR CATEGORY: \(selectedCategory.rawValue)...", color: .green))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let matches = searchDatabase(for: parameter, in: selectedCategory)
                searchResults.append(contentsOf: matches)
                isScanning = false
            }
        }
    }
    
    private func searchDatabase(for query: String, in category: SearchCategory) -> [TerminalLog] {
        let cleanQuery = query.lowercased()
        var logs: [TerminalLog] = []
        
        switch category {
        case .personnel:
            if cleanQuery.contains("vance") || cleanQuery.contains("aris") {
                logs.append(TerminalLog(text: "[MATCH CONFIRMED] SUBJECT: VANCE, ARIS (DR.)", color: .yellow))
                logs.append(TerminalLog(text: "--------------------------------------------------", color: .gray))
                logs.append(TerminalLog(text: "ROLE: SENIOR BIO-CHEMICAL SYNTHESIST (EX-APEX LABS)", color: .white))
                logs.append(TerminalLog(text: "CRIMINAL FILE: CLASSIFIED - INVESTIGATION PENDING (FEDERAL HOMICIDE DETECT)", color: .red))
                logs.append(TerminalLog(text: "ASSOCIATED KNOWN ENTITIES: ROSTOVA, ELENA (ART BROKER / SPECULATOR)", color: .white))
                logs.append(TerminalLog(text: "RECORD NOTES: Dismissed from Apex Labs after 1.2kg of military-grade precursor formulation went missing. Vance claimed theft, police reports unresolved.", color: .gray))
            } else if cleanQuery.contains("rostova") || cleanQuery.contains("elena") {
                logs.append(TerminalLog(text: "[MATCH CONFIRMED] SUBJECT: ROSTOVA, ELENA", color: .yellow))
                logs.append(TerminalLog(text: "--------------------------------------------------", color: .gray))
                logs.append(TerminalLog(text: "ROLE: ART CURATOR / INTERNATIONAL FINE GOODS BROKER", color: .white))
                logs.append(TerminalLog(text: "KNOWN SHELL ENTITIES: ROSTOVA ART HOLDINGS LTD, NORDIC LOGISTICS GMBH", color: .white))
                logs.append(TerminalLog(text: "SECURITY THREAT LEVEL: CLASS 3 (SUSPECTED COUNTERFEIT & BLACK MARKET CONDUIT)", color: .orange))
                logs.append(TerminalLog(text: "RECORD NOTES: Operates several premium galleries. Suspicious transfers of liquid currency detected via Baltic shell accounts matching dates of active biological breaches.", color: .gray))
            } else if cleanQuery.contains("alchemist") {
                logs.append(TerminalLog(text: "[MATCH CONFIRMED] CODENAME ARCHIVE: THE ALCHEMIST", color: .red))
                logs.append(TerminalLog(text: "--------------------------------------------------", color: .gray))
                logs.append(TerminalLog(text: "THREAT ENVELOPE: High-profile black-market developer. Custom poisonous formulas and synthetic chemical design.", color: .white))
                logs.append(TerminalLog(text: "SIGNATURE METRIC: Rare radioactive element signatures (Tracer isotope 409-R) found in toxin residues.", color: .yellow))
                logs.append(TerminalLog(text: "CURRENT CLASSIFIED STATUS: Active target. Associated with recent biochemical homicide of the German attache.", color: .red))
            } else {
                logs.append(TerminalLog(text: "[QUERY COMPLETED] NO RECORDS FOUND IN PERSONNEL DIRECTORY FOR: '\(query)'.", color: .red))
            }
            
        case .vehicles:
            if cleanQuery.contains("terminal 4") || cleanQuery.contains("airport") || cleanQuery.contains("delivery") {
                logs.append(TerminalLog(text: "[MATCH CONFIRMED] PORT/PORTAL LOGISTICS: TERMINAL 4", color: .yellow))
                logs.append(TerminalLog(text: "--------------------------------------------------", color: .gray))
                logs.append(TerminalLog(text: "LOGISTICAL OUTPOST: Terminal 4 Freight Storage, Hangar B.", color: .white))
                logs.append(TerminalLog(text: "INCOMING CARGO CHECK: Distillation glass crates matching 'Apex laboratory standards'. Consignee: Elena Rostova (Rostova Galleries).", color: .orange))
                logs.append(TerminalLog(text: "RELEASE STATUS: Blocked by customs officers due to mismatched isotope transport manifest records.", color: .red))
            } else {
                logs.append(TerminalLog(text: "[QUERY COMPLETED] NO MATCHING FREIGHT OR VEHICLE MANIFESTS RECORDED FOR: '\(query)'.", color: .red))
            }
            
        case .communications:
            if cleanQuery.contains("tx-409-r") || cleanQuery.contains("409") {
                logs.append(TerminalLog(text: "[MATCH CONFIRMED] RADAR SIGNALS INDEX: TX-409-R", color: .yellow))
                logs.append(TerminalLog(text: "--------------------------------------------------", color: .gray))
                logs.append(TerminalLog(text: "REGISTRATION ELEMENT: Custom Isotope Rig blueprint serial code.", color: .white))
                logs.append(TerminalLog(text: "TRANSCEIVER ACTIVITY: Cell tower records show a burner phone communicating directly with Dr. Vance's residence located in the vicinity of Terminal 4 during transport cycles.", color: .orange))
                logs.append(TerminalLog(text: "INTERCEPTED HEADER: 'The Alchemist formulation sequence completed. Ready for extraction.'", color: .red))
            } else {
                logs.append(TerminalLog(text: "[QUERY COMPLETED] COMMUNICATIONS ENCRYPTED OR SHADOW CELL TOWER LOGS SECURED. NO DISCLOSABLE LOGS FOR: '\(query)'.", color: .red))
            }
        }
        
        logs.append(TerminalLog(text: ">> SEARCH COMPLETED PROTOCOL EXECUTED. STANDING BY.", color: .green))
        return logs
    }
}
