// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension OCTManagerConfiguration {
    static func configurationWithBaseDirectory(_ baseDirectory: String) -> OCTManagerConfiguration? {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: baseDirectory, isDirectory:&isDirectory)

        guard exists && isDirectory.boolValue else {
            return nil
        }

        let configuration = OCTManagerConfiguration.default()

        let userDefaultsManager = UserDefaultsManager()

        configuration.options.iPv6Enabled = true
        configuration.options.udpEnabled = userDefaultsManager.UDPEnabled

        configuration.fileStorage = OCTDefaultFileStorage(baseDirectory: baseDirectory, temporaryDirectory: NSTemporaryDirectory())

        return configuration
    }
}
