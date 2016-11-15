// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

extension URL {
    func isToxURL() -> Bool {
        guard isFileURL else {
            return false
        }

        let request = URLRequest(url: self, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 0.1)
        var response: URLResponse? = nil

        _ = try? NSURLConnection.sendSynchronousRequest(request, returning: &response)

        guard let mimeType = response?.mimeType else {
            return false
        }

        guard let identifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }

        return UTTypeEqual(identifier, kUTTypeData)
    }
}
