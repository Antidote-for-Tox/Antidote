//
//  CDUser.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDChat, CDMessage, CDProfile;

@interface CDUser : NSManagedObject

@property (nonatomic, retain) NSString * clientId;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * avatarHash;

@property (nonatomic, retain) NSSet *chats;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) CDProfile *profile;

@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)addChatsObject:(CDChat *)value;
- (void)removeChatsObject:(CDChat *)value;
- (void)addChats:(NSSet *)values;
- (void)removeChats:(NSSet *)values;

- (void)addMessagesObject:(CDMessage *)value;
- (void)removeMessagesObject:(CDMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
