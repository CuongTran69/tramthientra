## ADDED Requirements

### Requirement: Preset data caching
The system SHALL cache parsed preset data (chord and arp frequency arrays) in a dictionary keyed by preset name. The system SHALL NOT create a new JSContext or re-evaluate JavaScript for a preset that has already been loaded.

#### Scenario: First load of a preset
- **WHEN** playBackgroundMusic or changePreset is called with a preset name that has not been loaded before
- **THEN** the system SHALL evaluate the JS file via JSContext, parse the frequency arrays, store them in the cache, and discard the JSContext

#### Scenario: Subsequent load of a cached preset
- **WHEN** playBackgroundMusic or changePreset is called with a preset name that is already in the cache
- **THEN** the system SHALL use the cached data without creating a JSContext or reading the JS file

### Requirement: Resume background music without restart
The system SHALL provide a resumeBackgroundMusic() method that resumes the audio engine without reloading preset data or resetting the sample counter. The music SHALL continue from where it was paused.

#### Scenario: App returns to foreground
- **WHEN** the app transitions from background to active and background music was previously playing
- **THEN** ContentView SHALL call resumeBackgroundMusic() (not playBackgroundMusic()) and the music SHALL continue from its paused position

#### Scenario: Resume when engine is already running
- **WHEN** resumeBackgroundMusic() is called while the audio engine is already running
- **THEN** the method SHALL be a no-op (no error, no restart)

#### Scenario: Initial app launch
- **WHEN** the app launches and ContentView appears for the first time
- **THEN** ContentView SHALL call playBackgroundMusic() to perform the initial preset load and engine start

### Requirement: Preset switching API
The system SHALL provide a changePreset(_ name: String) public method that switches the active background music preset at runtime. The system SHALL expose a currentPreset: String? readable property indicating the active preset name.

#### Scenario: Switch to a different preset while music is playing
- **WHEN** changePreset is called with a preset name different from currentPreset while the engine is running
- **THEN** the system SHALL load (or use cached) preset data, update SynthesizerState with the new frequency arrays, reset sampleCount to 0, and update currentPreset

#### Scenario: Switch to the same preset
- **WHEN** changePreset is called with the same name as currentPreset
- **THEN** the method SHALL be a no-op

#### Scenario: Switch to a non-existent preset
- **WHEN** changePreset is called with a preset name that does not exist in the bundle
- **THEN** the system SHALL print a diagnostic message and leave the current preset unchanged

### Requirement: Track current preset name
The system SHALL maintain a currentPreset property that reflects the name of the currently active preset. It SHALL be set when playBackgroundMusic or changePreset successfully loads a preset.

#### Scenario: After initial playBackgroundMusic
- **WHEN** playBackgroundMusic(preset: "piano") completes successfully
- **THEN** currentPreset SHALL equal "piano"

#### Scenario: After changePreset
- **WHEN** changePreset("ambient") completes successfully
- **THEN** currentPreset SHALL equal "ambient"
