## Why

AudioService has several reliability and correctness issues: a data race between the main thread and the real-time audio render thread on shared `SynthesizerState`, background music restarting from the beginning on every foreground transition instead of resuming, expensive JSContext re-creation on every preset load, sound effects failing silently due to missing file extension fallback, and overlapping effects cutting each other off. These issues degrade the user experience and introduce undefined behavior from thread-unsafe access.

## What Changes

- Add `os_unfair_lock` synchronization around `SynthesizerState` access to eliminate the data race between the main thread and the audio render thread
- Add a `resumeBackgroundMusic()` method that resumes the audio engine without reloading preset data or resetting playback position
- Cache parsed preset data (chord/arp frequency arrays) after first JS evaluation to avoid repeated JSContext creation
- Add a `changePreset(_ name:)` public API so the app can switch between the 5 bundled presets (piano, ambient, cinematic, dark, lofi)
- Update `playEffect` to try `.wav` extension as fallback when the primary extension file is not found in the bundle
- Replace the single `effectPlayer` with an array of players and implement `AVAudioPlayerDelegate` cleanup so multiple sound effects can overlap
- Remove the dead `SoundService` class from `HapticService.swift` (superseded by AudioService)
- Update `ContentView` to call `resumeBackgroundMusic()` on foreground transition instead of `playBackgroundMusic()`

## Capabilities

### New Capabilities
- `audio-thread-safety`: Thread-safe access to synthesizer state using os_unfair_lock between main and audio render threads
- `audio-preset-management`: Preset caching, switching API, and resume-without-reload for background music
- `audio-effect-playback`: Multi-format fallback and overlapping sound effect support

### Modified Capabilities

## Impact

- **Files modified**: `AudioService.swift` (main changes), `HapticService.swift` (dead code removal), `TramThienTraApp.swift` (ContentView integration)
- **APIs added**: `resumeBackgroundMusic()`, `changePreset(_ name:)`, `currentPreset` property
- **APIs changed**: `playEffect(name:ext:)` gains fallback extension logic internally (signature unchanged)
- **Dependencies**: No new dependencies; uses existing `os/lock.h` (via Foundation), AVFAudio, JavaScriptCore
- **Risk**: Low-medium. Changes are isolated to AudioService and its two call sites. The thread safety fix addresses undefined behavior that exists today.
