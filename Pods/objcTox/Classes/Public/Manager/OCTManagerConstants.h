//
//  OCTManagerConstants.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

/**
 * Sort type for FriendsContainer.
 */
typedef NS_ENUM(NSUInteger, OCTFriendsSort) {
    /**
     * Sort by friend name. In case if name will be nil, friends will be sorted by publicKey.
     */
    OCTFriendsSortByName = 0,

    /**
     * Sort by status. Within groups friends will be sorted by name.
     * - online
     * - away
     * - busy
     * - offline
     */
    OCTFriendsSortByStatus,
};

typedef NS_ENUM(NSUInteger, OCTMessageFileType) {
    /**
     * File is incoming and is waiting confirmation of user to be downloaded.
     * Please start loading or cancel it with <<placeholder>> method.
     */
    OCTMessageFileTypeWaitingConfirmation,

    /**
     * File is downloading or uploading.
     */
    OCTMessageFileTypeLoading,

    /**
     * Downloading or uploading of file is paused.
     */
    OCTMessageFileTypePaused,

    /**
     * Downloading or uploading of file was canceled.
     */
    OCTMessageFileTypeCanceled,

    /**
     * File is fully loaded.
     * In case of incoming file now it can be shown to user.
     */
    OCTMessageFileTypeReady,
};

/**
 * NSNotification posted on any friend updates (friend added, removed, or some of friend properties updated).
 * Always is posted on main thread.
 *
 * The notification object is nil. The userInfo dictionary contains dictionary with following keys:
 * kOCTContainerUpdateKeyInsertedSet - NSIndexSet with indexes of friends that were inserted;
 * kOCTContainerUpdateKeyRemovedSet  - NSIndexSet with indexes of friends that were removed;
 * kOCTContainerUpdateKeyUpdatedSet  - NSIndexSet with indexes of friends that were updated.
 * Note that on update there may be another friend than before.
 *
 * The order of friends may change (in case if friendSort changes or sort-dependant property changes).
 * In that case some of friends will be removed (see RemovedSet) and then added again (see InsertedSet).
 */
extern NSString *const kOCTFriendsContainerUpdateNotification;

extern NSString *const kOCTContainerUpdateKeyInsertedSet;
extern NSString *const kOCTContainerUpdateKeyRemovedSet;
extern NSString *const kOCTContainerUpdateKeyUpdatedSet;

