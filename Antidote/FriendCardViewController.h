//
//  FriendCardViewController.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ToxFriend.h"

@interface FriendCardViewController : UIViewController

- (instancetype)initWithToxFriend:(ToxFriend *)friend;

@end
