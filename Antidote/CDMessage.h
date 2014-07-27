//
//  CDMessage.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDChat, CDUser;

@interface CDMessage : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic) int32_t id;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) BOOL isDelivered;
@property (nonatomic, retain) CDChat *chat;
@property (nonatomic, retain) CDUser *user;
@property (nonatomic, retain) CDChat *chatForLastMessageInverse;

@end
