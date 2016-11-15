// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension OCTSubmanagerObjects {
    func friends(predicate: NSPredicate? = nil) -> Results<OCTFriend> {
        let rlmResults = objects(for: .friend, predicate: predicate)!
        return Results(results: rlmResults)
    }

    func friendRequests(predicate: NSPredicate? = nil) -> Results<OCTFriendRequest> {
        let rlmResults = objects(for: .friendRequest, predicate: predicate)!
        return Results(results: rlmResults)
    }

    func chats(predicate: NSPredicate? = nil) -> Results<OCTChat> {
        let rlmResults = objects(for: .chat, predicate: predicate)!
        return Results(results: rlmResults)
    }

    func calls(predicate: NSPredicate? = nil) -> Results<OCTCall> {
        let rlmResults = objects(for: .call, predicate: predicate)!
        return Results(results: rlmResults)
    }

    func messages(predicate: NSPredicate? = nil) -> Results<OCTMessageAbstract> {
        let rlmResults = objects(for: .messageAbstract, predicate: predicate)!
        return Results(results: rlmResults)
    }

    func getProfileSettings() -> ProfileSettings {
        guard let data = self.genericSettingsData else {
            return ProfileSettings()
        }

        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        let settings =  ProfileSettings(coder: unarchiver)
        unarchiver.finishDecoding()

        return settings
    }

    func saveProfileSettings(_ settings: ProfileSettings) {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        settings.encode(with: archiver)
        archiver.finishEncoding()

        self.genericSettingsData = data.copy() as! Data
    }
}
