import Foundation
import SwiftData

// MARK: - SPEC §3.2 SwiftData Model — Gratitude Log Entry

@Model
final class GratitudeLog {
    var id: UUID
    var date: Date
    var items: [String]
    var synced: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        items: [String] = [],
        synced: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.items = items
        self.synced = synced
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}