//
//  UITableViewCell+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UITableViewCell+Utilities.h"

@implementation UITableViewCell (Utilities)

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
