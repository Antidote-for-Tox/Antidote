//
//  CDChat.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDMessage, CDUser;

@interface CDChat : NSManagedObject

@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) CDMessage *lastMessage;
@property (nonatomic) NSTimeInterval lastReadDate;

@end

@interface CDChat (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(CDMessage *)value;
- (void)removeMessagesObject:(CDMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addUsersObject:(CDUser *)value;
- (void)removeUsersObject:(CDUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
