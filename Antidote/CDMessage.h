//
//  CDMessage.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CDMessageText.h"
#import "CDMessageFile.h"
#import "CDMessagePendingFile.h"
#import "CDMessageCall.h"

@class CDChat, CDUser;

@interface CDMessage : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) CDChat *chat;
@property (nonatomic, retain) CDChat *chatForLastMessageInverse;
@property (nonatomic, retain) CDUser *user;

// should have one of below properties
@property (nonatomic, retain) CDMessageText *text;
@property (nonatomic, retain) CDMessageFile *file;
@property (nonatomic, retain) CDMessagePendingFile *pendingFile;
@property (nonatomic, retain) CDMessageCall *call;

@end
