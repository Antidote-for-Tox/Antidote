// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension OCTManagerConfiguration {
    static func configurationWithBaseDirectory(baseDirectory: String) -> OCTManagerConfiguration? {
        var isDirectory: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(baseDirectory, isDirectory:&isDirectory)

        guard exists && isDirectory else {
            return nil
        }

        let configuration = OCTManagerConfiguration.defaultConfiguration()

        let userDefaultsManager = UserDefaultsManager()

        configuration.options.IPv6Enabled = true
        configuration.options.UDPEnabled = userDefaultsManager.UDPEnabled

        configuration.fileStorage = OCTDefaultFileStorage(baseDirectory: baseDirectory, temporaryDirectory: NSTemporaryDirectory())

        return configuration
    }
}
