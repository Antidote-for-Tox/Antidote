// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AVFoundation

class AlertAudioPlayer {
    enum Sound: String {
        case NewMessage = "isotoxin_NewMessage"
    }

    var playOnlyIfApplicationIsActive = true

    fileprivate var sounds: [Sound: SystemSoundID]!

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

    func playSound(_ sound: Sound) {
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
    func createSystemSoundForSound(_ sound: Sound) -> SystemSoundID {
        let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "aac")!

        var sound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &sound)
        return sound
    }
}
