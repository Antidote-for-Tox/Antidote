//
//  AlertAudioPlayer.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import AVFoundation

class AlertAudioPlayer {
    enum Sound: String {
        case NewMessage = "isotoxin_NewMessage"
    }

    var playOnlyIfApplicationIsActive = true

    private var sounds: [Sound: SystemSoundID]!

    init() {
        sounds = [
            .NewMessage: createSystemSoundForSound(.NewMessage),
        ]
    }

    deinit {
        for (_, systemSound) in sounds {
            AudioServicesDisposeSystemSoundID(systemSound)
        }
    }

    func playSound(sound: Sound) {
        if playOnlyIfApplicationIsActive && !UIApplication.isActive {
            return
        }

        guard let systemSound = sounds[sound] else {
            return
        }

        AudioServicesPlayAlertSound(systemSound)
    }
}

private extension AlertAudioPlayer {
    func createSystemSoundForSound(sound: Sound) -> SystemSoundID {
        let url = NSBundle.mainBundle().URLForResource(sound.rawValue, withExtension: "aac")!

        var sound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &sound)
        return sound
    }
}
