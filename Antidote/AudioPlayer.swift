// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AVFoundation

class AudioPlayer {
    enum Sound: String {
        case Calltone = "isotoxin_Calltone"
        case Hangup = "isotoxin_Hangup"
        case Ringtone = "isotoxin_Ringtone"
        case RingtoneWhileCall = "isotoxin_RingtoneWhileCall"
    }

    var playOnlyIfApplicationIsActive = true

    fileprivate var players = [Sound: AVAudioPlayer]()

    func playSound(_ sound: Sound, loop: Bool) {
        if playOnlyIfApplicationIsActive && !UIApplication.isActive {
            return
        }

        guard let player = playerForSound(sound) else {
            return
        }

        player.numberOfLoops = loop ? -1 : 1
        player.currentTime = 0.0
        player.play()
    }

    func isPlayingSound(_ sound: Sound) -> Bool {
        guard let player = playerForSound(sound) else {
            return false
        }

        return player.isPlaying
    }

    func isPlaying() -> Bool {
        let pl = players.filter {
            $0.1.isPlaying
        }

        return !pl.isEmpty
    }

    func stopSound(_ sound: Sound) {
        guard let player = playerForSound(sound) else {
            return
        }
        player.stop()
    }

    func stopAll() {
        for (_, player) in players {
            player.stop()
        }
    }
}

private extension AudioPlayer {
    func playerForSound(_ sound: Sound) -> AVAudioPlayer? {
        if let player = players[sound] {
            return player
        }

        guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: "aac") else {
            return nil
        }

        guard let player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }

        players[sound] = player
        return player
    }
}
