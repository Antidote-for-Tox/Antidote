//
//  OCTDBChat.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 27.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTDBFriend.h"
#import "OCTDBMessageAbstract.h"

@interface OCTDBChat : RLMObject

/**
 * If no uniqueIdentifier is specified on chat creation, random one will be used.
 */
@property NSString *uniqueIdentifier;

@property RLMArray<OCTDBFriend> *friends;
@property OCTDBMessageAbstract *lastMessage;
@property NSString *enteredText;

// Realm truncates an NSDate to the second. A fix for this is in progress.
// See https://github.com/realm/realm-cocoa/issues/875
@property NSTimeInterval lastReadDateInterval;

@end
