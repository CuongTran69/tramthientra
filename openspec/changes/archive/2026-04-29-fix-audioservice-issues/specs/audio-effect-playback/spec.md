## ADDED Requirements

### Requirement: Multi-format sound effect fallback
The system SHALL attempt to load a sound effect file with the requested extension first. If the file is not found, the system SHALL try `.wav` as a fallback extension before giving up.

#### Scenario: Requested extension exists
- **WHEN** playEffect(name: "droplet", ext: "wav") is called and droplet.wav exists in the bundle
- **THEN** the system SHALL play droplet.wav

#### Scenario: Requested extension missing, fallback exists
- **WHEN** playEffect(name: "pour_tea", ext: "mp3") is called and pour_tea.mp3 does not exist but pour_tea.wav exists in the bundle
- **THEN** the system SHALL play pour_tea.wav

#### Scenario: Neither extension exists
- **WHEN** playEffect(name: "missing", ext: "mp3") is called and neither missing.mp3 nor missing.wav exists in the bundle
- **THEN** the system SHALL silently return without error (no crash, no user-visible error)

### Requirement: Overlapping sound effects
The system SHALL support playing multiple sound effects simultaneously. Starting a new sound effect SHALL NOT stop or interrupt any currently playing effect.

#### Scenario: Two effects triggered in quick succession
- **WHEN** playEffect(name: "click") is called while a previous playEffect(name: "pour_tea") is still playing
- **THEN** both effects SHALL play simultaneously without one cutting off the other

#### Scenario: Finished players are cleaned up
- **WHEN** a sound effect finishes playing
- **THEN** the system SHALL remove the finished AVAudioPlayer from its internal collection to prevent unbounded memory growth

### Requirement: Remove dead SoundService
The SoundService class in HapticService.swift SHALL be removed. It is dead code superseded by AudioService.

#### Scenario: SoundService class deleted
- **WHEN** the fix is applied
- **THEN** HapticService.swift SHALL contain only the HapticService class, with no SoundService class definition
