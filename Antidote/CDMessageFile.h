//
//  CDMessageFile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDMessage;

@interface CDMessageFile : NSManagedObject

@property (nonatomic) BOOL isFullyLoaded;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pathFileName;
@property (nonatomic, retain) CDMessage *messageInverse;

@end
