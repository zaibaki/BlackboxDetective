import Foundation
import GRDB

public struct Case: Codable, FetchableRecord, MutablePersistableRecord, Identifiable, Hashable {
    public static var databaseTableName: String { "investigationCase" }
    
    public var id: UUID
    public var title: String
    public var codename: String
    public var summary: String
    public var status: String // "locked", "active", "solved"
    public var unlockedAt: Date
    
    public init(id: UUID, title: String, codename: String, summary: String, status: String, unlockedAt: Date) {
        self.id = id
        self.title = title
        self.codename = codename
        self.summary = summary
        self.status = status
        self.unlockedAt = unlockedAt
    }
}

public struct Clue: Codable, FetchableRecord, MutablePersistableRecord, Identifiable, Hashable {
    public var id: UUID
    public var caseId: UUID
    public var title: String
    public var type: String // "audio", "document", "image", "metadata"
    public var mediaPath: String
    public var transcript: String
    public var discoveryStatus: String // "hidden", "unlocked", "analyzed"
    
    public init(id: UUID, caseId: UUID, title: String, type: String, mediaPath: String, transcript: String, discoveryStatus: String) {
        self.id = id
        self.caseId = caseId
        self.title = title
        self.type = type
        self.mediaPath = mediaPath
        self.transcript = transcript
        self.discoveryStatus = discoveryStatus
    }
}

public struct EvidenceConnection: Codable, FetchableRecord, MutablePersistableRecord, Identifiable, Hashable {
    public var id: UUID
    public var caseId: UUID
    public var sourceClueId: UUID
    public var targetClueId: UUID
    public var connectionNote: String
    public var xPosSource: Double
    public var yPosSource: Double
    public var xPosTarget: Double
    public var yPosTarget: Double
    
    public init(id: UUID, caseId: UUID, sourceClueId: UUID, targetClueId: UUID, connectionNote: String, xPosSource: Double, yPosSource: Double, xPosTarget: Double, yPosTarget: Double) {
        self.id = id
        self.caseId = caseId
        self.sourceClueId = sourceClueId
        self.targetClueId = targetClueId
        self.connectionNote = connectionNote
        self.xPosSource = xPosSource
        self.yPosSource = yPosSource
        self.xPosTarget = xPosTarget
        self.yPosTarget = yPosTarget
    }
}

public struct Suspect: Codable, FetchableRecord, MutablePersistableRecord, Identifiable, Hashable {
    public var id: UUID
    public var caseId: UUID
    public var name: String
    public var photoPath: String
    public var alibi: String
    public var profileNotes: String
    public var interrogationLimit: Int
    public var questionsAsked: Int
    public var isGuilty: Bool
    public var secretPrompt: String
    
    public init(id: UUID, caseId: UUID, name: String, photoPath: String, alibi: String, profileNotes: String, interrogationLimit: Int, questionsAsked: Int, isGuilty: Bool, secretPrompt: String) {
        self.id = id
        self.caseId = caseId
        self.name = name
        self.photoPath = photoPath
        self.alibi = alibi
        self.profileNotes = profileNotes
        self.interrogationLimit = interrogationLimit
        self.questionsAsked = questionsAsked
        self.isGuilty = isGuilty
        self.secretPrompt = secretPrompt
    }
}

public struct InterrogationLog: Codable, FetchableRecord, MutablePersistableRecord, Identifiable, Hashable {
    public var id: UUID
    public var suspectId: UUID
    public var sender: String // "detective", "suspect"
    public var message: String
    public var timestamp: Date
    
    public init(id: UUID, suspectId: UUID, sender: String, message: String, timestamp: Date) {
        self.id = id
        self.suspectId = suspectId
        self.sender = sender
        self.message = message
        self.timestamp = timestamp
    }
}
