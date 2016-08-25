//
//  OCTManagerConfigurationExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

extension OCTManagerConfiguration {
    static func configurationWithBaseDirectory(baseDirectory: String) -> OCTManagerConfiguration? {
        var isDirectory: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(baseDirectory, isDirectory:&isDirectory)

        guard exists && isDirectory else {
            return nil
        }

        let configuration = OCTManagerConfiguration.defaultConfiguration()

        let userDefaultsManager = UserDefaultsManager()

        configuration.options.IPv6Enabled = userDefaultsManager.IPv6Enabled
        configuration.options.UDPEnabled = userDefaultsManager.UDPEnabled

        configuration.fileStorage = OCTDefaultFileStorage(baseDirectory: baseDirectory, temporaryDirectory: NSTemporaryDirectory())

        return configuration
    }
}
