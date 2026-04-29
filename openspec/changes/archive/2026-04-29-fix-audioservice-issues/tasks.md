## 1. Thread Safety for SynthesizerState

- [x] 1.1 Add `import os` to AudioService.swift and declare a private `os_unfair_lock` property (e.g., `private var stateLock = os_unfair_lock()`) on AudioService
- [x] 1.2 Wrap all writes to `synthState` fields in `playBackgroundMusic` with `os_unfair_lock_lock`/`os_unfair_lock_unlock` (chords, arps, sampleCount assignments)
- [x] 1.3 Refactor the AVAudioSourceNode render closure to acquire the lock, copy `synthState` fields into local variables, release the lock, then perform all synthesis computation using the local copies
- [x] 1.4 Ensure `stopBackgroundMusic` does not need locking (it only calls `engine.pause()`, no state mutation) <- (verify: no data race warnings in Thread Sanitizer, render closure holds lock only for value copies)

## 2. Preset Data Caching

- [x] 2.1 Add `private var presetCache: [String: (chords: [[Double]], arps: [[Double]])] = [:]` dictionary property to AudioService
- [x] 2.2 Add `private(set) var currentPreset: String?` property to AudioService
- [x] 2.3 Refactor `loadPreset(name:)` to check `presetCache` first and return cached data if present; only create JSContext and evaluate JS when cache misses; store result in cache before returning <- (verify: JSContext is created at most once per preset name, cached data matches fresh evaluation)

## 3. Resume and Preset Switching API

- [x] 3.1 Add `func resumeBackgroundMusic()` public method that calls `engine.start()` only if the engine is not running, without reloading preset data or resetting sampleCount
- [x] 3.2 Add `func changePreset(_ name: String)` public method that: returns early if name equals currentPreset; loads (or uses cached) preset data; acquires stateLock; updates synthState chords/arps and resets sampleCount; releases lock; updates currentPreset
- [x] 3.3 Update `playBackgroundMusic(preset:)` to set `currentPreset` after successful preset load
- [x] 3.4 Ensure `changePreset` with a non-existent preset name prints a diagnostic and leaves currentPreset unchanged <- (verify: resumeBackgroundMusic does not reset sampleCount, changePreset uses cache, currentPreset is always accurate)

## 4. Sound Effect Improvements

- [x] 4.1 Replace `private var effectPlayer: AVAudioPlayer?` with `private var effectPlayers: [AVAudioPlayer] = []`
- [x] 4.2 Conform AudioService to `AVAudioPlayerDelegate` and implement `audioPlayerDidFinishPlaying(_:successfully:)` to remove the finished player from `effectPlayers`
- [x] 4.3 Update `playEffect(name:ext:)` to append new AVAudioPlayer to `effectPlayers` array and set its delegate to `self`
- [x] 4.4 Add fallback logic in `playEffect`: if `Bundle.main.url(forResource:withExtension:)` returns nil for the requested extension, try `.wav` as fallback before returning <- (verify: two rapid playEffect calls both produce audio, droplet.wav plays when requested as mp3, effectPlayers array does not grow unbounded)

## 5. Dead Code Removal

- [x] 5.1 Delete the `SoundService` class (lines 42-65) from `TramThienTra/Services/HapticService.swift`, keeping the `HapticService` class and its imports intact <- (verify: HapticService.swift contains only HapticService class, no compile errors)

## 6. ContentView Integration

- [x] 6.1 In `TramThienTra/App/TramThienTraApp.swift`, change the `.onChange(of: scenePhase)` active case from `AudioService.shared.playBackgroundMusic()` to `AudioService.shared.resumeBackgroundMusic()`
- [x] 6.2 Keep the `.onAppear` call as `AudioService.shared.playBackgroundMusic()` for initial launch <- (verify: app compiles without warnings, foreground transition resumes music from paused position, initial launch starts music normally)
