//
//  NSURLExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 29.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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
