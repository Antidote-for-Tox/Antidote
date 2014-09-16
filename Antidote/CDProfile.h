//
//  CDProfile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDChat, CDUser;

@interface CDProfile : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) CDUser *user;
@property (nonatomic, retain) CDChat *chat;

@end
