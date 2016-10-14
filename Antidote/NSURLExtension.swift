// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

extension NSURL {
    func isToxURL() -> Bool {
        guard fileURL else {
            return false
        }

        let request = NSURLRequest(URL: self, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 0.1)
        var response: NSURLResponse? = nil

        _ = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)

        guard let mimeType = response?.MIMEType else {
            return false
        }

        guard let identifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, nil)?.takeRetainedValue() else {
            return false
        }

        return UTTypeEqual(identifier, kUTTypeData)
    }
}
