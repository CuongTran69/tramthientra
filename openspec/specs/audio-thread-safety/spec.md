## ADDED Requirements

### Requirement: Thread-safe SynthesizerState access
The system SHALL protect all reads and writes to SynthesizerState fields with an os_unfair_lock. The audio render thread (AVAudioSourceNode callback) SHALL acquire the lock before reading state fields. The main thread SHALL acquire the lock before writing state fields in playBackgroundMusic, resumeBackgroundMusic, and changePreset.

#### Scenario: Concurrent read during write
- **WHEN** the main thread updates SynthesizerState chords/arps via playBackgroundMusic while the audio render thread is reading state for sample generation
- **THEN** the lock SHALL serialize access so the render thread never observes a partially-written state (e.g., new chords with old arps)

#### Scenario: Lock does not cause priority inversion
- **WHEN** the audio render thread acquires the lock
- **THEN** the lock type SHALL be os_unfair_lock (not NSLock, DispatchQueue, or pthread_mutex) to avoid priority inversion on the real-time audio thread

#### Scenario: Minimal critical section in render closure
- **WHEN** the render closure executes per audio frame
- **THEN** the lock SHALL be held only long enough to copy state values into local variables, and all synthesis computation SHALL occur outside the lock
