import Foundation
import SwiftData

// MARK: - SPEC §3.4 Sync service — SwiftData ↔ backend, guest→login migration, retry

actor SyncService {
    static let shared = SyncService()

    private let baseURL = Constants.apiBaseURL
    private let maxRetries = 3

    private init() {}

    /// Sync a single GratitudeLog to the backend.
    func syncLog(_ log: GratitudeLog) async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/logs") else {
            throw SyncError.invalidURL
        }

        var attempt = 0
        while attempt < maxRetries {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                if let userId = AuthService.shared.getCurrentUserId() {
                    request.setValue("Bearer \(userId)", forHTTPHeaderField: "Authorization")
                }

                let payload: [String: Any] = [
                    "id": log.id.uuidString,
                    "date": ISO8601DateFormatter().string(from: log.date),
                    "items": log.items,
                    "synced": true
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)

                let (_, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw SyncError.serverError
                }

                // Mark as synced
                log.synced = true
                return
            } catch {
                attempt += 1
                if attempt >= maxRetries {
                    throw SyncError.maxRetriesExceeded
                }
                try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
            }
        }
    }

    /// Migrate all local entries for a guest → logged-in user.
    @MainActor
    func migrateGuestEntries(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<GratitudeLog>(
            predicate: #Predicate { !$0.synced }
        )

        do {
            let unsyncedLogs = try modelContext.fetch(descriptor)
            for log in unsyncedLogs {
                do {
                    try await syncLog(log)
                    try modelContext.save()
                } catch {
                    print("[Sync] Migration failed for log \(log.id): \(error)")
                }
            }
        } catch {
            print("[Sync] Fetch failed: \(error)")
        }
    }

    /// Background sync of all pending logs.
    @MainActor
    func syncAllPending(modelContext: ModelContext) async {
        await migrateGuestEntries(modelContext: modelContext)
    }
}

enum SyncError: Error {
    case invalidURL
    case serverError
    case maxRetriesExceeded
}