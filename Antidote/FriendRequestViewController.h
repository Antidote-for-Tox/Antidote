//
//  FriendRequestViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 11.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCTFriendRequest;

@interface FriendRequestViewController : UIViewController

- (instancetype)initWithRequest:(OCTFriendRequest *)request;

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
