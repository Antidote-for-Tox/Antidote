// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension OCTSubmanagerObjects {
    func friends(predicate predicate: NSPredicate? = nil) -> Results<OCTFriend> {
        let rlmResults = objectsForType(.Friend, predicate: predicate)
        return Results(results: rlmResults)
    }

    func friendRequests(predicate predicate: NSPredicate? = nil) -> Results<OCTFriendRequest> {
        let rlmResults = objectsForType(.FriendRequest, predicate: predicate)
        return Results(results: rlmResults)
    }

    func chats(predicate predicate: NSPredicate? = nil) -> Results<OCTChat> {
        let rlmResults = objectsForType(.Chat, predicate: predicate)
        return Results(results: rlmResults)
    }

    func calls(predicate predicate: NSPredicate? = nil) -> Results<OCTCall> {
        let rlmResults = objectsForType(.Call, predicate: predicate)
        return Results(results: rlmResults)
    }

    func messages(predicate predicate: NSPredicate? = nil) -> Results<OCTMessageAbstract> {
        let rlmResults = objectsForType(.MessageAbstract, predicate: predicate)
        return Results(results: rlmResults)
    }

    func getProfileSettings() -> ProfileSettings {
        guard let data = self.genericSettingsData else {
            return ProfileSettings()
        }

        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        let settings =  ProfileSettings(coder: unarchiver)
        unarchiver.finishDecoding()

        return settings
    }

    func saveProfileSettings(settings: ProfileSettings) {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)

        settings.encodeWithCoder(archiver)
        archiver.finishEncoding()

        self.genericSettingsData = data.copy() as! NSData
    }
}
