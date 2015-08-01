//
//  FriendsCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StatusCircleView.h"

extern const CGFloat kFriendsCellAvatarSize;

@interface FriendsCell : UITableViewCell

@property (assign, nonatomic) UIImage *avatar;
@property (assign, nonatomic) NSString *name;
@property (assign, nonatomic) NSString *statusMessage;

@property (assign, nonatomic) BOOL showStatusView;
@property (assign, nonatomic) StatusCircleStatus status;

@end
