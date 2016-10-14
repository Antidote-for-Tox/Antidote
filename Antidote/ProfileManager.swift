// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private struct Constants {
    static let SaveDirectoryPath = "saves"

    // TODO get this constant from objcTox OCTDefaultFileStorage
    static let ToxFileName = "save.tox"
}

class ProfileManager {
    private(set) var allProfileNames: [String]

    init() {
        allProfileNames = []

        reloadProfileNames()
    }

    func createProfileWithName(name: String, copyFromURL: NSURL? = nil) throws {
        let path = pathFromName(name)
        let fileManager = NSFileManager.defaultManager()

        try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)

        if let url = copyFromURL {
            let saveURL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(Constants.ToxFileName)
            try fileManager.moveItemAtURL(url, toURL: saveURL)
        }

        reloadProfileNames()
    }

    func deleteProfileWithName(name: String) throws {
        let path = pathFromName(name)

        try NSFileManager.defaultManager().removeItemAtPath(path)

        reloadProfileNames()
    }

    func renameProfileWithName(fromName: String, toName: String) throws {
        let fromPath = pathFromName(fromName)
        let toPath = pathFromName(toName)

        try NSFileManager.defaultManager().moveItemAtPath(fromPath, toPath: toPath)

        reloadProfileNames()
    }

    func pathForProfileWithName(name: String) -> String {
        return pathFromName(name)
    }
}

private extension ProfileManager {
    func saveDirectoryPath() -> String {
        let path: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        return path.stringByAppendingPathComponent(Constants.SaveDirectoryPath)
    }

    func pathFromName(name: String) -> String {
        let directoryPath: NSString = saveDirectoryPath()
        return directoryPath.stringByAppendingPathComponent(name)
    }

    func reloadProfileNames() {
        let fileManager = NSFileManager.defaultManager()
        let savePath = saveDirectoryPath()

        let contents = try? fileManager.contentsOfDirectoryAtPath(savePath)

        allProfileNames = contents?.filter {
            let path = (savePath as NSString).stringByAppendingPathComponent($0)

            var isDirectory: ObjCBool = false
            fileManager.fileExistsAtPath(path, isDirectory:&isDirectory)

            return isDirectory.boolValue
        } ?? [String]()
    }
}
