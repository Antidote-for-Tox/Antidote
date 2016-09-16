//
//  OCTSubmanagerObjectsExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/07/16.
//  Copyright © 2016 dvor. All rights reserved.
//

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

    func setProfileSettings(settings: ProfileSettings) {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)

        settings.encodeWithCoder(archiver)
        archiver.finishEncoding()

        self.genericSettingsData = data.copy() as! NSData
    }
}
