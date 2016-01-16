//
//  AudioPlayer.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    enum Sound: String {
        case Calltone = "isotoxin_Calltone"
        case Hangup = "isotoxin_Hangup"
        case NewMessage = "isotoxin_NewMessage"
        case Ringtone = "isotoxin_Ringtone"
        case RingtoneWhileCall = "isotoxin_RingtoneWhileCall"
    }

    var players = [Sound: AVAudioPlayer]()

    func playSound(sound: Sound, loop: Bool) {
        guard let player = playerForSound(sound) else {
            return
        }

        player.numberOfLoops = loop ? -1 : 1
        player.play()
    }

    func stopSound(sound: Sound) {
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
    func playerForSound(sound: Sound) -> AVAudioPlayer? {
        if let player = players[sound] {
            return player
        }

        guard let path = NSBundle.mainBundle().pathForResource(sound.rawValue, ofType: "aac") else {
            return nil
        }

        guard let player = try? AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(path)) else {
            return nil
        }

        players[sound] = player
        return player
    }
}
