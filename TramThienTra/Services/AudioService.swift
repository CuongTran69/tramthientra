import Foundation
import AVFAudio
import JavaScriptCore
import os

// MARK: - Procedural Audio State
/// Lưu trạng thái của máy phát âm tổng hợp để dùng trong realtime render thread
class SynthesizerState {
    var chords: [[Double]] = []
    var arps: [[Double]] = []

    var sampleCount: Int = 0

    var chordPhases = [Double](repeating: 0.0, count: 4)
    var chordFrequencies = [Double](repeating: 0.0, count: 4)

    var arpPhase: Double = 0.0
    var arpFrequency: Double = 0.0
    var arpAmplitude: Double = 0.0
    var currentArpNoteIndex: Int = -1

    // Tham số synthesis — mỗi preset có giá trị riêng
    var chordDuration: Double = 8.0
    var arpDuration: Double = 0.4
    var arpDecay: Double = 0.9998
    var padVolume: Double = 0.08
    var arpVolume: Double = 0.25
    var portamento: Double = 0.001
}

// MARK: - AudioService
/// Quản lý phát âm thanh: Procedural Audio (nhạc sinh học) cho nhạc nền và MP3 cho hiệu ứng
class AudioService: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioService()

    // Engine cho nhạc sinh học
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let synthState = SynthesizerState()

    // Thread safety: os_unfair_lock cho real-time audio thread (heap-allocated for pointer stability)
    private let stateLock: UnsafeMutablePointer<os_unfair_lock> = {
        let lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        return lock
    }()

    // Preset caching — lưu cả tần số và tham số synthesis
    private var presetCache: [String: PresetData] = [:]
    private(set) var currentPreset: String?

    struct PresetData {
        let chords: [[Double]]
        let arps: [[Double]]
        let chordDuration: Double
        let arpDuration: Double
        let arpDecay: Double
        let padVolume: Double
        let arpVolume: Double
        let portamento: Double
    }

    // Player cho hiệu ứng âm thanh vật lý (nước rót, tiếng click)
    private var effectPlayers: [AVAudioPlayer] = []

    private override init() {
        super.init()
        configureAudioSession()
        setupSynthesizer()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioService] ❌ Audio session failed: \(error)")
        }
    }
    
    // MARK: - Nhạc Nền Sinh Học (Procedural Synthesizer)
    
    private func setupSynthesizer() {
        let state = synthState
        let lockPtr = stateLock

        let outputFormat = engine.outputNode.inputFormat(forBus: 0)
        let sampleRate = outputFormat.sampleRate > 0 ? outputFormat.sampleRate : 44100.0

        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            // Acquire lock and copy shared state into local variables
            os_unfair_lock_lock(lockPtr)
            let localChords = state.chords
            let localArps = state.arps
            var localSampleCount = state.sampleCount
            var localChordPhases = state.chordPhases
            var localChordFrequencies = state.chordFrequencies
            var localArpPhase = state.arpPhase
            var localArpFrequency = state.arpFrequency
            var localArpAmplitude = state.arpAmplitude
            var localCurrentArpNoteIndex = state.currentArpNoteIndex
            let localChordDuration = state.chordDuration
            let localArpDuration = state.arpDuration
            let localArpDecay = state.arpDecay
            let localPadVolume = state.padVolume
            let localArpVolume = state.arpVolume
            let localPortamento = state.portamento
            os_unfair_lock_unlock(lockPtr)

            // All synthesis computation uses local copies only
            for frame in 0..<Int(frameCount) {
                let timeInSeconds = Double(localSampleCount) / sampleRate

                // Sequencer logic — tham số từ preset
                let chordDuration = localChordDuration
                let arpDuration = localArpDuration

                if !localChords.isEmpty {
                    let chordIndex = Int(timeInSeconds / chordDuration) % localChords.count
                    let chord = localChords[chordIndex]
                    for i in 0..<min(4, chord.count) {
                        let targetFreq = chord[i]
                        localChordFrequencies[i] += (targetFreq - localChordFrequencies[i]) * localPortamento
                    }
                }

                if !localArps.isEmpty {
                    let arpIndex = Int(timeInSeconds / chordDuration) % localArps.count
                    let arp = localArps[arpIndex]
                    let arpNoteIndex = Int(timeInSeconds / arpDuration) % max(1, arp.count)

                    if arpNoteIndex != localCurrentArpNoteIndex {
                        localCurrentArpNoteIndex = arpNoteIndex
                        localArpFrequency = arp[arpNoteIndex]
                        localArpAmplitude = 1.0 // Gảy nốt (Pluck)
                    }
                }

                // Envelope rải nốt — decay từ preset
                localArpAmplitude *= localArpDecay

                // Tổng hợp sóng âm
                var sampleValue: Double = 0.0

                // 1. Chords (Âm thanh nền/Pad)
                for i in 0..<4 {
                    let freq = localChordFrequencies[i]
                    if freq > 0 {
                        localChordPhases[i] += (2.0 * .pi * freq) / sampleRate
                        if localChordPhases[i] > 2.0 * .pi { localChordPhases[i] -= 2.0 * .pi }
                        sampleValue += sin(localChordPhases[i]) * localPadVolume
                    }
                }

                // 2. Arpeggio (Nốt rải)
                if localArpFrequency > 0 {
                    localArpPhase += (2.0 * .pi * localArpFrequency) / sampleRate
                    if localArpPhase > 2.0 * .pi { localArpPhase -= 2.0 * .pi }
                    sampleValue += sin(localArpPhase) * localArpAmplitude * localArpVolume
                }

                // Giới hạn Master Volume tổng
                sampleValue *= 0.3

                // Ghi dữ liệu vào Buffer an toàn
                for buffer in ablPointer {
                    let ptr = buffer.mData?.assumingMemoryBound(to: Float.self)
                    ptr?[frame] = Float(sampleValue)
                }

                localSampleCount += 1
            }

            // Write back mutable state under lock
            os_unfair_lock_lock(lockPtr)
            state.sampleCount = localSampleCount
            state.chordPhases = localChordPhases
            state.chordFrequencies = localChordFrequencies
            state.arpPhase = localArpPhase
            state.arpFrequency = localArpFrequency
            state.arpAmplitude = localArpAmplitude
            state.currentArpNoteIndex = localCurrentArpNoteIndex
            os_unfair_lock_unlock(lockPtr)

            return noErr
        }

        if let sourceNode = sourceNode {
            engine.attach(sourceNode)
            engine.connect(sourceNode, to: engine.mainMixerNode, format: outputFormat)
        }
    }
    
    /// Đọc file `.js` bằng JavaScriptCore và lấy ra tần số + tham số synthesis (có cache)
    private func loadPreset(name: String) -> PresetData? {
        // Check cache first
        if let cached = presetCache[name] {
            return cached
        }

        // Thử tìm trong thư mục con "presets" (nếu là Folder Reference màu xanh)
        var fileUrl = Bundle.main.url(forResource: name, withExtension: "js", subdirectory: "presets")

        // Nếu không thấy, thử tìm ở thư mục gốc (nếu là Group màu vàng / bị Xcode làm phẳng)
        if fileUrl == nil {
            fileUrl = Bundle.main.url(forResource: name, withExtension: "js")
        }

        guard let url = fileUrl else {
            print("Không tìm thấy preset \(name).js trong bundle của app. Vui lòng kiểm tra lại Target Membership.")
            return nil
        }

        do {
            let jsCode = try String(contentsOf: url)
            guard let context = JSContext() else { return nil }

            // Giả lập đối tượng window của trình duyệt
            context.evaluateScript("var window = {};")
            context.evaluateScript(jsCode)

            let windowObj = context.objectForKeyedSubscript("window")
            let bgmPresets = windowObj?.objectForKeyedSubscript("BGM_PRESETS")

            // Lấy preset bằng tên file trước, nếu không có thì lấy key đầu tiên trong object
            var preset = bgmPresets?.objectForKeyedSubscript(name)
            if preset?.isUndefined == true || preset?.isNull == true {
                if let keys = context.evaluateScript("Object.keys(window.BGM_PRESETS)")?.toArray() as? [String],
                   let firstKey = keys.first {
                    preset = bgmPresets?.objectForKeyedSubscript(firstKey)
                }
            }

            // Ép kiểu mảng JS sang mảng Swift [[Double]]
            guard let chordRaw = preset?.objectForKeyedSubscript("chords").toArray() as? [Any],
                  let arpRaw = preset?.objectForKeyedSubscript("arps").toArray() as? [Any] else {
                return nil
            }

            let chordList = parseNestedDoubleArray(chordRaw)
            let arpList = parseNestedDoubleArray(arpRaw)

            // Đọc tham số synthesis — dùng giá trị mặc định nếu JS không có
            let chordDuration = preset?.objectForKeyedSubscript("chordDuration").toDouble() ?? 8.0
            let arpDuration = preset?.objectForKeyedSubscript("arpDuration").toDouble() ?? 0.4
            let arpDecay = preset?.objectForKeyedSubscript("arpDecay").toDouble() ?? 0.9998
            let padVolume = preset?.objectForKeyedSubscript("padVolume").toDouble() ?? 0.08
            let arpVolume = preset?.objectForKeyedSubscript("arpVolume").toDouble() ?? 0.25
            let portamento = preset?.objectForKeyedSubscript("portamento").toDouble() ?? 0.001

            let result = PresetData(
                chords: chordList, arps: arpList,
                chordDuration: chordDuration > 0 ? chordDuration : 8.0,
                arpDuration: arpDuration > 0 ? arpDuration : 0.4,
                arpDecay: arpDecay > 0 ? arpDecay : 0.9998,
                padVolume: padVolume > 0 ? padVolume : 0.08,
                arpVolume: arpVolume > 0 ? arpVolume : 0.25,
                portamento: portamento > 0 ? portamento : 0.001
            )
            presetCache[name] = result
            return result
        } catch {
            print("Lỗi khi đọc file preset: \(error)")
            return nil
        }
    }
    
    private func parseNestedDoubleArray(_ array: [Any]) -> [[Double]] {
        return array.compactMap { row in
            guard let subArr = row as? [Any] else { return nil }
            return subArr.compactMap { ($0 as? NSNumber)?.doubleValue }
        }
    }
    
    /// Phát nhạc nền bằng cách nạp preset vào Synthesizer
    func playBackgroundMusic(preset: String = "piano") {
        guard let data = loadPreset(name: preset) else {
            return
        }

        os_unfair_lock_lock(stateLock)
        synthState.chords = data.chords
        synthState.arps = data.arps
        synthState.chordDuration = data.chordDuration
        synthState.arpDuration = data.arpDuration
        synthState.arpDecay = data.arpDecay
        synthState.padVolume = data.padVolume
        synthState.arpVolume = data.arpVolume
        synthState.portamento = data.portamento
        synthState.sampleCount = 0
        os_unfair_lock_unlock(stateLock)

        currentPreset = preset

        do {
            if !engine.isRunning {
                try engine.start()
            }
        } catch {
            print("[AudioService] ❌ Engine start failed: \(error)")
        }
    }

    /// Tiếp tục phát nhạc nền từ vị trí đã tạm dừng, không reset dữ liệu
    func resumeBackgroundMusic() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("Không thể resume AVAudioEngine: \(error)")
        }
    }

    /// Chuyển preset nhạc nền khi đang phát
    func changePreset(_ name: String) {
        guard name != currentPreset else { return }

        guard let data = loadPreset(name: name) else {
            print("Không tìm thấy preset '\(name)'. Giữ nguyên preset hiện tại.")
            return
        }

        os_unfair_lock_lock(stateLock)
        synthState.chords = data.chords
        synthState.arps = data.arps
        synthState.chordDuration = data.chordDuration
        synthState.arpDuration = data.arpDuration
        synthState.arpDecay = data.arpDecay
        synthState.padVolume = data.padVolume
        synthState.arpVolume = data.arpVolume
        synthState.portamento = data.portamento
        synthState.sampleCount = 0
        os_unfair_lock_unlock(stateLock)

        currentPreset = name
    }

    func stopBackgroundMusic() {
        if engine.isRunning {
            engine.pause()
        }
    }
    
    // MARK: - Hiệu Ứng Âm Thanh (MP3/WAV gốc)
    
    /// Phát tiếng click, tiếng rót trà (hỗ trợ phát chồng và fallback .wav)
    func playEffect(name: String, ext: String = "mp3") {
        var url = Bundle.main.url(forResource: name, withExtension: ext)

        // Fallback: thử .wav nếu extension gốc không tìm thấy
        if url == nil && ext != "wav" {
            url = Bundle.main.url(forResource: name, withExtension: "wav")
        }

        guard let soundUrl = url else {
            // Log nhưng không lỗi, tránh spam console nếu user chưa kịp thêm file
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundUrl)
            player.volume = 0.3
            player.delegate = self
            player.prepareToPlay()
            player.play()
            effectPlayers.append(player)
        } catch {
            print("Lỗi phát hiệu ứng \(name): \(error.localizedDescription)")
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        effectPlayers.removeAll { $0 === player }
    }
}
