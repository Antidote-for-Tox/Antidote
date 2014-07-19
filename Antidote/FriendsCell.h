//
//  FriendsCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StatusCircleView.h"

@interface FriendsCell : UITableViewCell

@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (assign, nonatomic) StatusCircleStatus status;

- (void)redraw;

+ (CGFloat)height;
+ (NSString *)reuseIdentifier;

@end
