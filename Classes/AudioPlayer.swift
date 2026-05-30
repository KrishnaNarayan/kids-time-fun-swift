import AVFoundation

class AudioPlayer: NSObject {

    private static let sharedInstance = AudioPlayer()

    class func getInstance() -> AudioPlayer {
        return sharedInstance
    }

    private var queuePlayer: AVQueuePlayer?

    func playAudio(forHours hours: Int, andMinutes minutes: Int) {
        var files: [URL] = []

        func mp3(_ name: String) -> URL? {
            guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else { return nil }
            return URL(fileURLWithPath: path)
        }

        if minutes == 0 {
            if hours == 12 {
                let r = Int.random(in: 0...2)
                switch r {
                case 0:
                    [mp3("12_m"), mp3("oclock_m")].compactMap { $0 }.forEach { files.append($0) }
                case 1:
                    if let u = mp3("12_midnight_m") { files.append(u) }
                default:
                    if let u = mp3("12_noon_m") { files.append(u) }
                }
            } else {
                [mp3("\(hours)_m"), mp3("oclock_m")].compactMap { $0 }.forEach { files.append($0) }
            }
        } else if minutes == 15 {
            if Int.random(in: 0...1) == 0 {
                [mp3("\(hours)_m"), mp3("15_m")].compactMap { $0 }.forEach { files.append($0) }
            } else {
                [mp3("quarter_past_m"), mp3("\(hours)_m")].compactMap { $0 }.forEach { files.append($0) }
            }
        } else if minutes == 30 {
            if Int.random(in: 0...1) == 0 {
                [mp3("\(hours)_m"), mp3("30_m")].compactMap { $0 }.forEach { files.append($0) }
            } else {
                [mp3("half_past_m"), mp3("\(hours)_m")].compactMap { $0 }.forEach { files.append($0) }
            }
        } else if minutes == 45 {
            let nextHour = hours == 12 ? 1 : hours + 1
            if Int.random(in: 0...1) == 0 {
                [mp3("\(hours)_m"), mp3("45_m")].compactMap { $0 }.forEach { files.append($0) }
            } else {
                [mp3("quarter_til_m"), mp3("\(nextHour)_m")].compactMap { $0 }.forEach { files.append($0) }
            }
        } else if minutes <= 29 {
            [mp3("\(minutes)_m"), mp3("minutes_past_m"), mp3("\(hours)_m")].compactMap { $0 }.forEach { files.append($0) }
        } else {
            let nextHour = hours == 12 ? 1 : hours + 1
            if Int.random(in: 0...1) == 0 {
                [mp3("\(minutes)_m"), mp3("minutes_past_m"), mp3("\(hours)_m")].compactMap { $0 }.forEach { files.append($0) }
            } else {
                [mp3("\(60 - minutes)_m"), mp3("minutes_til_m"), mp3("\(nextHour)_m")].compactMap { $0 }.forEach { files.append($0) }
            }
        }

        playQueuedFiles(files)
    }

    func playAudioTime(_ time: String) {
        let parts = time.components(separatedBy: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]) else { return }
        playAudio(forHours: h, andMinutes: m)
    }

    func playQueuedFiles(_ urls: [URL]) {
        guard KidsTimeFunAppState.sharedState().appSoundState else { return }
        let items = urls.map { AVPlayerItem(url: $0) }
        queuePlayer?.removeAllItems()
        queuePlayer = AVQueuePlayer(items: items)
        queuePlayer?.play()
    }

    func playCorrectWrong(_ correct: Bool) {
        let n = Int.random(in: 1...9)
        let name = correct ? "\(n)correct.mp3" : "\(n)wrong.mp3"
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else { return }
        playQueuedFiles([URL(fileURLWithPath: path)])
    }

    func playAudioFile(_ fileName: String) {
        guard let path = Bundle.main.path(forResource: "\(fileName)_m", ofType: "mp3") else { return }
        playQueuedFiles([URL(fileURLWithPath: path)])
    }

    func playAudioFile(_ fileName: String, withTime time: String) {
        var files: [URL] = []
        func mp3(_ name: String) -> URL? {
            guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else { return nil }
            return URL(fileURLWithPath: path)
        }
        if let u = mp3("\(fileName)_m") { files.append(u) }
        let parts = time.components(separatedBy: ":")
        if parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) {
            if let u = mp3("\(h)_m") { files.append(u) }
            if m != 0 {
                if let u = mp3("\(m)_m") { files.append(u) }
            } else {
                if let u = mp3("oclock_m") { files.append(u) }
            }
        }
        playQueuedFiles(files)
    }

    func playTellTime(_ fileName: String, playHours pHrs: Bool, hours hrs: String,
                      playMinutes pMnts: Bool, minutes mnts: String,
                      playAnd sAnd: Bool, playAgo sAgo: Bool) {
        var files: [URL] = []
        func mp3(_ name: String) -> URL? {
            guard let path = Bundle.main.path(forResource: "\(name)_m", ofType: "mp3") else { return nil }
            return URL(fileURLWithPath: path)
        }
        if let u = mp3(fileName) { files.append(u) }
        if pHrs {
            let parts = hrs.components(separatedBy: " ")
            parts.compactMap { mp3($0) }.forEach { files.append($0) }
        }
        if sAnd, let u = Bundle.main.path(forResource: "and_m", ofType: "mp3").map({ URL(fileURLWithPath: $0) }) {
            files.append(u)
        }
        if pMnts {
            let parts = mnts.components(separatedBy: " ")
            parts.compactMap { mp3($0) }.forEach { files.append($0) }
        }
        if sAgo, let u = Bundle.main.path(forResource: "ago_m", ofType: "mp3").map({ URL(fileURLWithPath: $0) }) {
            files.append(u)
        }
        playQueuedFiles(files)
    }
}
