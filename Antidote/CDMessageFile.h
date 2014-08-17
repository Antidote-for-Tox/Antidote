//
//  CDMessageFile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 16.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDMessage;

@interface CDMessageFile : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * documentPath;
@property (nonatomic) uint64_t fileSize;
@property (nonatomic, retain) CDMessage *messageInverse;

@end
