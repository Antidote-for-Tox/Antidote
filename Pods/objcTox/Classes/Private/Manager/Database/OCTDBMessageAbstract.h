//
//  OCTDBMessageAbstract.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTDBFriend.h"
#import "OCTDBMessageText.h"
#import "OCTDBMessageFile.h"
#import "OCTMessageAbstract.h"

@class OCTDBChat;
@interface OCTDBMessageAbstract : RLMObject

// Realm truncates an NSDate to the second. A fix for this is in progress.
// See https://github.com/realm/realm-cocoa/issues/875
@property NSTimeInterval dateInterval;
@property OCTDBFriend *sender;
@property OCTDBChat *chat;

/**
 * MessageAbstract should have on of the following properties.
 */
@property OCTDBMessageText *textMessage;
@property OCTDBMessageFile *fileMessage;

- (instancetype)initWithMessageAbstract:(OCTMessageAbstract *)message
                                 sender:(OCTDBFriend *)sender
                                   chat:(OCTDBChat *)chat;

@end
