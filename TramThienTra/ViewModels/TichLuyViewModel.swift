import Foundation
import SwiftUI
import SwiftData

// MARK: - SPEC §3.3 ViewModel — Gratitude entry form

@MainActor
final class TichLuyViewModel: ObservableObject {
    @Published var item1: String = ""
    @Published var item2: String = ""
    @Published var item3: String = ""
    @Published var isSaving: Bool = false

    private let maxCharacters = Constants.maxCharacterLimit

    var isFormValid: Bool {
        !item1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveGratitude(modelContext: ModelContext) async {
        guard isFormValid else { return }
        isSaving = true
        defer { isSaving = false }

        let trimmedItem1 = String(item1.prefix(maxCharacters))
        let trimmedItem2 = String(item2.prefix(maxCharacters))
        let trimmedItem3 = String(item3.prefix(maxCharacters))

        let log = GratitudeLog(
            date: Date(),
            items: [trimmedItem1, trimmedItem2, trimmedItem3].filter { !$0.isEmpty },
            synced: false
        )

        modelContext.insert(log)

        do {
            try modelContext.save()
            // Reset form
            item1 = ""
            item2 = ""
            item3 = ""
            HapticService.shared.playSuccess()
            try await SyncService.shared.syncLog(log)
        } catch {
            print("[TichLuy] Save failed: \(error)")
        }
    }
}