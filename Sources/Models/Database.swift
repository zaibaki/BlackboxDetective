import Foundation
import GRDB

public class DatabaseManager {
    public static let shared = DatabaseManager()
    public var dbQueue: DatabaseQueue?
    
    public init() {
        let fileManager = FileManager.default
        let folderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbURL = folderURL.appendingPathComponent("blackbox_detective.sqlite")
        print("Database filepath: \(dbURL.path)")
        
        do {
            dbQueue = try DatabaseQueue(path: dbURL.path)
            try setupDatabase()
        } catch {
            print("Database setup failed: \(error). Recreating file to resolve schema mismatch...")
            try? fileManager.removeItem(at: dbURL)
            do {
                dbQueue = try DatabaseQueue(path: dbURL.path)
                try setupDatabase()
            } catch {
                print("Critical: Database recreation failed: \(error)")
            }
        }
    }
    
    private func setupDatabase() throws {
        guard let dbQueue = dbQueue else { return }
        
        try dbQueue.write { db in
            // Create cases table
            try db.create(table: "investigationCase", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("codename", .text).notNull()
                t.column("summary", .text).notNull()
                t.column("status", .text).notNull()
                t.column("unlockedAt", .datetime).notNull()
            }
            
            // Create clues table
            try db.create(table: "clue", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("caseId", .text).notNull().references("investigationCase", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("type", .text).notNull()
                t.column("mediaPath", .text).notNull()
                t.column("transcript", .text).notNull()
                t.column("discoveryStatus", .text).notNull()
            }
            
            // Create evidence_connections table
            try db.create(table: "evidenceConnection", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("caseId", .text).notNull().references("investigationCase", onDelete: .cascade)
                t.column("sourceClueId", .text).notNull().references("clue", onDelete: .cascade)
                t.column("targetClueId", .text).notNull().references("clue", onDelete: .cascade)
                t.column("connectionNote", .text).notNull()
                t.column("xPosSource", .double).notNull()
                t.column("yPosSource", .double).notNull()
                t.column("xPosTarget", .double).notNull()
                t.column("yPosTarget", .double).notNull()
            }
            
            // Create suspects table
            try db.create(table: "suspect", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("caseId", .text).notNull().references("investigationCase", onDelete: .cascade)
                t.column("name", .text).notNull()
                t.column("photoPath", .text).notNull()
                t.column("alibi", .text).notNull()
                t.column("profileNotes", .text).notNull()
                t.column("interrogationLimit", .integer).notNull()
                t.column("questionsAsked", .integer).notNull()
                t.column("isGuilty", .boolean).notNull()
                t.column("secretPrompt", .text).notNull()
            }
            
            // Create interrogation_logs table
            try db.create(table: "interrogationLog", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("suspectId", .text).notNull().references("suspect", onDelete: .cascade)
                t.column("sender", .text).notNull()
                t.column("message", .text).notNull()
                t.column("timestamp", .datetime).notNull()
            }
            
            // Create investigatorNote table
            try db.create(table: "investigatorNote", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("caseId", .text).notNull().references("investigationCase", onDelete: .cascade)
                t.column("content", .text).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
        }
        
        try seedInitialData()
    }
    
    private func seedInitialData() throws {
        guard let dbQueue = dbQueue else { return }
        
        try dbQueue.write { db in
            let caseCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM investigationCase") ?? 0
            if caseCount == 0 {
                // Seed Case
                let caseId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
                var activeCase = Case(
                    id: caseId,
                    title: "The Chemist's Recipe",
                    codename: "The Alchemist",
                    summary: "A high-profile diplomat was poisoned with a rare synthetic neurotoxin at a state banquet. All signs point to a signature developer known only as 'The Alchemist'. We must intercept the next target.",
                    status: "active",
                    unlockedAt: Date()
                )
                try activeCase.insert(db)
                
                // Seed Clues
                let clue1Id = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
                var clue1 = Clue(
                    id: clue1Id,
                    caseId: caseId,
                    title: "Intercepted Audio Tape 409",
                    type: "audio",
                    mediaPath: "audio_tape_409.mp3",
                    transcript: "[Static] Vance: The delivery is delayed. The customs officers at Terminal 4 are asking questions. Rostova: Figure it out, Vance. The client does not like to wait, and the formulation degrades at room temperature. [Beep]",
                    discoveryStatus: "unlocked"
                )
                try clue1.insert(db)
                
                let clue2Id = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
                var clue2 = Clue(
                    id: clue2Id,
                    caseId: caseId,
                    title: "Encrypted Lab Blueprint",
                    type: "image",
                    mediaPath: "lab_blueprint.png",
                    transcript: "Image shows a schematic of a specialized glass distillation rig with hand-drawn annotations matching Dr. Vance's personal notebook handwriting. A serial number is visible: 'TX-409-R'.",
                    discoveryStatus: "analyzed"
                )
                try clue2.insert(db)
                
                let clue3Id = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
                var clue3 = Clue(
                    id: clue3Id,
                    caseId: caseId,
                    title: "Burn Phone Ledger Record",
                    type: "document",
                    mediaPath: "phone_ledger.txt",
                    transcript: "Found in a discarded burner cell: 3 calls to Dr. Vance's private residence line, immediately preceding and following the diplomat's poisoning event.",
                    discoveryStatus: "hidden"
                )
                try clue3.insert(db)
                
                // Seed Suspects
                let suspect1Id = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
                var suspect1 = Suspect(
                    id: suspect1Id,
                    caseId: caseId,
                    name: "Dr. Aris Vance",
                    photoPath: "dr_vance.png",
                    alibi: "Claimed he was lecturing at the university chemistry department when the poisoning occurred, but colleagues cannot verify his location between 3 PM and 6 PM.",
                    profileNotes: "Brilliant chemical synthesist, former lead researcher at Apex Labs. Dismissed under suspicious circumstances regarding chemical theft.",
                    interrogationLimit: 12,
                    questionsAsked: 0,
                    isGuilty: true,
                    secretPrompt: "You are Dr. Aris Vance, the genius chemist codenamed 'The Alchemist'. You are nervous but supercilious. You deny everything. If the investigator mentions the 'Audio Tape' or 'Terminal 4', you become agitated and stammer. If they explicitly confront you with the 'Burn Phone Ledger' or the calls, you break and admit that Elena Rostova blackmailed you into synthesizing the neurotoxin because she holds your family's debts. Keep replies short (1-2 sentences)."
                )
                try suspect1.insert(db)
                
                let suspect2Id = UUID(uuidString: "66666666-6666-6666-6666-666666666666")!
                var suspect2 = Suspect(
                    id: suspect2Id,
                    caseId: caseId,
                    name: "Elena Rostova",
                    photoPath: "elena_rostova.png",
                    alibi: "Was hosting a charity gala at her private gallery during the incident, surrounded by 200 witnesses.",
                    profileNotes: "High-society broker and art curator. Rumored to run a private channel for illegal high-end black-market transactions.",
                    interrogationLimit: 8,
                    questionsAsked: 0,
                    isGuilty: false,
                    secretPrompt: "You are Elena Rostova, a cold, elegant, and powerful black-market broker. You treat the detective with polite amusement. You have a solid alibi and know the law. You will tell them that you know Dr. Vance, but only as a buyer of rare chemical formulas. You claim to have no knowledge of any poison. If the detective accuses you without solid proof, you mock them. Keep replies cold, short, and poised."
                )
                try suspect2.insert(db)
                
                // Seed Case 2 (The Courier)
                let case2Id = UUID(uuidString: "88888888-8888-8888-8888-888888888888")!
                var courierCase = Case(
                    id: case2Id,
                    title: "The Shadow Courier",
                    codename: "The Courier",
                    summary: "A courier has been intercepted at a border checkpoint with a locked briefcase containing schematics for a custom neural-active trigger. Cross-reference municipal database files to locate their drop point.",
                    status: "locked",
                    unlockedAt: Date().addingTimeInterval(3600)
                )
                try courierCase.insert(db)
                
                // Seed Clues for Case 2
                var courierClue1 = Clue(
                    id: UUID(),
                    caseId: case2Id,
                    title: "Border Checkpoint Briefcase",
                    type: "document",
                    mediaPath: "courier_ledger.txt",
                    transcript: "Found inside the double lining of the case: a logistics routing map referencing 'Warehouse 4' and a delivery contact 'Rostova Art Logistics'.",
                    discoveryStatus: "unlocked"
                )
                try courierClue1.insert(db)
                
                // Seed Suspect for Case 2
                var courierSuspect1 = Suspect(
                    id: UUID(),
                    caseId: case2Id,
                    name: "Viktor Cruz",
                    photoPath: "cruz.png",
                    alibi: "Claims he was just a delivery driver hired via an online courier app, with no knowledge of the classified contents.",
                    profileNotes: "Known associate of shipping ports. Linked to smuggling operations in Eastern European routes.",
                    interrogationLimit: 10,
                    questionsAsked: 0,
                    isGuilty: true,
                    secretPrompt: "You are Viktor Cruz, a smuggling courier. You act dumb and pretend to be a simple driver. If they mention 'Warehouse 4', you panic. Keep replies brief."
                )
                try courierSuspect1.insert(db)
            }
        }
    }
    
    // MARK: - Database APIs
    
    public func fetchCases() -> [Case] {
        guard let dbQueue = dbQueue else { return [] }
        return (try? dbQueue.read { db in
            try Case.fetchAll(db, sql: "SELECT * FROM investigationCase ORDER BY unlockedAt DESC")
        }) ?? []
    }
    
    public func fetchClues(caseId: UUID) -> [Clue] {
        guard let dbQueue = dbQueue else { return [] }
        return (try? dbQueue.read { db in
            try Clue.fetchAll(db, sql: "SELECT * FROM clue WHERE caseId = ?", arguments: [caseId.uuidString])
        }) ?? []
    }
    
    public func fetchSuspects(caseId: UUID) -> [Suspect] {
        guard let dbQueue = dbQueue else { return [] }
        return (try? dbQueue.read { db in
            try Suspect.fetchAll(db, sql: "SELECT * FROM suspect WHERE caseId = ?", arguments: [caseId.uuidString])
        }) ?? []
    }
    
    public func fetchConnections(caseId: UUID) -> [EvidenceConnection] {
        guard let dbQueue = dbQueue else { return [] }
        return (try? dbQueue.read { db in
            try EvidenceConnection.fetchAll(db, sql: "SELECT * FROM evidenceConnection WHERE caseId = ?", arguments: [caseId.uuidString])
        }) ?? []
    }
    
    public func fetchInterrogationLogs(suspectId: UUID) -> [InterrogationLog] {
        guard let dbQueue = dbQueue else { return [] }
        return (try? dbQueue.read { db in
            try InterrogationLog.fetchAll(db, sql: "SELECT * FROM interrogationLog WHERE suspectId = ? ORDER BY timestamp ASC", arguments: [suspectId.uuidString])
        }) ?? []
    }
    
    public func saveConnection(_ connection: EvidenceConnection) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            var mutableConnection = connection
            try mutableConnection.save(db)
        }
    }
    
