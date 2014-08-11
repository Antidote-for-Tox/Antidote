//
//  CoreDataManager+User.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager.h"
#import "CDUser.h"

@interface CoreDataManager (User)

+ (void)getOrInsertUserWithPredicate:(NSPredicate *)predicate
                         configBlock:(void (^)(CDUser *user))configBlock
                     completionQueue:(dispatch_queue_t)queue
                     completionBlock:(void (^)(CDUser *user))completionBlock;

@end
