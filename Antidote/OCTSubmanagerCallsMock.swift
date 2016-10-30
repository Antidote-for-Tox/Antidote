// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerCallsMock: NSObject, OCTSubmanagerCalls {
    weak var delegate: OCTSubmanagerCallDelegate? = nil
    var enableMicrophone: Bool = false
    
    func setup() throws {
        // nop
    }
    
    func callToChat(chat: OCTChat, enableAudio: Bool, enableVideo: Bool) throws -> OCTCall {
        return OCTCall()
    }
    
    func enableVideoSending(enable: Bool, forCall call: OCTCall) throws {
        // nop
    }
    
    func answerCall(call: OCTCall, enableAudio: Bool, enableVideo: Bool) throws {
        // nop
    }
    
    func sendCallControl(control: OCTToxAVCallControl, toCall call: OCTCall) throws {
        // nop
    }
    
    func videoFeed() -> UIView? {
        return nil
    }
    
    func getVideoCallPreview(completionBlock: (CALayer?) -> Void) {
        // nop
    }
    
    func setAudioBitrate(bitrate: Int32, forCall call: OCTCall) throws {
        // nop
    }
    
    func routeAudioToSpeaker(speaker: Bool) throws {
        // nop
    }
    
    func switchToCameraFront(front: Bool) throws {
        // nop
    }
}
