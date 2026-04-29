import SwiftUI
import SwiftData

// MARK: - SPEC §1 App Entry Point
// TODO: Implement full routing based on hasCompletedOnboarding (SPEC §2.1)

@main
struct TramThienTraApp: App {
    @StateObject private var streakViewModel = StreakViewModel()
    @StateObject private var thoiGianViewModel = ThoiGianViewModel()

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
                .environmentObject(thoiGianViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Content View with notification reminder integration
struct ContentView: View {
    @AppStorage(Constants.hasCompletedOnboardingKey) private var hasCompletedOnboarding: Bool = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    @AppStorage(Constants.backgroundMusicEnabledKey) private var backgroundMusicEnabled = true
    @StateObject private var notificationReminderService = NotificationReminderService()

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TraThatView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .task {
            if AuthService.shared.getCurrentUserId() != nil {
                await SyncService.shared.syncAllPending(modelContext: modelContext)
            }
        }
        .onAppear {
            if backgroundMusicEnabled {
                AudioService.shared.playBackgroundMusic(preset: thoiGianVM.current.musicPreset)
            }
        }
        .onChange(of: thoiGianVM.current) { _, newSlot in
            if backgroundMusicEnabled {
                AudioService.shared.changePreset(newSlot.musicPreset)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                notificationReminderService.checkAndUpdatePromptStatus()
                if backgroundMusicEnabled {
                    AudioService.shared.resumeBackgroundMusic()
                }
            } else if newPhase == .background {
                AudioService.shared.stopBackgroundMusic()
            }
        }
        .sheet(isPresented: $notificationReminderService.shouldShowPrompt) {
            NotificationPromptView(
                onAccept: {
                    notificationReminderService.acceptPrompt()
                },
                onDismiss: {
                    notificationReminderService.dismissPrompt()
                }
            )
            .environmentObject(thoiGianVM)
        }
    }
}