import Foundation
import SwiftData

// MARK: - SPEC §3.2 SwiftData Model — App User

@Model
final class AppUser {
    var id: UUID
    var appleUserId: String
    var apnsToken: String?
    var streak: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        appleUserId: String = "",
        apnsToken: String? = nil,
        streak: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.appleUserId = appleUserId
        self.apnsToken = apnsToken
        self.streak = streak
        self.createdAt = createdAt
    }
}