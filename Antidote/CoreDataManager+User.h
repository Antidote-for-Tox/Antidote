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

+ (CDUser *)firstUserWithPredicate:(NSPredicate *)predicate;

+ (CDUser *)insertUserWithConfigBlock:(void (^)(CDUser *theUser))configBlock;

@end
