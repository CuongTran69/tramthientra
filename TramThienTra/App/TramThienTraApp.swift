import SwiftUI
import SwiftData

// MARK: - SPEC §1 App Entry Point
// TODO: Implement full routing based on hasCompletedOnboarding (SPEC §2.1)

@main
struct TramThienTraApp: App {
    @StateObject private var streakViewModel = StreakViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GratitudeLog.self,
            AppUser.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(streakViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Content View placeholder
// TODO: Implement routing based on hasCompletedOnboarding (SPEC §2.1)
struct ContentView: View {
    @AppStorage(Constants.hasCompletedOnboardingKey) private var hasCompletedOnboarding: Bool = false

    var body: some View {
        if hasCompletedOnboarding {
            TraThatView()
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}