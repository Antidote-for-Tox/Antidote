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

+ (CDUser *)getOrInsertUserWithPredicate:(NSPredicate *)predicate
                             configBlock:(void (^)(CDUser *theUser))configBlock;

@end