    public func deleteConnection(id: UUID) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            try db.execute(sql: "DELETE FROM evidenceConnection WHERE id = ?", arguments: [id.uuidString])
        }
    }
    
    public func updateClueDiscoveryStatus(clueId: UUID, status: String) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            try db.execute(sql: "UPDATE clue SET discoveryStatus = ? WHERE id = ?", arguments: [status, clueId.uuidString])
        }
    }
    
    public func saveInterrogationLog(_ log: InterrogationLog) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            var mutableLog = log
            try mutableLog.save(db)
        }
    }
    
    public func incrementQuestionsAsked(suspectId: UUID) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            try db.execute(sql: "UPDATE suspect SET questionsAsked = questionsAsked + 1 WHERE id = ?", arguments: [suspectId.uuidString])
        }
    }
    
    public func fetchNote(caseId: UUID) -> InvestigatorNote? {
        guard let dbQueue = dbQueue else { return nil }
        return (try? dbQueue.read { db in
            try InvestigatorNote.fetchOne(db, sql: "SELECT * FROM investigatorNote WHERE caseId = ?", arguments: [caseId.uuidString])
        })
    }
    
    public func saveNote(_ note: InvestigatorNote) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            var mutableNote = note
            try mutableNote.save(db)
        }
    }
    
    public func solveCase(caseId: UUID) {
        guard let dbQueue = dbQueue else { return }
        try? dbQueue.write { db in
            // Set current case to solved
            try db.execute(sql: "UPDATE investigationCase SET status = 'solved' WHERE id = ?", arguments: [caseId.uuidString])
            // Unlock next case (The Courier)
            let nextCaseId = UUID(uuidString: "88888888-8888-8888-8888-888888888888")!
            try db.execute(sql: "UPDATE investigationCase SET status = 'active' WHERE id = ?", arguments: [nextCaseId.uuidString])
        }
    }
}
