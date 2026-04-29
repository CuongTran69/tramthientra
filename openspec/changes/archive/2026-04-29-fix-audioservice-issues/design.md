## Context

AudioService is a singleton managing two audio subsystems in the TramThienTra iOS app:

1. **Procedural background music** via AVAudioEngine + AVAudioSourceNode + JavaScriptCore. A real-time render closure reads frequency data from a `SynthesizerState` object to synthesize pad chords and arpeggios. Preset data (frequency arrays) is loaded from bundled `.js` files evaluated through JSContext.

2. **One-shot sound effects** via AVAudioPlayer for UI feedback sounds (pour tea, click, droplet).

Current state: AudioService has a data race on SynthesizerState, restarts music from the beginning on every foreground transition, re-evaluates JavaScript on every preset load, cannot play overlapping sound effects, and has no API for switching between the 5 bundled presets. A dead `SoundService` class in HapticService.swift duplicates effect playback functionality.

Files involved:
- `TramThienTra/Services/AudioService.swift` (227 lines) -- main service
- `TramThienTra/Services/HapticService.swift` (lines 44-65) -- dead SoundService
- `TramThienTra/App/TramThienTraApp.swift` (ContentView) -- call site

## Goals / Non-Goals

**Goals:**
- Eliminate the data race between main thread and audio render thread on SynthesizerState
- Allow background music to resume from its current position on foreground transitions
- Cache parsed preset data to avoid repeated JSContext creation and JS evaluation
- Expose a public API for switching presets at runtime
- Support overlapping sound effects and multi-format file lookup
- Remove dead code (SoundService)

**Non-Goals:**
- Adding a UI for preset selection (future work; this change only adds the API)
- Replacing the procedural synthesis approach with pre-recorded audio files
- Adding volume control or fade-in/fade-out transitions
- Supporting audio ducking or interruption handling beyond the current implementation

## Decisions

### D1: Use os_unfair_lock for thread synchronization

**Choice**: `os_unfair_lock` wrapping all reads and writes to SynthesizerState fields.

**Rationale**: Apple explicitly recommends `os_unfair_lock` for real-time audio threads. It does not allocate, does not cause priority inversion (unlike `NSLock` or `DispatchQueue`), and has minimal overhead. The audio render closure runs on a real-time thread where blocking on a mutex that could cause priority inversion is forbidden.

**Alternatives considered**:
- `DispatchQueue.sync` -- causes priority inversion on real-time threads; not suitable
- `NSLock` / `pthread_mutex` -- can cause priority inversion
- Atomic properties -- insufficient for compound state updates (chords + arps + sampleCount must be updated together)
- Actor isolation -- Swift actors use cooperative scheduling incompatible with the C-callback-based AVAudioSourceNode render closure

### D2: Cache parsed preset data, not JSContext

**Choice**: Store `[String: (chords: [[Double]], arps: [[Double]])]` dictionary. Discard JSContext after parsing.

**Rationale**: JSContext is heavyweight and not thread-safe. The only data needed from JS evaluation is the numeric frequency arrays. Caching the parsed result is simpler, smaller in memory, and safe to access from any thread (the arrays are value types once extracted).

### D3: Separate resume from play

**Choice**: Add `resumeBackgroundMusic()` that only calls `engine.start()` without reloading preset data or resetting sampleCount. Keep `playBackgroundMusic(preset:)` for initial start and explicit preset changes.

**Rationale**: The current behavior of restarting from sample 0 on every foreground transition is jarring. The audio engine's pause/start cycle naturally preserves the source node's state, so resuming only requires restarting the engine.

### D4: Array-based effect players with delegate cleanup

**Choice**: Replace `effectPlayer: AVAudioPlayer?` with `effectPlayers: [AVAudioPlayer]`. AudioService conforms to `AVAudioPlayerDelegate` and removes finished players in `audioPlayerDidFinishPlaying`.

**Rationale**: Simple and sufficient. The app plays at most 2-3 overlapping effects. An array with delegate cleanup avoids unbounded growth without the complexity of a player pool.

### D5: Extension fallback for sound effects

**Choice**: When `Bundle.main.url(forResource:withExtension:)` returns nil for the requested extension, try `.wav` as fallback.

**Rationale**: The bundle currently contains `droplet.wav` but call sites request `.mp3`. Rather than changing all call sites or requiring exact extensions, a single fallback in `playEffect` handles the mismatch transparently. This is forward-compatible -- when `.mp3` files are added later, they take priority.

## Risks / Trade-offs

- **[Lock contention in render closure]** The os_unfair_lock is held briefly in the render closure for reads and on the main thread for writes. Since writes happen only on preset changes (rare), contention is negligible. Mitigation: keep the critical section minimal (copy values out, then compute outside the lock).

- **[Memory from preset cache]** Caching all 5 presets keeps frequency arrays in memory permanently. Each preset is a few KB of Doubles. Mitigation: negligible memory impact; no eviction needed.

- **[Effect player array growth]** If effects are triggered rapidly, the array could grow before delegates fire. Mitigation: AVAudioPlayer delegate callbacks are prompt; the app's UI interaction rate naturally limits this.
