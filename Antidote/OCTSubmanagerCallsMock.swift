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
    
    func call(to chat: OCTChat, enableAudio: Bool, enableVideo: Bool) throws -> OCTCall {
        return OCTCall()
    }
    
    func enableVideoSending(_ enable: Bool, for call: OCTCall) throws {
        // nop
    }
    
    func answer(_ call: OCTCall, enableAudio: Bool, enableVideo: Bool) throws {
        // nop
    }
    
    func send(_ control: OCTToxAVCallControl, to call: OCTCall) throws {
        // nop
    }
    
    func videoFeed() -> UIView? {
        return nil
    }
    
    func getVideoCallPreview(_ completionBlock: @escaping (CALayer?) -> Void) {
        // nop
    }
    
    func setAudioBitrate(_ bitrate: Int32, for call: OCTCall) throws {
        // nop
    }
    
    func routeAudio(toSpeaker speaker: Bool) throws {
        // nop
    }
    
    func `switch`(toCameraFront front: Bool) throws {
        // nop
    }
}
