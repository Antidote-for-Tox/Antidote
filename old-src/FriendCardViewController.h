//
//  FriendCardViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "BasicSettingsViewController.h"
#import "OCTFriend.h"

@interface FriendCardViewController : BasicSettingsViewController

- (instancetype)initWithToxFriend:(OCTFriend *)friend;

@end
